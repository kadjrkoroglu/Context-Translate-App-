import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/study_viewmodel.dart';
import '../../data/services/srs_service.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  int? _previousCardId;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  StudyRating? _getRatingFromOffset(Offset offset) {
    if (offset.dx.abs() < 30 && offset.dy.abs() < 30) return null;

    if (offset.dx.abs() > offset.dy.abs()) {
      // Horizontal: Left = again, Right = good
      return offset.dx < -30 ? StudyRating.again : StudyRating.good;
    } else {
      // Vertical: Up = easy, Down = hard
      return offset.dy < -30 ? StudyRating.easy : StudyRating.hard;
    }
  }

  Color _getColorForRating(StudyRating rating) {
    switch (rating) {
      case StudyRating.again:
        return Colors.red;
      case StudyRating.good:
        return Colors.green;
      case StudyRating.easy:
        return Colors.blue;
      case StudyRating.hard:
        return Colors.orange;
    }
  }

  String _getDirectionForRating(StudyRating rating) {
    switch (rating) {
      case StudyRating.again:
        return '🔴 ← AGAIN';
      case StudyRating.good:
        return '🟢 GOOD →';
      case StudyRating.easy:
        return '🔵 ↑ EASY';
      case StudyRating.hard:
        return '🟠 ↓ HARD';
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<StudyViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final inversePrimary = colorScheme.inversePrimary;

    if (viewModel.isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: inversePrimary),
        ),
        body: Center(child: CircularProgressIndicator(color: inversePrimary)),
      );
    }

    if (viewModel.isFinished) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.celebration, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                'Session Finished!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: inversePrimary,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: inversePrimary,
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back to Decks'),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = viewModel.currentCard;
    if (currentCard == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: Text(
            'No cards available',
            style: TextStyle(color: inversePrimary),
          ),
        ),
      );
    }

    // Reset animation when card changes
    if (_previousCardId != currentCard.id) {
      _flipController.animateTo(0, duration: Duration.zero);
      _previousCardId = currentCard.id;
    }

    // Trigger flip animation based on answer visibility
    if (viewModel.isAnswerVisible && _flipController.value == 0) {
      _flipController.forward();
    } else if (!viewModel.isAnswerVisible && _flipController.value == 1) {
      _flipController.reverse();
    }

    StudyRating? activeRating = _isDragging
        ? _getRatingFromOffset(_dragOffset)
        : null;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          viewModel.deck.name,
          style: TextStyle(color: inversePrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card ${viewModel.currentIndex + 1} / ${viewModel.dueCards.length}',
                      style: TextStyle(
                        color: inversePrimary.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${(viewModel.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: inversePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: viewModel.progress,
                  backgroundColor: colorScheme.primary,
                  valueColor: AlwaysStoppedAnimation<Color>(inversePrimary),
                  borderRadius: BorderRadius.circular(8),
                  minHeight: 8,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onPanStart: (_) => setState(() => _isDragging = true),
                onPanUpdate: (details) {
                  if (viewModel.isAnswerVisible) {
                    setState(() => _dragOffset += details.delta);
                  }
                },
                onPanEnd: (_) {
                  if (activeRating != null && viewModel.isAnswerVisible) {
                    viewModel.rateCard(activeRating);
                  }
                  setState(() {
                    _isDragging = false;
                    _dragOffset = Offset.zero;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Feedback Background (Shows during drag)
                    if (activeRating != null)
                      Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          color: _getColorForRating(
                            activeRating,
                          ).withValues(alpha: 0.15),
                          border: Border.all(
                            color: _getColorForRating(activeRating),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getDirectionForRating(activeRating),
                              style: TextStyle(
                                color: _getColorForRating(activeRating),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // The Card (Front/Back with flip animation)
                    Transform.translate(
                      offset: _isDragging && viewModel.isAnswerVisible
                          ? _dragOffset
                          : Offset.zero,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final angle = _flipAnimation.value;
                          final isBack = angle > pi / 2;
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: isBack
                                ? Transform(
                                    transform: Matrix4.identity()..rotateY(pi),
                                    alignment: Alignment.center,
                                    child: _buildCardContent(
                                      currentCard.translation,
                                      colorScheme.primary,
                                      inversePrimary,
                                      isBack: true,
                                    ),
                                  )
                                : _buildCardContent(
                                    currentCard.word,
                                    colorScheme.primary,
                                    inversePrimary,
                                    isBack: false,
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!viewModel.isAnswerVisible)
            Padding(
              padding: const EdgeInsets.only(bottom: 64.0),
              child: ElevatedButton.icon(
                onPressed: () => viewModel.showAnswer(),
                icon: const Icon(Icons.rotate_right_rounded),
                label: const Text('TURN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: inversePrimary,
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.only(bottom: 64.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Swipe to Rate',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '🔴 Again • 🟢 Good • 🔵 Easy • 🟠 Hard',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent(
    String text,
    Color bgColor,
    Color textColor, {
    required bool isBack,
  }) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: textColor.withValues(alpha: 0.1), width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: SingleChildScrollView(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isBack ? 28 : 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
