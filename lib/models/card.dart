import 'dart:io';

class CardModel {
  String id;
  String deckId;
  int lastUpdated;
  String front;
  String back;

  File? frontImg;
  File? backImg;

  // Properties below are not stored in online database 

  // Currently grade determines if cards is new. In future it can be used also to other things.
  // Grades are represented by numbers: 0 - new, 1 - played.
  int grade;

  // Schedule determines date of review of card.
  int schedule;

  // These 3 properties dictate knowledge of cards. Default values shuld be in order: 0, 0, 2.5.
  int interval;
  int repetitions;
  double easeFactor;

  // This is helper property used in flashcards review.
  int currentRepetition;

  CardModel({
    required this.id,
    required this.deckId,
    required this.lastUpdated,
    required this.front,
    required this.back,
    this.frontImg,
    this.backImg,
    this.grade = 0,
    required this.schedule,
    this.interval = 0,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.currentRepetition = 0,
  });

  CardModel copyWith({
    String? id,
    String? deckId,
    int? lastUpdated,
    String? front,
    String? back,
    File? frontImg,
    File? backImg,
    int? grade,
    int? schedule,
    int? interval,
    int? repetitions,
    double? easeFactor,
    int? currentRepetition,
  }) =>
      CardModel(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        front: front ?? this.front,
        back: back ?? this.back,
        frontImg: frontImg ?? this.frontImg,
        backImg: backImg ?? this.backImg,
        grade: grade ?? this.grade,
        schedule: schedule ?? this.schedule,
        interval: interval ?? this.interval,
        repetitions: repetitions ?? this.repetitions,
        easeFactor: easeFactor ?? this.easeFactor,
        currentRepetition: currentRepetition ?? this.currentRepetition,
      );

  @override
  String toString() {
    return "CardModel(id: $id, deckId: $deckId, lu: $lastUpdated, front: $front, back: $back, frontImg: $frontImg, backImg: $backImg grade: $grade, schedule: $schedule, int: $interval, rep: $repetitions, ef: $easeFactor)";
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "lastUpdated": lastUpdated,
        "front": front,
        "back": back,
      };
}
