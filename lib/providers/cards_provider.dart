import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:nanoid/async.dart';
import 'package:validators/sanitizers.dart';
import 'package:zxzc9992/models/card.dart';
import 'package:zxzc9992/services/convert_to_map.dart';
import 'package:zxzc9992/services/crud_helper.dart';
import 'package:zxzc9992/services/local_db/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';

class CardsProvider with ChangeNotifier {
  final CrudHelper _crudHelper = CrudHelper();

  List<CardModel> _currentCards = [];
  List<CardModel> get currentCards => _currentCards;

  late String currentDeckId;

  Future<void> getCards(String deckId) async {
    currentDeckId = deckId;

    final cardsData = await DBHelper.fetch(
      'cards',
      where: 'deck_id = "$deckId"',
    );

    List<CardModel> loadedCards = [];
    loadedCards = cardsData
        .map((e) => CardModel(
              id: e['id'] as String,
              deckId: currentDeckId,
              lastUpdated: e['lastUpdated'] as int,
              front: e['front'] as String,
              back: e['back'] as String,
              frontImg:
                  e['frontImg'] != null ? File(e['frontImg'] as String) : null,
              backImg:
                  e['backImg'] != null ? File(e['backImg'] as String) : null,
              grade: e['grade'] as int,
              schedule: e['schedule'] as int,
              interval: e['interval'] as int,
              repetitions: e['repetitions'] as int,
              easeFactor: e['ease_factor'] as double,
            ))
        .toList();
    _currentCards = loadedCards;
    await _updateCardsAmount();

    if (_currentCards.isNotEmpty) sortCards();
  }

  void sortCards([bool notifyListener = false]) {
    if (_currentCards.isNotEmpty) {
      _currentCards.sort((a, b) => a.schedule.compareTo(b.schedule));
    }

    print('sort');
    if (notifyListener) notifyListeners();
  }

  Future<void> _updateCardsAmount() async {
    final cardsAmount = _currentCards.length;
    final query =
        "UPDATE decks SET cards_amount = $cardsAmount WHERE id = '$currentDeckId'";
    await DBHelper.rawQuery(query);
  }

  Future<void> addCard({
    required String front,
    required String back,
    File? frontImg,
    File? backImg,
  }) async {
    final randId = await nanoid(11);
    final epoch = DateTime.now().millisecondsSinceEpoch;

    final newCard = CardModel(
      id: randId,
      deckId: currentDeckId,
      lastUpdated: epoch,
      front: _putInParagraph(escape(front)),
      back: _putInParagraph(escape(back)),
      frontImg: frontImg,
      backImg: backImg,
      schedule: epoch,
    );

    _currentCards.add(newCard);
    notifyListeners();

    print(newCard);

    await _crudHelper.insertLocalCard(newCard);

    await _crudHelper.addCardToSync(newCard.id, {
      'deck_id': currentDeckId,
      'card_id': newCard.id,
      'operation': 'insert',
    });

    await _updateCardsAmount();
  }

  Future<void> editCard({
    required String id,
    required String front,
    required String back,
    File? frontImg,
    File? backImg,
  }) async {
    final epoch = DateTime.now().millisecondsSinceEpoch;

    final newCard = _currentCards.firstWhere((e) => e.id == id).copyWith(
          lastUpdated: epoch,
          front: _putInParagraph(escape(front)),
          back: _putInParagraph(escape(back)),
          frontImg: frontImg,
          backImg: backImg,
        );

    final cardIndex = _currentCards.indexWhere((e) => e.id == id);
    _currentCards[cardIndex] = newCard;
    notifyListeners();

    await _crudHelper.insertLocalCard(newCard);
  }

  Future<void> deleteCard(String cardId) async {
    _currentCards.removeWhere((e) => e.id == cardId);
    notifyListeners();

    await DBHelper.delete('cards', 'id', cardId);

    await _crudHelper.addCardToSync(cardId, {
      'deck_id': currentDeckId,
      'card_id': cardId,
      'operation': 'delete',
    });

    await _updateCardsAmount();
  }

  // Reset progress of all cards in current deck, or just single card if cardId is provided.
  Future<void> resetProgress([String? cardId]) async {
    final List<CardModel> singleCardList = [];

    if (cardId != null) {
      final card = _currentCards.firstWhere((e) => e.id == cardId);
      singleCardList.add(card);
    }

    final list = cardId != null ? singleCardList : _currentCards;
    for (final card in list) {
      final epoch = DateTime.now().millisecondsSinceEpoch;

      card.grade = 0;
      card.schedule = epoch;
      card.interval = 0;
      card.repetitions = 0;
      card.easeFactor = 2.5;

      final newCard = card.copyWith(
        grade: 0,
        schedule: epoch,
        interval: 0,
        repetitions: 0,
        easeFactor: 2.5,
      );

      await _crudHelper.insertLocalCard(newCard);
    }
    notifyListeners();
  }

  List<CardModel> prepareCards(dynamic options) {
    final List<CardModel> cardsList = [];
    int cardsPerGame = 25;

    if (options != null) {
      cardsPerGame = options['cards_per_game'] as int;
    }

    for (final card in _currentCards) {
      cardsList.add(card);
      if (cardsList.length >= cardsPerGame) break;
    }

    cardsList.shuffle();

    return cardsList;
  }

