import 'package:zxzc9992/services/flashcards/sm_response.dart';

class Sm {
  SmResponse calc({
    required int quality,
    required int repetitions,
    required int previousInterval,
    required double previousEaseFactor,
  }) {
    int interval;
    double easeFactor;

    if (quality >= 3) {
      if (repetitions == 0) {
        interval = 1;
      } else if (repetitions == 1) {
        interval = 3;
      } else {
        interval = (previousInterval * previousEaseFactor).round();
      }

      repetitions++;
      easeFactor = previousEaseFactor +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    } else {
      interval = 1;
      easeFactor = previousEaseFactor;
    }

    if (easeFactor < 1.3) easeFactor = 1.3;

    final schedule =
        DateTime.now().add(Duration(days: interval)).millisecondsSinceEpoch;

    return SmResponse(
      interval: interval,
      repetitions: repetitions,
      easeFactor: easeFactor,
      schedule: schedule,
    );
  }
}
