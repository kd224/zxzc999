import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:zxzc9992/models/card.dart';
import 'package:zxzc9992/models/deck.dart';
import 'package:zxzc9992/models/crud_response.dart';
import 'package:zxzc9992/services/auth/auth.dart';
import 'package:zxzc9992/services/local_db/sqflite.dart';
import 'package:http/http.dart' as http;

class CrudHelper {
  final decksApi = 'https://zxzc333.herokuapp.com/decks';
  final cardsApi = 'https://zxzc333.herokuapp.com/cards';

  final headers = {"Content-Type": "application/json"};

  final _auth = Auth();

  Future<void> instertLocalDeck(Deck deck) async {
    // TODO: Not always not null
    final userId = _auth.auth.currentUser?.id;
    
    // TODO: Do it better
    if (userId == null) return;

    print('1: $userId');

    await DBHelper.insert('decks', {
      'id': deck.id,
      'userId': userId,
      'createdAt': deck.createdAt,
      'lastPlayed': deck.lastPlayed,
      'lastUpdated': deck.lastUpdated,
      'title': deck.title,
      'cards_amount': deck.cardsAmount,
    });

    print(2);
  }

  Future<void> updateLocalDeck(String deckId, Map<String, Object> data) async {
    await DBHelper.update(table: 'decks', data: data, deckId: deckId);
  }

  Future<void> insertLocalCard(CardModel card) async {
    DBHelper.insert('cards', {
      'id': card.id,
      'deck_id': card.deckId,
      'lastUpdated': card.lastUpdated,
      'front': card.front,
      'back': card.back,
      'frontImg': card.frontImg != null ? card.frontImg!.path : null,
      'backImg': card.backImg != null ? card.backImg!.path : null,
      'frontMP3': null,
      'backMP3': null,
      'grade': card.grade,
      'schedule': card.schedule,
      'interval': card.interval,
      'repetitions': card.repetitions,
      'ease_factor': card.easeFactor,
    });
  }

  Future<void> deleteLocalDeck(String deckId) async {
    await DBHelper.delete('cards', 'deck_id', deckId);
    await DBHelper.delete('decks', 'id', deckId);
  }

  Future<CrudResponse> insertOnlineDeck(Deck deck) async {
    final url = Uri.parse('$decksApi/insertOne');

    final encodedDeck = jsonEncode({
      'id': deck.id,
      'userId': _auth.auth.currentUser!.id,
      'createdAt': deck.createdAt,
      'lastUpdated': deck.lastUpdated,
      'title': deck.title,
    });

    try {
      final res = await http.post(url, headers: headers, body: encodedDeck);

      return _handleStatusCode(res);
    } on SocketException {
      return const CrudResponse(
          error: 'No internet connection', isOnline: false);
    } catch (e) {
      return CrudResponse(error: e.toString());
    }
  }

  Future<CrudResponse> insertManyDecksOnline(List<dynamic> decks) async {
    final url = Uri.parse('$decksApi/insertMany');

    final encodedDecks = jsonEncode(decks);

    try {
      final res = await http.post(url, headers: headers, body: encodedDecks);

      return _handleStatusCode(res);
    } on SocketException {
      return const CrudResponse(
          error: 'No internet connection', isOnline: false);
    } catch (e) {
      return CrudResponse(error: e.toString());
    }
  }

  Future<CrudResponse> updateDeckOnline(Deck deck) async {
    final url = Uri.parse('$decksApi/updateOne/${deck.id}');

    final encodedDeck = jsonEncode([
      {"propName": "lastUpdated", "value": deck.lastUpdated},
      {"propName": "title", "value": deck.title}
    ]);

    try {
      final res = await http.patch(url, headers: headers, body: encodedDeck);

      print(res.body);
      return _handleStatusCode(res);
    } on SocketException {
      return const CrudResponse(
          error: 'No internet connection', isOnline: false);
    } catch (e) {
      return CrudResponse(error: e.toString());
      // ? In case if error occur, deck will be updated as case 6 (decks_provider).
    }
  }

