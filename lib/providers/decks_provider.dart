import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nanoid/nanoid.dart';
import 'package:validators/sanitizers.dart';
import 'package:zxzc9992/models/deck.dart';
import 'package:zxzc9992/services/auth/auth.dart';
import 'package:zxzc9992/services/convert_to_map.dart';
import 'package:zxzc9992/services/crud_helper.dart';
import 'package:zxzc9992/services/local_db/sqflite.dart';
import 'package:http/http.dart' as http;
import 'package:collection/collection.dart';
import 'package:zxzc9992/utils/keys.dart';

class DecksProvider with ChangeNotifier {
  final CrudHelper _crudHelper = CrudHelper();
  final _auth = Auth();

  List<Deck> _decksList = [];
  List<Deck> get decksList => _decksList;

  late Deck _currentDeck;
  Deck get currentDeck => _currentDeck;

  late String? userId;

  /// `getDecksList()` returns all decks, but without it's cards.
  Future<void> getDecksList() async {
    print('getDecksList: ${_auth.auth.currentUser?.id}');

    final authBox = Hive.box(authBoxKey);
    final sessionInfo = authBox.get(sessionInfoKey) as String;
    final decoded = jsonDecode(sessionInfo) as Map<String, dynamic>;
    userId = decoded["currentSession"]["user"]["id"] as String;

    print(userId);

    final data = await DBHelper.fetch(
      'decks',
      where: 'userId = "$userId"',
      orderBy: 'title ASC',
    );

    _decksList = data
        .map((e) => Deck(
              id: e['id'].toString(),
              createdAt: e['createdAt'] as int,
              lastPlayed: e['lastPlayed'] != null ? e['lastPlayed'] as int : 0,
              lastUpdated: e['lastUpdated'] as int,
              title: e['title'] as String,
              cardsAmount: e['cards_amount'] as int,
            ))
        .toList();

    sortDecks(lastReviewed: true);
  }

  void sortDecks({bool alphabetically = false, bool lastReviewed = false}) {
    if (_decksList.isEmpty) return;

    if (alphabetically) {
      print('jd');
      _decksList.sort((a, b) => a.title.compareTo(b.title));
      return;
    }

    if (lastReviewed) {
      _decksList.sort((a, b) => b.lastPlayed.compareTo(a.lastPlayed));
      return;
    }
    notifyListeners();
  }

  Future<void> getDeck(String deckId) async {
    _currentDeck = _decksList.firstWhere((e) => e.id == deckId);
  }

  Future<void> addDeck(String title) async {
    final randId = nanoid(11);
    final epoch = DateTime.now().millisecondsSinceEpoch;

    final newDeck = Deck(
      id: randId,
      createdAt: epoch,
      lastPlayed: 0,
      lastUpdated: epoch,
      title: escape(title),
    );

    _decksList.add(newDeck);
    notifyListeners();

    // TODO: Jeżeli pojawi sie error to return
    await _crudHelper.instertLocalDeck(newDeck);

    final res = await _crudHelper.insertOnlineDeck(newDeck);
    if (res.error != null) {
      await _crudHelper.addDeckToSync(newDeck.id, {
        'id': newDeck.id,
        'operation': 'insert',
      });
    }
  }

  Future<void> editDeck(String id, String title) async {
    final epoch = DateTime.now().millisecondsSinceEpoch;

    final newDeck = _decksList.firstWhere((e) => e.id == id).copyWith(
          lastUpdated: epoch,
          title: escape(title),
        );

    _currentDeck = newDeck;

    final deckIndex = _decksList.indexWhere((e) => e.id == id);
    _decksList[deckIndex] = newDeck;
    notifyListeners();

    await _crudHelper.updateLocalDeck(
        id, {'lastUpdated': newDeck.lastUpdated, 'title': newDeck.title});

    await _crudHelper.updateDeckOnline(newDeck);
  }

  Future<void> deleteDeck(String deckId) async {
    _decksList.removeWhere((e) => e.id == deckId);
    notifyListeners();

    await _crudHelper.deleteLocalDeck(deckId);

    await DBHelper.delete('cardsToSync', 'deck_id', deckId);

    final res = await _crudHelper.deleteDeckOnline(deckId);
    if (res.error == null) {
      await _crudHelper.addDeckToSync(deckId, {});
    }
  }

