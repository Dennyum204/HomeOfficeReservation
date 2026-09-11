import 'package:flutter/material.dart';

import 'theme_tokens.dart';

ThemeData appTheme(Brightness brightness) {
  final t = ThemeTokens(brightness == Brightness.dark);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: t.primary,
        brightness: brightness,
      ).copyWith(
        primary: t.primary,
        onPrimary: t.primaryForeground,
        primaryContainer: t.accent,
        onPrimaryContainer: t.foreground,
        secondary: t.secondaryForeground,
        onSecondary: t.secondary,
        secondaryContainer: t.secondary,
        onSecondaryContainer: t.secondaryForeground,
        tertiary: t.info,
        onTertiary: t.infoSurface,
        tertiaryContainer: t.infoSurface,
        onTertiaryContainer: t.info,
        surface: t.surface,
        onSurface: t.foreground,
        onSurfaceVariant: t.mutedForeground,
        surfaceContainerLowest: t.background,
        surfaceContainerLow: t.surface,
        surfaceContainer: t.secondary,
        surfaceContainerHigh: t.secondary,
        surfaceContainerHighest: t.secondary,
        surfaceTint: Colors.transparent,
        outline: t.input,
        outlineVariant: t.border,
        error: t.danger,
        onError: t.dangerSurface,
        errorContainer: t.dangerSurface,
        onErrorContainer: t.danger,
        inverseSurface: t.foreground,
        onInverseSurface: t.background,
      );
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Outfit',
  );
  return base.copyWith(
    scaffoldBackgroundColor: t.background,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    appBarTheme: AppBarTheme(
      backgroundColor: t.background,
      foregroundColor: t.foreground,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: t.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: t.border),
      ),
    ),
    dividerTheme: DividerThemeData(color: t.border, space: 24),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: t.popover,
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: t.input),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: t.ring, width: 2),
      ),
      labelStyle: TextStyle(color: t.mutedForeground),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: shape,
        side: BorderSide(color: t.input),
        foregroundColor: t.foreground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: t.primary,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: t.foreground,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.surface,
      indicatorColor: t.accent,
      surfaceTintColor: Colors.transparent,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: t.surface,
      indicatorColor: t.accent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.popover,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: t.foreground,
      contentTextStyle: TextStyle(color: t.background),
    ),
  );
}
