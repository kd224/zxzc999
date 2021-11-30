import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zxzc9992/models/card.dart';
import 'package:zxzc9992/services/crud_helper.dart';
import 'package:zxzc9992/services/flashcards/sm.dart';
import 'package:zxzc9992/services/flashcards/sm_response.dart';
import 'package:hive/hive.dart';
import 'package:zxzc9992/utils/keys.dart';

class FlashcardsProvider with ChangeNotifier {
  Sm sm = Sm();

  bool isFrontFirst = true;
  int cardsPerGame = 35;

  List<CardModel> cardsList = [];

  late CardModel currentCard;

  late int currentIndex;
  late int savedIndex;

  // Used in flashcards stats.
  List<int> reviewCount = [0, 0, 0, 0, 0, 0, 0];

  void initFlashcards(List<CardModel> cards) async {
    _loadStats();

    cardsList = [];
    cardsList = cards;

    savedIndex = Random().nextInt(cardsList.length);
    currentIndex = savedIndex;

    _randCard(isFrontFirst);
  }

  int _calcQuality(CardModel currentCard, bool isGuess) {
    int quality;

    if (!isGuess) {
      quality = 2;
      currentCard.currentRepetition++;
    } else {
      if (currentCard.repetitions == 0) {
        quality = currentCard.currentRepetition <= 0 ? 4 : 3;
      } else {
        quality = currentCard.currentRepetition <= 0 ? 5 : 3;
      }
    }

    return quality;
  }

  void _flashcardsLvlHandler(bool isGuess) {
    final currentCard = cardsList[currentIndex];

    // Calculating the new quality of cards based on guessed and unguessed cards.
    final newQuality = _calcQuality(currentCard, isGuess);

    final SmResponse smResponse = sm.calc(
      quality: newQuality,
      previousInterval: currentCard.interval,
      repetitions: currentCard.repetitions,
      previousEaseFactor: currentCard.easeFactor,
    );

    _printData(currentCard, smResponse);

    currentCard.schedule = smResponse.schedule;
    currentCard.grade = currentCard.grade++;
    currentCard.interval = smResponse.interval;
    currentCard.repetitions = smResponse.repetitions;
    currentCard.easeFactor = smResponse.easeFactor;

    final newCard = currentCard.copyWith(
      grade: currentCard.grade++,
      schedule: smResponse.schedule,
      interval: smResponse.interval,
      repetitions: smResponse.repetitions,
      easeFactor: smResponse.easeFactor,
    );

    // Update card local
    CrudHelper().insertLocalCard(newCard);

    if (isGuess) {
      cardsList.removeAt(currentIndex);
      return;
    }
  }

  int rand(bool isGuess) {
    // TODO: Review count stats
    //_persistStats();
    _flashcardsLvlHandler(isGuess);
    if (cardsList.isNotEmpty) {
      if (cardsList.length >= 3) {
        while (savedIndex == currentIndex) {
          savedIndex = Random().nextInt(cardsList.length);
        }
      } else {
        savedIndex = Random().nextInt(cardsList.length);
      }
    }
    currentIndex = savedIndex;

    _randCard(isFrontFirst);
    return currentIndex;
  }

  void _randCard(bool isFrontFirst) {
    if (cardsList.isNotEmpty) currentCard = cardsList[currentIndex];
  }

  int counter() => cardsList.length;

  String currentCardId() => cardsList[currentIndex].id;

  void undoCard() {}

  void _printData(CardModel currentCard, SmResponse smResponse) {
    print('\n');
    //print('currentRep: ${currentCard.currentRepetition}, q: $q');
    print('int: ${currentCard.interval} -> ${smResponse.interval}');
    print('rep: ${currentCard.repetitions} -> ${smResponse.repetitions}');
    print('ef: ${currentCard.easeFactor} -> ${smResponse.easeFactor}');
  }

  void _loadStats() {
    final box = Hive.box(flashcardsStatsBox);
    final data = box.get(flashcardsReviewCounterKey);
    if (data != null) {
      reviewCount = data as List<int>;
      print(data);
    }
  }

  // void _persistStats() {
  //   final weekday = DateTime.now().weekday;
  //   print(weekday);
  //   reviewCount[weekday - 1]++;
  //   print(reviewCount);

  //   final box = Hive.box(flashcardsStatsBox);
  //   box.put(flashcardsReviewCounterKey, reviewCount);
  // }
}
