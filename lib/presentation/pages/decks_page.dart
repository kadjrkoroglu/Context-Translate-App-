import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/viewmodels/decks_viewmodel.dart';
import 'package:translate_app/presentation/pages/deck_detail_page.dart';

class DecksPage extends StatelessWidget {
  const DecksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inversePrimary = colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Decks'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: inversePrimary,
      ),
      body: Consumer<DecksViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.decks.isEmpty) {
            return _buildEmptyState(inversePrimary);
          }

          return ListView.builder(
            itemCount: viewModel.decks.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final deck = viewModel.decks[index];
              final studyCount = viewModel.getStudyCount(deck);

              return Card(
                color: colorScheme.primary,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: inversePrimary.withValues(alpha: 0.1),
                    child: Text(
                      '${deck.orderIndex ?? (index + 1)}.',
                      style: TextStyle(
                        color: inversePrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    deck.name,
                    style: TextStyle(
                      color: inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: studyCount > 0
                          ? Colors.orange.withValues(alpha: 0.2)
                          : inversePrimary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$studyCount',
                      style: TextStyle(
                        color: studyCount > 0
                            ? Colors.orange
                            : inversePrimary.withValues(alpha: 0.6),
                        fontWeight: studyCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  onLongPress: () => _showDeckOptions(context, deck, viewModel),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeckDialog(context),
        backgroundColor: inversePrimary,
        label: const Text('New Deck'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showDeckOptions(
    BuildContext context,
    dynamic deck,
    DecksViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final inversePrimary = colorScheme.inversePrimary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          deck.name,
          textAlign: TextAlign.center,
          style: TextStyle(color: inversePrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionItem(
              context,
              icon: Icons.add_circle_outline,
              title: 'Add Card',
              onTap: () {
                Navigator.pop(context);
                _showAddCardDialog(context, deck, viewModel);
              },
            ),
            _buildOptionItem(
              context,
              icon: Icons.style_outlined,
              title: 'Browse Cards',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeckDetailPage(deck: deck),
                  ),
                );
              },
            ),
            const Divider(),
            _buildOptionItem(
              context,
              icon: Icons.delete_outline,
              title: 'Delete Deck',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirm(context, deck, viewModel);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final inversePrimary = Theme.of(context).colorScheme.inversePrimary;
    return ListTile(
      leading: Icon(icon, color: color ?? inversePrimary),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? inversePrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    dynamic deck,
    DecksViewModel viewModel,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck?'),
        content: Text(
          'Are you sure you want to delete "${deck.name}" and all its cards?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.inversePrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteDeck(deck.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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
            color: inversePrimary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first deck to start learning!',
            style: TextStyle(color: inversePrimary.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  void _showAddDeckDialog(BuildContext context) {
    final controller = TextEditingController();
    final viewModel = context.read<DecksViewModel>();
    final colorScheme = Theme.of(context).colorScheme;
    final inversePrimary = colorScheme.inversePrimary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'New Deck',
          style: TextStyle(color: inversePrimary, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: inversePrimary),
          decoration: InputDecoration(
            labelText: 'Deck Name',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(color: inversePrimary.withValues(alpha: 0.7)),
            filled: true,
            fillColor: colorScheme.primary.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: inversePrimary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await viewModel.addDeck(controller.text.trim());
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: inversePrimary,
              foregroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog(
    BuildContext context,
    dynamic deck,
    DecksViewModel viewModel,
  ) {
    final wordController = TextEditingController();
    final translationController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;
    final inversePrimary = colorScheme.inversePrimary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Add Card',
          style: TextStyle(color: inversePrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordController,
              autofocus: true,
              style: TextStyle(color: inversePrimary),
              decoration: InputDecoration(
                labelText: 'Front',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(
                  color: inversePrimary.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: colorScheme.primary.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: translationController,
              style: TextStyle(color: inversePrimary),
              decoration: InputDecoration(
                labelText: 'Back',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle: TextStyle(
                  color: inversePrimary.withValues(alpha: 0.7),
                ),
                filled: true,
                fillColor: colorScheme.primary.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: inversePrimary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (wordController.text.isNotEmpty &&
                  translationController.text.isNotEmpty) {
                await viewModel.addCard(
                  deck.id,
                  wordController.text.trim(),
                  translationController.text.trim(),
                );
                if (context.mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: inversePrimary,
              foregroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
