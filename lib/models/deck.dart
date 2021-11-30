import 'package:zxzc9992/models/card.dart';

class Deck {
  String id;
  int createdAt;
  int lastPlayed; // Property not stored in online database
  int lastUpdated;
  String title;
  String desc; 
  int cardsAmount; // Property not stored in online database
  //int cardsPerGame;
  List<CardModel>? cards;

  Deck({
    required this.id,
    required this.createdAt,
    required this.lastPlayed,
    required this.lastUpdated,
    required this.title,
    this.desc = '',
    this.cardsAmount = 0,
    this.cards,
    //this.cardsPerGame = 25,
  });

  Deck copyWith({
    String? id,
    int? createdAt,
    int? lastPlayed,
    int? lastUpdated,
    String? title,
    String? desc,
    int? cardsAmount,
    //int? cardsPerGame,
    List<CardModel>? cards,
  }) =>
      Deck(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        lastPlayed: lastPlayed ?? this.lastPlayed,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        title: title ?? this.title,
        desc: desc ?? this.desc,
        cardsAmount: cardsAmount ?? this.cardsAmount,
        cards: cards ?? this.cards,
        //cardsPerGame: cardsPerGame ?? this.cardsPerGame,
      );
}


