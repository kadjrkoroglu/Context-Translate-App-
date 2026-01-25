import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const LanguageDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  static const List<String> languages = [
    'İngilizce',
    'Almanca',
    'Fransızca',
    'İspanyolca',
    'İtalyanca',
    'Rusça',
    'Japonca',
    'Çince',
    'Korece',
    'Arapça',
    'Portekizce',
    'Hintçe',
    'Urduca',
    'Farsça',
    'Hollandaca',
    'İsveççe',
    'Norveççe',
    'Danca',
    'Fince',
    'Lehçe',
    'Yunanca',
    'İbranice',
    'Türkçe',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: colorScheme.primary),
    );

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(splashColor: colorScheme.inversePrimary.withOpacity(0.2)),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        iconEnabledColor: colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(16),
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.primary,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          prefixIcon: Icon(
            Icons.language,
            size: 20,
            color: colorScheme.inversePrimary,
          ),
        ),
        items: languages
            .map(
              (lang) => DropdownMenuItem(
                value: lang,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    lang,
                    style: TextStyle(
                      color: colorScheme.inversePrimary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
