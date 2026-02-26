import 'package:flutter/material.dart';

class GlassThemeExtension extends ThemeExtension<GlassThemeExtension> {
  final Color baseGlassColor;
  final Color borderGlassColor;
  final List<Color> backgroundGradient;
  final List<Color> micGradient;

  GlassThemeExtension({
    required this.baseGlassColor,
    required this.borderGlassColor,
    required this.backgroundGradient,
    required this.micGradient,
  });

  @override
  GlassThemeExtension copyWith({
    Color? baseGlassColor,
    Color? borderGlassColor,
    List<Color>? backgroundGradient,
    List<Color>? micGradient,
  }) {
    return GlassThemeExtension(
      baseGlassColor: baseGlassColor ?? this.baseGlassColor,
      borderGlassColor: borderGlassColor ?? this.borderGlassColor,
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      micGradient: micGradient ?? this.micGradient,
    );
  }

  @override
  GlassThemeExtension lerp(
    ThemeExtension<GlassThemeExtension>? other,
    double t,
  ) {
    if (other is! GlassThemeExtension) return this;
    return GlassThemeExtension(
      baseGlassColor: Color.lerp(baseGlassColor, other.baseGlassColor, t)!,
      borderGlassColor: Color.lerp(
        borderGlassColor,
        other.borderGlassColor,
        t,
      )!,
      backgroundGradient: [
        Color.lerp(backgroundGradient[0], other.backgroundGradient[0], t)!,
        Color.lerp(backgroundGradient[1], other.backgroundGradient[1], t)!,
      ],
      micGradient: [
        Color.lerp(micGradient[0], other.micGradient[0], t)!,
        Color.lerp(micGradient[1], other.micGradient[1], t)!,
      ],
    );
  }
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade200,
    primary: Colors.grey.shade300,
    secondary: Colors.grey.shade400,
    tertiary: Colors.grey.shade600,
    surfaceContainer: Colors.black,
    inversePrimary: Colors.white,
    outline: Colors.black,
  ),
  extensions: [
    GlassThemeExtension(
      baseGlassColor: Colors.white.withValues(alpha: 0.1),
      borderGlassColor: Colors.white.withValues(alpha: 0.15),
      backgroundGradient: [
        const Color.fromARGB(255, 149, 157, 160),
        const Color.fromARGB(255, 94, 106, 121),
      ],
      micGradient: [
        const Color(0xFF89979D),
        const Color.fromARGB(255, 94, 106, 121),
      ],
    ),
  ],
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionColor: Colors.black26,
    selectionHandleColor: Colors.black,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: const Color.fromARGB(255, 27, 27, 27),
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade700,
    tertiary: Colors.grey.shade600,
    surfaceContainer: Colors.grey.shade700,
    inversePrimary: Colors.white70,
    outline: const Color.fromARGB(255, 27, 27, 27),
  ),
  extensions: [
    GlassThemeExtension(
      baseGlassColor: Colors.black.withValues(alpha: 0.15),
      borderGlassColor: Colors.white.withValues(alpha: 0.05),
      backgroundGradient: [
        const Color.fromARGB(255, 45, 52, 54),
        const Color.fromARGB(255, 29, 34, 40),
      ],
      micGradient: [
        const Color(0xFF454D50),
        const Color.fromARGB(255, 29, 34, 40),
      ],
    ),
  ],
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
    selectionColor: Colors.white24,
    selectionHandleColor: Colors.white,
  ),
);
