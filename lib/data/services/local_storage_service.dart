import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/favorite_word_model.dart';
import '../models/history_model.dart';
import '../models/card_model.dart';
import '../models/deck_model.dart';

class LocalStorageService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        FavoriteWordSchema,
        HistoryItemSchema,
        CardItemSchema,
        DeckItemSchema,
      ], // Register all schemas
      directory: dir.path,
    );
  }

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

  Future<List<DeckItem>> getAllDecks() async {
    return await isar.deckItems.where().sortByCreatedAtDesc().findAll();
  }

  Future<void> saveDeck(DeckItem deck) async {
    await isar.writeTxn(() async {
      await isar.deckItems.put(deck);
    });
  }

  Future<void> deleteDeck(int id) async {
    await isar.writeTxn(() async {
      final deck = await isar.deckItems.get(id);
      if (deck != null) {
        // Delete all cards in the deck too
        final cardsToDelete = deck.cards.toList();
        for (final card in cardsToDelete) {
          await isar.cardItems.delete(card.id);
        }
        await isar.deckItems.delete(id);
      }
    });
  }

  Future<void> addCardToDeck(int deckId, CardItem card) async {
    await isar.writeTxn(() async {
      await isar.cardItems.put(card);
      final deck = await isar.deckItems.get(deckId);
      if (deck != null) {
        deck.cards.add(card);
        await deck.cards.save();
      }
    });
  }

  Future<void> deleteCard(int cardId) async {
    await isar.writeTxn(() async {
      await isar.cardItems.delete(cardId);
    });
  }
}