  Future<Map<String, dynamic>?> getData() async {
    const apiKey = 'https://zxzc333.herokuapp.com/decks';
    final url = Uri.parse('$apiKey/$currentDeckId/getDeck');

    try {
      final response = await http.get(url);
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final decodedMap = ConvertToMap().convertCardsToMap(decoded);

      return decodedMap;
    } catch (e) {
      print('getData: $e');
      return null;
    }
  }

  final List<CardModel> cardsToUpdate = [];

  Future<void> syncCards() async {
    print('SyncCards');
    final List<String> cardsToDelete = [];

    await _checkCardsToSync();

    final decoded = await getData();
    if (decoded == null) return;

    for (final key in decoded.keys) {
      final localCard = _currentCards.firstWhereOrNull((e) => e.id == key);

      if (localCard == null) {
        _addLocalCard(key, decoded[key]);
      } else {
        _compareEntries(key, decoded[key], localCard);
      }
    }

    if (cardsToUpdate.isNotEmpty) {
      await _crudHelper.updateManyCardsOnline(cardsToUpdate, currentDeckId);
    }

    for (final x in _currentCards) {
      final jd = decoded[x.id];

      if (jd == null) {
        await DBHelper.delete('cards', 'id', x.id);
        cardsToDelete.add(x.id);
      }
    }
    _currentCards.removeWhere((e) => cardsToDelete.contains(e.id));
    print('Sync is done');
  }

  Future<void> _checkCardsToSync() async {
    final List<CardModel> cardsToInsert = [];
    final List<String> cardsToDelete = [];

    final data = await DBHelper.fetch(
      'cardsToSync',
      where: 'deck_id = "$currentDeckId"',
    );

    if (data.isEmpty) return;

    for (final x in data) {
      final operation = x['operation'];
      if (operation == 'insert') {
        print('insert');
        final cardId = x['card_id'].toString();

        final card = await DBHelper.fetch(
          'cards',
          where: 'id = "$cardId"',
        );

        final epoch = DateTime.now().millisecondsSinceEpoch;

        final newCard = CardModel(
          id: card[0]['id'] as String,
          deckId: currentDeckId,
          lastUpdated: card[0]['lastUpdated'] as int,
          front: card[0]['front'] as String,
          back: card[0]['back'] as String,
          schedule: epoch,
        );

        cardsToInsert.add(newCard);
      } else if (operation == 'delete') {
        cardsToDelete.add(x['card_id'].toString());
      }
    }

    if (cardsToInsert.isNotEmpty && cardsToDelete.isNotEmpty) {
      print('cardsToInsert.isNotEmpty && cardsToDelete.isNotEmpty)');

      final results = await Future.wait([
        _crudHelper.insertManyCardsOnline(currentDeckId, cardsToInsert),
        _crudHelper.deleteManyCardsOnline(currentDeckId, cardsToDelete),
      ]);

      if (results[0].error == null) {
        for (final _ in cardsToInsert) {
          await deleteFromCardsToSync(currentDeckId, 'insert');
        }
      }
      if (results[1].error == null) {
        for (final _ in cardsToDelete) {
          await deleteFromCardsToSync(currentDeckId, 'delete');
        }
      }
    } else {
      if (cardsToInsert.isNotEmpty) {
        print('cardsToInsert.isNotEmpty');
        final res = await _crudHelper.insertManyCardsOnline(
          currentDeckId,
          cardsToInsert,
        );
        print(res.error);
        if (res.error != null) return;

        for (final _ in cardsToInsert) {
          await deleteFromCardsToSync(currentDeckId, 'insert');
        }
      } else if (cardsToDelete.isNotEmpty) {
        print('cardsToDelete.isNotEmpty');
        final res = await _crudHelper.deleteManyCardsOnline(
          currentDeckId,
          cardsToDelete,
        );
        print(res.error);
        if (res.error != null) return;

        for (final _ in cardsToDelete) {
          await deleteFromCardsToSync(currentDeckId, 'delete');
        }
      }
    }
  }

  Future<void> deleteFromCardsToSync(String deckId, String operation) async {
    await DBHelper.rawQuery(
      "DELETE FROM cardsToSync WHERE deck_id = '$deckId' AND operation = '$operation'",
    );
  }

  Future<void> _addLocalCard(String key, dynamic val) async {
    final epoch = DateTime.now().millisecondsSinceEpoch;

    final newCard = CardModel(
      id: key,
      deckId: currentDeckId,
      lastUpdated: val['lastUpdated'] as int,
      front: val['front'] as String,
      back: val['back'] as String,
      schedule: epoch,
    );

    _currentCards.add(newCard);

    await _crudHelper.insertLocalCard(newCard);
  }

  Future<void> _compareEntries(
    String decodedEntryKey,
    dynamic decodedEntryValue,
    CardModel card,
  ) async {
    final online = decodedEntryValue['lastUpdated'] as int;
    final offline = card.lastUpdated;

    if (online > offline) {
      final newCard = card.copyWith(
        lastUpdated: decodedEntryValue['lastUpdated'] as int,
        front: decodedEntryValue['front'] as String,
        back: decodedEntryValue['back'] as String,
      );

      await _crudHelper.insertLocalCard(newCard);
    } else if (online < offline) {
      print(card);
      cardsToUpdate.add(card);
    }
  }

  String _putInParagraph(String text) => '<p>$text</p>';
}
