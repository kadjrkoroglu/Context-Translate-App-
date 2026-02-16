import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/viewmodels/history_viewmodel.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load history when page opens
    Future.microtask(() => context.read<HistoryViewModel>().loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inversePrimary = colorScheme.inversePrimary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: inversePrimary,
        actions: [
          Consumer<HistoryViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.historyItems.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                child: IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, size: 28),
                  onPressed: () => _showClearDialog(context, viewModel),
                  tooltip: 'Clear All',
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.historyItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 64,
                    color: inversePrimary.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: TextStyle(
                      color: inversePrimary.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: viewModel.historyItems.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = viewModel.historyItems[index];

              return Dismissible(
                key: Key(item.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => viewModel.deleteItem(item.id),
                child: Card(
                  color: colorScheme.primary,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      item.word,
                      style: TextStyle(
                        color: inversePrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        item.translation,
                        style: TextStyle(
                          color: inversePrimary.withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: inversePrimary.withValues(alpha: 0.3),
                      ),
                      onPressed: () => viewModel.deleteItem(item.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context, HistoryViewModel viewModel) {
    final inversePrimary = Theme.of(context).colorScheme.inversePrimary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: inversePrimary)),
          ),
          TextButton(
            onPressed: () {
              viewModel.clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
