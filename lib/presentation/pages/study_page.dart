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
      return offset.dx < -30 ? StudyRating.again : StudyRating.good;
    } else {
      return offset.dy < -30 ? StudyRating.easy : StudyRating.hard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<StudyViewModel>(context);
    final cs = Theme.of(context).colorScheme;
    final ip = cs.inversePrimary;

    if (vm.isLoading) return _LoadingView(cs: cs, ip: ip);
    if (vm.isFinished) return _FinishedView(cs: cs, ip: ip);

    final card = vm.currentCard;
    if (card == null) return _NoCardsView(cs: cs, ip: ip);

    // Sync flip state
    if (_previousCardId != card.id) {
      _flipController.animateTo(0, duration: Duration.zero);
      _previousCardId = card.id;
    }
    if (vm.isAnswerVisible && _flipController.value == 0)
      _flipController.forward();
    else if (!vm.isAnswerVisible && _flipController.value == 1)
      _flipController.reverse();

    final activeRating = _isDragging ? _getRatingFromOffset(_dragOffset) : null;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(vm.deck.name, style: TextStyle(color: ip)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ip,
      ),
      body: Column(
        children: [
          _StudyProgressBar(
            progress: vm.progress,
            index: vm.currentIndex,
            total: vm.dueCards.length,
            ip: ip,
            cs: cs,
          ),
          Expanded(
            child: Center(
              child: GestureDetector(
                onPanStart: (_) => setState(() => _isDragging = true),
                onPanUpdate: (d) => setState(() {
                  if (vm.isAnswerVisible) _dragOffset += d.delta;
                }),
                onPanEnd: (_) {
                  if (activeRating != null && vm.isAnswerVisible)
                    vm.rateCard(activeRating);
                  setState(() {
                    _isDragging = false;
                    _dragOffset = Offset.zero;
                  });
                },
                child: _FlashcardStack(
                  activeRating: activeRating,
                  flipAnimation: _flipAnimation,
                  dragOffset: _dragOffset,
                  isDragging: _isDragging && vm.isAnswerVisible,
                  card: card,
                  cs: cs,
                  ip: ip,
                ),
              ),
            ),
          ),
          _StudyActionArea(vm: vm, ip: ip, cs: cs),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final ColorScheme cs;
  final Color ip;
  const _LoadingView({required this.cs, required this.ip});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: cs.surface,
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: BackButton(color: ip),
    ),
    body: Center(child: CircularProgressIndicator(color: ip)),
  );
}

class _FinishedView extends StatelessWidget {
  final ColorScheme cs;
  final Color ip;
  const _FinishedView({required this.cs, required this.ip});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: cs.surface,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Session Finished!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: ip,
              foregroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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

class _NoCardsView extends StatelessWidget {
  final ColorScheme cs;
  final Color ip;
  const _NoCardsView({required this.cs, required this.ip});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: cs.surface,
    body: Center(
      child: Text('No cards available', style: TextStyle(color: ip)),
    ),
  );
}

class _StudyProgressBar extends StatelessWidget {
  final double progress;
  final int index;
  final int total;
  final Color ip;
  final ColorScheme cs;

  const _StudyProgressBar({
    required this.progress,
    required this.index,
    required this.total,
    required this.ip,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Card ${index + 1} / $total',
              style: TextStyle(color: ip.withValues(alpha: 0.7), fontSize: 12),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(color: ip, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: cs.primary,
          valueColor: AlwaysStoppedAnimation<Color>(ip),
          borderRadius: BorderRadius.circular(8),
          minHeight: 8,
        ),
      ],
    ),
  );
}

class _FlashcardStack extends StatelessWidget {
  final StudyRating? activeRating;
  final Animation<double> flipAnimation;
  final Offset dragOffset;
  final bool isDragging;
  final dynamic card;
  final ColorScheme cs;
  final Color ip;

  const _FlashcardStack({
    required this.activeRating,
    required this.flipAnimation,
    required this.dragOffset,
    required this.isDragging,
    required this.card,
    required this.cs,
    required this.ip,
  });

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      if (activeRating != null) _RatingFeedback(rating: activeRating!),
      Transform.translate(
        offset: isDragging ? dragOffset : Offset.zero,
        child: AnimatedBuilder(
          animation: flipAnimation,
          builder: (context, _) {
            final angle = flipAnimation.value;
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
                      child: _CardSide(
                        text: card.translation,
                        cs: cs,
                        ip: ip,
                        isBack: true,
                      ),
                    )
                  : _CardSide(text: card.word, cs: cs, ip: ip, isBack: false),
            );
          },
        ),
      ),
    ],
  );
}

class _RatingFeedback extends StatelessWidget {
  final StudyRating rating;
  const _RatingFeedback({required this.rating});

  Color _getColor() {
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

  String _getText() {
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
  Widget build(BuildContext context) => Container(
    width: 320,
    height: 320,
    decoration: BoxDecoration(
      color: _getColor().withValues(alpha: 0.15),
      border: Border.all(color: _getColor(), width: 3),
      borderRadius: BorderRadius.circular(32),
    ),
    child: Center(
      child: Text(
        _getText(),
        style: TextStyle(
          color: _getColor(),
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    ),
  );
}

class _CardSide extends StatelessWidget {
  final String text;
  final ColorScheme cs;
  final Color ip;
  final bool isBack;
  const _CardSide({
    required this.text,
    required this.cs,
    required this.ip,
    required this.isBack,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 300,
    height: 300,
    decoration: BoxDecoration(
      color: cs.primary,
      borderRadius: BorderRadius.circular(32),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
      border: Border.all(color: ip.withValues(alpha: 0.1), width: 2),
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
            color: ip,
          ),
        ),
      ),
    ),
  );
}

class _StudyActionArea extends StatelessWidget {
  final StudyViewModel vm;
  final Color ip;
  final ColorScheme cs;
  const _StudyActionArea({
    required this.vm,
    required this.ip,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 64.0),
    child: !vm.isAnswerVisible
        ? ElevatedButton.icon(
            onPressed: () => vm.showAnswer(),
            icon: const Icon(Icons.rotate_right_rounded),
            label: const Text('TURN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ip,
              foregroundColor: cs.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          )
        : const Column(
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
  );
}
