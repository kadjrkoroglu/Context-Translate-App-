import 'package:flutter/material.dart';
import 'package:translate_app/theme/theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final glassTheme = Theme.of(context).extension<GlassThemeExtension>();

    final colors =
        glassTheme?.backgroundGradient ??
        [
          const Color.fromARGB(255, 149, 157, 160),
          const Color.fromARGB(255, 94, 106, 121),
        ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}