  Future<Map<String, dynamic>?> getData() async {
    final apiKey = '$decksApi/$userId';
    final url = Uri.parse(apiKey);

    try {
      final res = await http.get(url);
      final decoded = jsonDecode(res.body) as List<dynamic>;

      final decodedMap = ConvertToMap().convertDecksToMap(decoded);

      return decodedMap;
    } catch (e) {
      print('getData $e');
      return null;
    }
  }

  List<Deck> decksToUpdate = [];

  //Main function of syncing
  Future<void> syncDecks() async {
    final List<Deck> decksToDelete = [];

    await checkDecksToSync();

    final decoded = await getData();

    if (decoded == null || decoded.isEmpty) return;

    for (final key in decoded.keys) {
      final localDeck = _decksList.firstWhereOrNull((e) => e.id == key);

      if (localDeck == null) {
        _addLocalDeck(key, decoded[key]);
      } else {
        _compareEntries(key, decoded[key], localDeck);
      }
    }

    if (decksToUpdate.isNotEmpty) {
      await _crudHelper.updateManyDecksOnline(decksToUpdate);
    }

    for (final x in _decksList) {
      final jd = decoded[x.id];

      if (jd == null) {
        await _crudHelper.deleteLocalDeck(x.id);
        decksToDelete.add(x);
      }
    }

    _decksList.removeWhere((e) => decksToDelete.contains(e));

    print('Syncing is done');
  }

  Future<void> checkDecksToSync() async {
    final List<Map<String, dynamic>> decksToInsert = [];
    final List<Map<String, dynamic>> decksToDelete = [];

    final data = await DBHelper.fetch('decksToSync');
    print('decksToSync: $data');
    if (data.isEmpty) return;

    // Sorting on decks to inserted and decks to deleted.
    for (final x in data) {
      final operation = x['operation'];
      if (operation == 'insert') {
        // TODO: Check if x['id'] can be int
        final deckId = x['id'];
        final deck = await DBHelper.fetch('decks', where: 'id = "$deckId"');

        if (deck.isNotEmpty) {
          decksToInsert.add(deck[0]);
        }
      } else if (operation == 'delete') {
        decksToDelete.add({"id": x['id']});
      }
    }

    if (decksToInsert.isNotEmpty) {
      final res = await _crudHelper.insertManyDecksOnline(decksToInsert);
      if (res.error != null) return;

      for (final x in decksToInsert) {
        await deleteFromDecksToAdd(x['id'].toString());
      }
    }

    if (decksToDelete.isNotEmpty) {
      final List<String> decksIds = [];

      for (final x in decksToDelete) {
        decksIds.add(x['id'].toString());
      }

      final res = await _crudHelper.deleteManyDecksOnline(decksIds);
      if (res.error != null) return;

      for (final x in decksToDelete) {
        await deleteFromDecksToAdd(x['id'].toString());
      }
    }
  }

  Future<void> _addLocalDeck(String key, dynamic val) async {
    final createdAt = val['createdAt'] ?? 0;
    final newDeck = Deck(
      id: key,
      createdAt: createdAt as int,
      lastPlayed: 0,
      lastUpdated: val['lastUpdated'] as int,
      title: val['title'] as String,
    );

    _decksList.add(newDeck);

    await _crudHelper.instertLocalDeck(newDeck);
  }

  void _compareEntries(
    String decodedEntryKey,
    dynamic decodedEntryValue,
    Deck deck,
  ) async {
    final online = decodedEntryValue['lastUpdated'] as int;
    final offline = deck.lastUpdated;

    final createdAt = decodedEntryValue['createdAt'] ?? 0;
    final title = decodedEntryValue['title'] as String;

    if (online > offline) {
      final newDeck = Deck(
        id: decodedEntryKey,
        createdAt: createdAt as int,
        lastPlayed: deck.lastPlayed,
        lastUpdated: online,
        title: title,
      );
      await _crudHelper.instertLocalDeck(newDeck);
    } else if (online < offline) {
      decksToUpdate.add(deck);
    }
  }

  //Helper function
  Future<void> deleteFromDecksToAdd(String id) async {
    await DBHelper.delete('decksToSync', 'id', id);
  }
}
