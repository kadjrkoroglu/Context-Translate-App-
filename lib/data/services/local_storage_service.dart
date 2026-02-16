import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/favorite_word_model.dart';
import '../models/history_model.dart';

class LocalStorageService {
  late Isar isar;

  // Initialize database
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [FavoriteWordSchema, HistoryItemSchema], // Register both schemas
      directory: dir.path,
    );
  }

  // --- FAVORITES ---
  Future<void> addFavorite(FavoriteWord favorite) async {
    await isar.writeTxn(() async {
      await isar.favoriteWords.put(favorite);
    });
  }

  Future<List<FavoriteWord>> getAllFavorites() async {
    return await isar.favoriteWords.where().findAll();
  }

  Future<void> deleteFavorite(int id) async {
    await isar.writeTxn(() async {
      await isar.favoriteWords.delete(id);
    });
  }

  // --- HISTORY ---
  Future<void> addHistory(HistoryItem item) async {
    await isar.writeTxn(() async {
      await isar.historyItems.put(item);
    });
  }

  Future<List<HistoryItem>> getAllHistory() async {
    // Return history sorted by newest first
    return await isar.historyItems.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> deleteHistoryItem(int id) async {
    await isar.writeTxn(() async {
      await isar.historyItems.delete(id);
    });
  }

  Future<void> clearHistory() async {
    await isar.writeTxn(() async {
      await isar.historyItems.clear();
    });
  }
}
