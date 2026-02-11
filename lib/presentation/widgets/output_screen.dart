import 'package:flutter/material.dart';

class OutputScreen extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double fontSize;

  const OutputScreen({
    super.key,
    required this.controller,
    this.hintText = 'Translation',
    this.fontSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    // Define border style once
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
    );

    return SizedBox(
      height: 200,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          return Stack(
            children: [
              TextField(
                controller: controller,
                readOnly: true,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: fontSize,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.primary,
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border,
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              if (controller.text.isNotEmpty)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {},
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.library_add_outlined,
                          size: 24,
                          color: Theme.of(
                            context,
                          ).colorScheme.inversePrimary.withValues(alpha: 0.6),
                        ),
                        tooltip: 'Add to Cards',
                      ),
                      IconButton(
                        onPressed: () {},
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.favorite_border,
                          size: 24,
                          color: Theme.of(
                            context,
                          ).colorScheme.inversePrimary.withValues(alpha: 0.6),
                        ),
                        tooltip: 'Favorite',
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
