import 'package:flutter/material.dart';
import '../../data/models/card_model.dart';
import '../../data/models/deck_model.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/srs_service.dart';

class StudyViewModel extends ChangeNotifier {
  final LocalStorageService _storageService;
  final DeckItem deck;

  List<CardItem> _dueCards = [];
  int _currentIndex = 0;
  bool _isAnswerVisible = false;
  bool _isFinished = false;
  bool _isLoading = true;

  StudyViewModel(this._storageService, this.deck) {
    _initializeStudySession();
  }

  List<CardItem> get dueCards => _dueCards;
  CardItem? get currentCard =>
      _dueCards.isNotEmpty && _currentIndex < _dueCards.length
      ? _dueCards[_currentIndex]
      : null;
  int get currentIndex => _currentIndex;
  bool get isAnswerVisible => _isAnswerVisible;
  bool get isFinished => _isFinished;
  bool get isLoading => _isLoading;
  double get progress =>
      _dueCards.isEmpty ? 1.0 : (_currentIndex + 1) / _dueCards.length;

  Future<void> _initializeStudySession() async {
    _isLoading = true;
    notifyListeners();

    try {
      await deck.cards.load();
      final now = DateTime.now();
      final allCards = deck.cards.toList();

      _dueCards = allCards.where((card) {
        if (card.nextReviewDate == null) return true;
        return card.nextReviewDate!.isBefore(now) ||
            card.nextReviewDate!.isAtSameMomentAs(now);
      }).toList();

      // Sort: new cards first, then by nextReviewDate
      _dueCards.sort((a, b) {
        if (a.nextReviewDate == null && b.nextReviewDate == null) return 0;
        if (a.nextReviewDate == null) return -1;
        if (b.nextReviewDate == null) return 1;
        return a.nextReviewDate!.compareTo(b.nextReviewDate!);
      });

      if (_dueCards.isEmpty) {
        _isFinished = true;
      }
    } catch (e) {
      debugPrint("Error initializing study session: $e");
      _isFinished = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void showAnswer() {
    _isAnswerVisible = true;
    notifyListeners();
  }

  Future<void> rateCard(StudyRating rating) async {
    if (currentCard == null) return;

    final updatedCard = SRSService.calculateNextReview(currentCard!, rating);
    await _storageService.updateCard(updatedCard);

    _isAnswerVisible = false;
    _currentIndex++;

    if (_currentIndex >= _dueCards.length) {
      _isFinished = true;
    }

    notifyListeners();
  }
}
