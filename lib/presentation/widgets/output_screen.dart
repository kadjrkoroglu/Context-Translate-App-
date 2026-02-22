import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/viewmodels/favorite_viewmodel.dart';
import 'package:translate_app/presentation/viewmodels/main_viewmodel.dart';
import 'package:translate_app/presentation/viewmodels/ml_translate_viewmodel.dart';
import 'package:translate_app/presentation/viewmodels/gemini_translate_viewmodel.dart';
import 'package:translate_app/presentation/widgets/deck_selector_sheet.dart';

class OutputScreen extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const OutputScreen({
    super.key,
    required this.controller,
    this.hintText = 'Translation',
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 200,
      child: AnimatedBuilder(
        animation: Listenable.merge([viewModel.pageController, controller]),
        builder: (context, _) {
          final page = viewModel.pageController.hasClients
              ? (viewModel.pageController.page ?? 0)
              : 0.0;
          final fontSize = 26 - (page * 8);

          return Stack(
            children: [
              _buildTranslationField(colorScheme, fontSize),
              if (controller.text.isNotEmpty)
                _buildActionButtons(context, viewModel, colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTranslationField(ColorScheme cs, double fontSize) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: cs.outline),
    );

    return TextField(
      controller: controller,
      readOnly: true,
      expands: true,
      maxLines: null,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(fontSize: fontSize, color: cs.inversePrimary),
      decoration: InputDecoration(
        filled: true,
        fillColor: cs.primary,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        hintText: hintText,
        hintStyle: TextStyle(color: cs.tertiary),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    MainViewModel mainVM,
    ColorScheme cs,
  ) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Row(
        children: [
          _DeckAddButton(mainVM: mainVM, translation: controller.text),
          _FavoriteButton(mainVM: mainVM, translation: controller.text),
        ],
      ),
    );
  }
}

class _DeckAddButton extends StatelessWidget {
  final MainViewModel mainVM;
  final String translation;

  const _DeckAddButton({required this.mainVM, required this.translation});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.inversePrimary.withValues(alpha: 0.7);

    return IconButton(
      onPressed: () {
        final word = mainVM.isMLPage
            ? Provider.of<MLTranslateViewModel>(
                context,
                listen: false,
              ).textController.text
            : Provider.of<GeminiTranslateViewModel>(
                context,
                listen: false,
              ).textController.text;
        DeckSelectorSheet.show(context, word, translation);
      },
      icon: Icon(Icons.library_add_outlined, color: color),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final MainViewModel mainVM;
  final String translation;

  const _FavoriteButton({required this.mainVM, required this.translation});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteViewModel>(
      builder: (context, favVM, _) {
        final mlVM = Provider.of<MLTranslateViewModel>(context, listen: false);
        final geminiVM = Provider.of<GeminiTranslateViewModel>(
          context,
          listen: false,
        );

        final word = mainVM.isMLPage
            ? mlVM.textController.text
            : geminiVM.textController.text;
        final isFav = favVM.isFavorite(word);
        final color = Theme.of(
          context,
        ).colorScheme.inversePrimary.withValues(alpha: 0.7);

        return IconButton(
          onPressed: () {
            if (word.isNotEmpty && translation.isNotEmpty) {
              favVM.toggleFavorite(word: word, translation: translation);
              if (mainVM.isMLPage) mlVM.saveHistoryNow(translation);
            }
          },
          icon: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.red : color,
          ),
        );
      },
    );
  }
}
