import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final List<String>? items;
  final List<String> recentLanguages;
  final Set<String> downloadedModels;
  final bool showIcons;
  final bool isLoading;

  const LanguageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.items,
    this.recentLanguages = const [],
    this.downloadedModels = const {},
    this.showIcons = true,
    this.isLoading = false,
  });

  static const List<String> languages = [
    'English',
    'German',
    'French',
    'Spanish',
    'Italian',
    'Russian',
    'Japanese',
    'Chinese',
    'Korean',
    'Arabic',
    'Portuguese',
    'Hindi',
    'Urdu',
    'Persian',
    'Dutch',
    'Swedish',
    'Norwegian',
    'Danish',
    'Finnish',
    'Polish',
    'Greek',
    'Hebrew',
    'Turkish',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.inversePrimary;

    // Build combined list for dropdown items without duplicates
    final List<dynamic> dropdownData = [];
    final List<String> allLangs = items ?? languages;

    if (recentLanguages.isNotEmpty && items == null) {
      dropdownData.add('RECENTS');
      dropdownData.addAll(recentLanguages);
      dropdownData.add('DIVIDER');

      dropdownData.add('ALL LANGUAGES');
      // Add languages not already in recents
      dropdownData.addAll(
        allLangs.where((lang) => !recentLanguages.contains(lang)),
      );
    } else {
      // Add all if no recents or custom items provided
      dropdownData.addAll(allLangs);
    }

    final bool isPlaceholder = value == '-';
    final String? effectiveValue = isPlaceholder ? null : value;

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(splashColor: color.withValues(alpha: 0.2)),
      child: DropdownButtonFormField<String>(
        value: effectiveValue,
        hint: isPlaceholder
            ? Center(
                child: Text(
                  '—',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              )
            : null,
        isExpanded: true,
        iconEnabledColor: color,
        borderRadius: BorderRadius.circular(16),
        dropdownColor: colorScheme.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.primary,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
        ),
        selectedItemBuilder: (context) {
          // Display for the closed dropdown state
          return dropdownData.map((data) {
            final String text = data is String ? data : '';
            return Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Text(text, style: TextStyle(color: color, fontSize: 15)),
            );
          }).toList();
        },
        items: dropdownData.map((data) {
          if (data == 'DIVIDER') {
            return DropdownMenuItem<String>(
              enabled: false,
              child: Divider(color: color.withValues(alpha: 0.2)),
            );
          }
          if (data == 'RECENTS' || data == 'ALL LANGUAGES') {
            return DropdownMenuItem<String>(
              enabled: false,
              child: Text(
                data,
                style: TextStyle(
                  color: color.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final String lang = data as String;
          final bool isDownloaded = downloadedModels.contains(lang);

          return DropdownMenuItem<String>(
            value: lang,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    lang,
                    style: TextStyle(color: color, fontSize: 15),
                  ),
                ),
                if (showIcons)
                  Icon(
                    isDownloaded ? Icons.check : Icons.file_download_outlined,
                    color: color.withValues(alpha: 0.6),
                    size: 22,
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
