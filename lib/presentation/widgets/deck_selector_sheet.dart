import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/viewmodels/decks_viewmodel.dart';

class DeckSelectorSheet extends StatelessWidget {
  final String word;
  final String translation;

  const DeckSelectorSheet({
    super.key,
    required this.word,
    required this.translation,
  });

  static Future<void> show(
    BuildContext context,
    String word,
    String translation,
  ) {
    return showModalBottomSheet(
      context: context,
      barrierColor: Colors.black54,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => DeckSelectorSheet(word: word, translation: translation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decksVM = Provider.of<DecksViewModel>(context);
    final cs = Theme.of(context).colorScheme;
    final ip = cs.inversePrimary;

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.0,
      maxChildSize: 0.6,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: CustomScrollView(
            controller: scrollCtrl,
            slivers: [
              _buildAppBar(ctx, cs, ip),
              if (decksVM.decks.isEmpty)
                _buildEmptyState(ip)
              else
                _buildDeckList(ctx, cs, decksVM, ip),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ColorScheme cs, Color ip) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: cs.surface,
      elevation: 0,
      toolbarHeight: 85,
      titleSpacing: 0,
      title: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ip.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Save to Deck',
                  style: TextStyle(
                    color: ip,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: ip),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color ip) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(
          'No decks found.\nCreate a deck first.',
          textAlign: TextAlign.center,
          style: TextStyle(color: ip.withValues(alpha: 0.7)),
        ),
      ),
    );
  }

  Widget _buildDeckList(
    BuildContext context,
    ColorScheme cs,
    DecksViewModel decksVM,
    Color ip,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((ctx, i) {
        final deck = decksVM.decks[i];
        return ListTile(
          leading: Icon(Icons.style_outlined, color: ip),
          title: Text(deck.name, style: TextStyle(color: ip)),
          onTap: () => _handleSave(context, cs, decksVM, deck),
        );
      }, childCount: decksVM.decks.length),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    ColorScheme cs,
    DecksViewModel decksVM,
    dynamic deck,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(
          'Save Flashcard',
          style: TextStyle(color: cs.inversePrimary),
        ),
        content: Text(
          'Save to ${deck.name}?',
          style: TextStyle(color: cs.inversePrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: cs.inversePrimary.withValues(alpha: 0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.inversePrimary,
              foregroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await decksVM.addCard(deck.id, word, translation);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
