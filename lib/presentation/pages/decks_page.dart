import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/viewmodels/decks_viewmodel.dart';
import 'package:translate_app/presentation/pages/deck_detail_page.dart';
import 'package:translate_app/presentation/pages/study_page.dart';
import 'package:translate_app/presentation/viewmodels/study_viewmodel.dart';
import 'package:translate_app/data/services/local_storage_service.dart';

class DecksPage extends StatelessWidget {
  const DecksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ip = colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Decks'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ip,
      ),
      body: Consumer<DecksViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading)
            return const Center(child: CircularProgressIndicator());
          if (vm.decks.isEmpty) return _buildEmptyState(ip);

          return ListView.builder(
            itemCount: vm.decks.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) =>
                _DeckCard(deck: vm.decks[index], index: index, vm: vm),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeckDialog(context),
        backgroundColor: ip,
        label: const Text('New Deck'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(Color ip) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 64,
            color: ip.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Create your first deck to start learning!',
            style: TextStyle(color: ip.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }

  void _showAddDeckDialog(BuildContext context) {
    final controller = TextEditingController();
    final cs = Theme.of(context).colorScheme;
    final ip = cs.inversePrimary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'New Deck',
          style: TextStyle(color: ip, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: ip),
          decoration: InputDecoration(
            labelText: 'Deck Name',
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(color: ip.withValues(alpha: 0.7)),
            filled: true,
            fillColor: cs.primary.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ip)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await context.read<DecksViewModel>().addDeck(
                  controller.text.trim(),
                );
                if (context.mounted) Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ip,
              foregroundColor: cs.primary,
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
}

class _DeckCard extends StatelessWidget {
  final dynamic deck;
  final int index;
  final DecksViewModel vm;

  const _DeckCard({required this.deck, required this.index, required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ip = cs.inversePrimary;

    return Card(
      color: cs.primary,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: ip.withValues(alpha: 0.1),
          child: Text(
            '${deck.orderIndex ?? (index + 1)}.',
            style: TextStyle(color: ip, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          deck.name,
          style: TextStyle(
            color: ip,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: _CountBadges(counts: vm.getCardCountsByStatus(deck), ip: ip),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (ctx) =>
                    StudyViewModel(ctx.read<LocalStorageService>(), deck),
                child: const StudyPage(),
              ),
            ),
          ).then((_) => vm.loadDecks());
        },
        onLongPress: () => _showDeckOptions(context),
      ),
    );
  }

  void _showDeckOptions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ip = cs.inversePrimary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          deck.name,
          textAlign: TextAlign.center,
          style: TextStyle(color: ip, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _optionItem(ctx, Icons.add_circle_outline, 'Add Card', () {
              Navigator.pop(ctx);
              _showAddCardDialog(context);
            }),
            _optionItem(ctx, Icons.style_outlined, 'Browse Cards', () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DeckDetailPage(deck: deck)),
              );
            }),
            _optionItem(ctx, Icons.settings_outlined, 'Deck Settings', () {
              Navigator.pop(ctx);
              _showDeckSettingsDialog(context);
            }),
            const Divider(),
            _optionItem(ctx, Icons.delete_outline, 'Delete Deck', () {
              Navigator.pop(ctx);
              _showDeleteConfirm(context);
            }, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _optionItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    final ip = Theme.of(context).colorScheme.inversePrimary;
    return ListTile(
      leading: Icon(icon, color: color ?? ip),
      title: Text(
        title,
        style: TextStyle(color: color ?? ip, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    final ip = Theme.of(context).colorScheme.inversePrimary;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Deck?'),
        content: Text('Delete "${deck.name}" and all its cards?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ip)),
          ),
          TextButton(
            onPressed: () {
              vm.deleteDeck(deck.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeckSettingsDialog(BuildContext context) {
    final newCtrl = TextEditingController(text: deck.newCardsLimit.toString());
    final revCtrl = TextEditingController(text: deck.reviewsLimit.toString());
    final cs = Theme.of(context).colorScheme;
    final ip = cs.inversePrimary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Deck Settings',
          style: TextStyle(color: ip, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LimitField(
              controller: newCtrl,
              label: 'Daily New Cards Limit',
              cs: cs,
              ip: ip,
            ),
            const SizedBox(height: 16),
            _LimitField(
              controller: revCtrl,
              label: 'Daily Reviews Limit',
              cs: cs,
              ip: ip,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ip)),
          ),
          ElevatedButton(
            onPressed: () async {
              await vm.updateDeckLimits(
                deck.id,
                int.tryParse(newCtrl.text) ?? 20,
                int.tryParse(revCtrl.text) ?? 200,
              );
              if (context.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ip,
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
  }

  void _showAddCardDialog(BuildContext context) {
    final frontCtrl = TextEditingController();
    final backCtrl = TextEditingController();
    final cs = Theme.of(context).colorScheme;
    final ip = cs.inversePrimary;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Add Card',
          style: TextStyle(color: ip, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LimitField(
              controller: frontCtrl,
              label: 'Front',
              cs: cs,
              ip: ip,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            _LimitField(controller: backCtrl, label: 'Back', cs: cs, ip: ip),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: ip)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (frontCtrl.text.isNotEmpty && backCtrl.text.isNotEmpty) {
                await vm.addCard(
                  deck.id,
                  frontCtrl.text.trim(),
                  backCtrl.text.trim(),
                );
                frontCtrl.clear();
                backCtrl.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ip,
              foregroundColor: cs.primary,
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

class _LimitField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ColorScheme cs;
  final Color ip;
  final bool autofocus;

  const _LimitField({
    required this.controller,
    required this.label,
    required this.cs,
    required this.ip,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      style: TextStyle(color: ip),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TextStyle(color: ip.withValues(alpha: 0.7)),
        filled: true,
        fillColor: cs.primary.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CountBadges extends StatelessWidget {
  final Map<String, int> counts;
  final Color ip;

  const _CountBadges({required this.counts, required this.ip});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (counts['new']! > 0) _badge(counts['new']!, Colors.grey.shade400),
        const SizedBox(width: 3),
        if (counts['again']! > 0) _badge(counts['again']!, Colors.red),
        const SizedBox(width: 3),
        if (counts['hard']! > 0) _badge(counts['hard']!, Colors.orange),
        const SizedBox(width: 3),
        if (counts['good']! > 0) _badge(counts['good']!, Colors.green),
        const SizedBox(width: 3),
        if (counts['easy']! > 0) _badge(counts['easy']!, Colors.blue),
      ],
    );
  }

  Widget _badge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
