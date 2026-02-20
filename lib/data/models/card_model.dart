import 'package:isar/isar.dart';

part 'card_model.g.dart';

@collection
class CardItem {
  Id id = Isar.autoIncrement;

  late String word;
  late String translation;
  late DateTime createdAt;

  // For "study" logic
  DateTime? nextReviewDate;
  int level = 0; // For Spaced Repetition (SRS)
  int?
  lastRatingIndex; // For tracking last rating (0=again, 1=hard, 2=good, 3=easy)
}
