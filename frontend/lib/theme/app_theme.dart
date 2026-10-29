import 'package:flutter/material.dart';

/// Brand colors and spacing shared by the existing screens.
abstract final class AppDesign {
  static const Color navy = Color(0xFF14213D);
  static const Color amber = Color(0xFFFCA311);
  static const Color page = Color(0xFFF6F7FB);
  static const Color ink = Color(0xFF182230);
  static const double pagePadding = 20;
  static const double cardRadius = 24;
  static const double controlRadius = 18;
  static const double pillRadius = 32;
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light();
    final textTheme = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        color: AppDesign.ink,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        color: AppDesign.ink,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        color: AppDesign.ink,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        color: AppDesign.ink,
        height: 1.45,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: AppDesign.ink,
        height: 1.4,
      ),
    );
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppDesign.navy,
          brightness: Brightness.light,
        ).copyWith(
          secondary: AppDesign.amber,
          onSecondary: AppDesign.navy,
          secondaryContainer: const Color(0xFFFFEBCB),
          onSecondaryContainer: AppDesign.navy,
          tertiaryContainer: const Color(0xFFEAF2FC),
          onTertiaryContainer: AppDesign.navy,
          surface: Colors.white,
          error: const Color(0xFFBA1A1A),
        );

    return ThemeData.from(
      colorScheme: colorScheme,
      textTheme: textTheme,
      useMaterial3: true,
    ).copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppDesign.page,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppDesign.page,
        foregroundColor: AppDesign.navy,
        toolbarHeight: 68,
        titleSpacing: 20,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppDesign.navy),
        actionsIconTheme: const IconThemeData(color: AppDesign.navy),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colorScheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIconTheme: const IconThemeData(color: AppDesign.navy),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: AppDesign.navy,
          backgroundColor: Colors.white,
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: const CircleBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.controlRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.controlRadius),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.controlRadius),
          borderSide: const BorderSide(color: AppDesign.navy, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.controlRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDesign.controlRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.controlRadius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.controlRadius),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.all(4),
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x0A14213D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.cardRadius),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppDesign.navy,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.controlRadius),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppDesign.amber,
        foregroundColor: AppDesign.navy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.pillRadius),
        ),
      ),
    );
  }
}
