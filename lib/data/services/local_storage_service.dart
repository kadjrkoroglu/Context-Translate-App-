import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/favorite_word_model.dart';

class LocalStorageService {
  late Isar isar;

  // Initialize database
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [FavoriteWordSchema], // from .g.dart
      directory: dir.path,
    );
  }

  // Add favorite
  Future<void> addFavorite(FavoriteWord favorite) async {
    await isar.writeTxn(() async {
      await isar.favoriteWords.put(favorite);
    });
  }

  // Fetch all favorites
  Future<List<FavoriteWord>> getAllFavorites() async {
    return await isar.favoriteWords.where().findAll();
  }

  // Delete by ID
  Future<void> deleteFavorite(int id) async {
    await isar.writeTxn(() async {
      await isar.favoriteWords.delete(id);
    });
  }
}
