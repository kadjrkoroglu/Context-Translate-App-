import 'package:isar/isar.dart';

part 'history_model.g.dart';

@collection
class HistoryItem {
  Id id = Isar.autoIncrement;

  late String word;
  late String translation;
  late DateTime createdAt;
}
