import 'package:isar/isar.dart';

part 'card_model.g.dart';

@collection
class CardItem {
  Id id = Isar.autoIncrement;

  late String word;
  late String translation;
  late DateTime createdAt;

  DateTime? nextReviewDate;
  int level = 0;
}
