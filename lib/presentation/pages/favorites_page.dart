import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/viewmodels/favorite_viewmodel.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    // Fetch favorites on page load
    Future.microtask(() => context.read<FavoriteViewModel>().loadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites'), centerTitle: true),
      body: Consumer<FavoriteViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          if (viewModel.favorites.isEmpty) {
            return const Center(child: Text('No favorites yet.'));
          }

          // List View
          return ListView.builder(
            itemCount: viewModel.favorites.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final favorite = viewModel.favorites[index];
              return Card(
                color: Theme.of(context).colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    favorite.word,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      favorite.translation,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.inversePrimary.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      viewModel.removeFavorite(favorite.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
