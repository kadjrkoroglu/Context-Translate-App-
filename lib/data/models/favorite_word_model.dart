import 'package:isar/isar.dart';

part 'favorite_word_model.g.dart';

@collection
class FavoriteWord {
  Id id = Isar.autoIncrement;

  @Index()
  late String word;

  late String translation;
  late DateTime createdAt;

  bool isSynced = false;
}