  Future<CrudResponse> updateManyDecksOnline(List<Deck> decks) async {
    final url = Uri.parse('$decksApi/updateMany');

    try {
      final List<Map<String, dynamic>> decksToUpdate = [];

      for (final x in decks) {
        decksToUpdate.add({
          "id": x.id.toString(),
          "data": {"title": x.title, "lastUpdated": x.lastUpdated}
        });
      }

      final res = await http.patch(url, headers: headers, body: decksToUpdate);

      return _handleStatusCode(res);
    } on SocketException {
      return const CrudResponse(
          error: 'No internet connection', isOnline: false);
    } catch (e) {
      return CrudResponse(error: e.toString());
    }
  }

  Future<CrudResponse> deleteDeckOnline(String deckId) async {
    final url = Uri.parse('$decksApi/deleteOne/$deckId');

    try {
      final res = await http.delete(url);

      return _handleStatusCode(res);
    } on SocketException {
      return const CrudResponse(
          error: 'No internet connection', isOnline: false);
    } catch (e) {
      return CrudResponse(error: e.toString());
    }
  }

  Future<CrudResponse> deleteManyDecksOnline(List<String> deckId) async {
    final url = Uri.parse('$decksApi/deleteMany');
    try {
      final json = jsonEncode(deckId);
      final res = await http.delete(url, headers: headers, body: json);

      return _handleStatusCode(res);
    } on SocketException {
      return const CrudResponse(
          error: 'No internet connection', isOnline: false);
    } catch (e) {
      return CrudResponse(error: e.toString());
    }
  }

  Future<CrudResponse> insertManyCardsOnline(
    String deckId,
    List<CardModel> cards,
  ) async {
    final url = Uri.parse('$cardsApi/$deckId/insertMany');
    final json = jsonEncode(cards);

    try {
      final res = await http.post(url, headers: headers, body: json);

      return _handleStatusCode(res);
    } on SocketException {
      return const CrudResponse(
          error: 'No internet connection', isOnline: false);
    } catch (e) {
      return CrudResponse(error: e.toString());
    }
  }

  // TODO: Offline handler?
  Future<void> updateManyCardsOnline(
    List<CardModel> cards,
    String deckId,
  ) async {
    try {
      final url = Uri.parse('$cardsApi/$deckId/updateMany');

      final json = jsonEncode(cards);
      print(json);

      final res = await http.patch(url, headers: headers, body: json);
      print('updateManyCardsOnline res: ${res.body}');
    } catch (e) {
      print('cardUpdateOnline: $e');
    }
  }

  Future<CrudResponse> deleteManyCardsOnline(
      String deckId, List<String> cardId) async {
    try {
      final url = Uri.parse('$cardsApi/$deckId/deleteMany');

      final json = jsonEncode(cardId);

      final res = await http.delete(url, headers: headers, body: json);

      return _handleStatusCode(res);
    } on SocketException {
      return const CrudResponse(
          error: 'No internet connection', isOnline: false);
    } catch (e) {
      return CrudResponse(error: e.toString());
    }
  }

  CrudResponse _handleStatusCode(Response res) {
    if (res.statusCode == 201) {
      return const CrudResponse();
    } else {
      return CrudResponse(error: res.body);
    }
  }

  Future<void> addDeckToSync(String deckId, Map<String, Object> deck) async {
    final query1 = 'SELECT * FROM $decksToSync WHERE id= "$deckId"';
    final query2 = 'DELETE FROM $decksToSync WHERE id = "$deckId"';

    final data = await DBHelper.rawQuery(query1);

    if (data.isEmpty) {
      await DBHelper.insert('decksToSync', deck);
      return;
    }

    if (data.isNotEmpty) {
      await DBHelper.rawQuery(query2);
    }
  }

  Future<void> addCardToSync(String cardId, Map<String, Object> card) async {
    final query1 = 'SELECT * FROM cardsToSync WHERE card_id = "$cardId"';
    final query2 = 'DELETE FROM $cardsToSync WHERE card_id = "$cardId"';

    final data = await DBHelper.rawQuery(query1);

    if (data.isEmpty) {
      await DBHelper.insert(cardsToSync, card);
      return;
    }

    if (data.isNotEmpty) {
      await DBHelper.rawQuery(query2);
    }
  }
}
