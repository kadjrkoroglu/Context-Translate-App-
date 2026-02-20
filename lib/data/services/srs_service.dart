import '../models/card_model.dart';

enum StudyRating { again, hard, good, easy }

class SRSService {
  static CardItem calculateNextReview(CardItem card, StudyRating rating) {
    int level = card.level;
    DateTime now = DateTime.now();
    DateTime nextReview;

    switch (rating) {
      case StudyRating.again:
        level = 0;
        nextReview = now;
        break;
      case StudyRating.hard:
        level = (level - 1).clamp(0, 10);
        nextReview = now.add(const Duration(days: 1));
        break;
      case StudyRating.good:
        level = (level + 1).clamp(0, 10);
        nextReview = now.add(Duration(days: _getIntervalForLevel(level)));
        break;
      case StudyRating.easy:
        level = (level + 2).clamp(0, 10);
        nextReview = now.add(Duration(days: _getIntervalForLevel(level) * 2));
        break;
    }

    card.level = level;
    card.nextReviewDate = nextReview;
    card.lastRatingIndex = rating.index;
    return card;
  }

  static int _getIntervalForLevel(int level) {
    final intervals = [1, 3, 7, 14, 30, 60, 90, 180, 365, 730, 1460];
    if (level < intervals.length) {
      return intervals[level];
    }
    return intervals.last;
  }

  static String getRatingLabel(StudyRating rating) {
    switch (rating) {
      case StudyRating.again:
        return 'AGAIN';
      case StudyRating.good:
        return 'GOOD';
      case StudyRating.easy:
        return 'EASY';
      case StudyRating.hard:
        return 'HARD';
    }
  }

  static StudyRating? getRatingFromIndex(int? index) {
    if (index == null) return null;
    if (index < 0 || index >= StudyRating.values.length) return null;
    return StudyRating.values[index];
  }
}
