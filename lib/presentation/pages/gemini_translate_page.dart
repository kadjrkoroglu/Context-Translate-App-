import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translate_app/presentation/widgets/dropdown.dart';
import 'package:translate_app/presentation/viewmodels/gemini_translate_viewmodel.dart';

class GeminiTranslatePage extends StatelessWidget {
  final TextEditingController outputController;

  const GeminiTranslatePage({super.key, required this.outputController});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<GeminiTranslateViewModel>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;
    final inversePrimary = colorScheme.inversePrimary;
    final outlineColor = colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                TextField(
                  controller: viewModel.textController,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(fontSize: 26, color: inversePrimary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: primaryColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      borderSide: BorderSide(color: outlineColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      borderSide: BorderSide(color: outlineColor),
                    ),
                    hintText: 'Enter text',
                    hintStyle: TextStyle(color: colorScheme.tertiary),
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  onChanged: (value) {
                    if (value.isEmpty) {
                      outputController.clear();
                    }
                  },
                ),
                if (viewModel.textController.text.isNotEmpty)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: inversePrimary.withValues(alpha: 0.7),
                      ),
                      onPressed: () {
                        viewModel.clear(outputController);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 55,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      LanguageDropdown(
                        value: viewModel.selectedLanguage,
                        recentLanguages: viewModel.recentLanguages,
                        showIcons: false,
                        onChanged: (value) {
                          viewModel.setSelectedLanguage(value!);
                        },
                      ),
                      if (viewModel.isListening)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mic,
                                  color: inversePrimary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Listening...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Translate Button (Middle)
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading
                        ? null
                        : () => viewModel.translate(outputController),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: inversePrimary,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: outlineColor),
                      ),
                    ),
                    child: viewModel.isLoading
                        ? Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: inversePrimary,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : const Icon(Icons.translate, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                // Tone Selector (Right)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: outlineColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: viewModel.selectedToneIndex,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                          color: inversePrimary,
                        ),
                        dropdownColor: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        selectedItemBuilder: (context) {
                          return const [
                            Center(
                              child: Text(
                                'Standard',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'Formal',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'Slang',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ];
                        },
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              'Std',
                              style: TextStyle(
                                fontSize: 15,
                                color: inversePrimary,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text(
                              'Formal',
                              style: TextStyle(
                                fontSize: 15,
                                color: inversePrimary,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text(
                              'Slang',
                              style: TextStyle(
                                fontSize: 15,
                                color: inversePrimary,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          viewModel.setSelectedToneIndex(
                            value!,
                            outputController,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (viewModel.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                viewModel.error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
