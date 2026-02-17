import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:translate_app/data/models/deck_model.dart';
import 'package:translate_app/presentation/viewmodels/decks_viewmodel.dart';

class DeckDetailPage extends StatelessWidget {
  final DeckItem deck;

  const DeckDetailPage({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inversePrimary = colorScheme.inversePrimary;

    final cardsList = deck.cards.toList();
    cardsList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(deck.name),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: inversePrimary,
        actions: [
          Consumer<DecksViewModel>(
            builder: (context, viewModel, child) {
              final currentDeck = viewModel.decks.firstWhere(
                (d) => d.id == deck.id,
                orElse: () => deck,
              );
              final count = currentDeck.cards.length;
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    '$count cards',
                    style: TextStyle(
                      color: inversePrimary.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<DecksViewModel>(
        builder: (context, viewModel, child) {
          final currentDeck = viewModel.decks.firstWhere(
            (d) => d.id == deck.id,
            orElse: () => deck,
          );
          final cardsList = currentDeck.cards.toList();
          cardsList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          if (cardsList.isEmpty) {
            return _buildEmptyState(inversePrimary);
          }

          return ListView.separated(
            itemCount: cardsList.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: inversePrimary.withValues(alpha: 0.1),
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final card = cardsList[index];
              final dateStr = DateFormat('dd.MM.yy').format(card.createdAt);

              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: SizedBox(
                  width: 30,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: inversePrimary.withValues(alpha: 0.5),
                      fontSize: 13,
                    ),
                  ),
                ),
                title: Text(
                  card.word,
                  style: TextStyle(
                    color: inversePrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Text(
                  dateStr,
                  style: TextStyle(
                    color: inversePrimary.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Color inversePrimary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 64,
            color: inversePrimary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards yet',
            style: TextStyle(color: inversePrimary.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}
