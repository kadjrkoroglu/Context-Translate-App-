import 'package:flutter/material.dart';
import '../../data/models/history_model.dart';
import '../../data/services/local_storage_service.dart';

class HistoryViewModel extends ChangeNotifier {
  final LocalStorageService _storageService;

  HistoryViewModel(this._storageService);

  List<HistoryItem> _historyItems = [];
  bool _isLoading = false;

  List<HistoryItem> get historyItems => _historyItems;
  bool get isLoading => _isLoading;

  Future<void> loadHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _historyItems = await _storageService.getAllHistory();
    } catch (e) {
      debugPrint('Load history error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHistoryItem({
    required String word,
    required String translation,
  }) async {
    // If history is empty, ensure it's loaded first to check for duplicates
    if (_historyItems.isEmpty && !_isLoading) {
      await loadHistory();
    }

    // Don't save if it's the same as the last entry
    if (_historyItems.isNotEmpty) {
      final lastItem = _historyItems.first;
      if (lastItem.word.trim() == word.trim() &&
          lastItem.translation.trim() == translation.trim()) {
        return;
      }
    }

    final item = HistoryItem()
      ..word = word
      ..translation = translation
      ..createdAt = DateTime.now();

    await _storageService.addHistory(item);
    await loadHistory();
  }

  Future<void> deleteItem(int id) async {
    await _storageService.deleteHistoryItem(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await _storageService.clearHistory();
    _historyItems = [];
    notifyListeners();
  }
}
