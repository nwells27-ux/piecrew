import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PieCrew's design language: a working pizzeria's internal tool, not a
/// generic SaaS dashboard. Warm dough-cream surfaces instead of stark
/// white, ink-brown text instead of pure black, and Your Pie red held in
/// reserve for things that actually deserve it — the brand mark and true
/// urgency — rather than spent on every button and link.
class PieCrewColors {
  PieCrewColors._();

  // Surfaces
  static const crust = Color(0xFFFBF3E7); // app background — warm dough
  static const crustDark = Color(0xFFF3E7D3); // recessed surfaces
  static const card = Color(0xFFFFFDF8); // raised surfaces

  // Text
  static const ink = Color(0xFF2A1E1A); // primary text
  static const inkMuted = Color(0xFF8A7B6C); // secondary text
  static const inkFaint = Color(0xFFB6A990); // tertiary / placeholder

  // Brand
  static const pie = Color(0xFFC8102E);
  static const pieDark = Color(0xFFA10D25);
  static const pieTint = Color(0xFFFBEAEA); // pale wash for badges/highlights

  // Status — deliberately not the generic Material red/green/amber
  static const basil = Color(0xFF4B7F52); // done / success
  static const basilTint = Color(0xFFE7F0E2);
  static const ember = Color(0xFFC97A2B); // attention / important
  static const emberTint = Color(0xFFFBEBD9);

  static const line = Color(0xFFE8D9C3); // hairline borders
}

/// A single top-rail stripe color is how PieCrew marks category/priority —
/// the "order ticket" motif — instead of colored card backgrounds or
/// generic rounded chips everywhere.
Color railColorForPriority(String priority) {
  switch (priority) {
    case 'urgent':
      return PieCrewColors.pie;
    case 'important':
      return PieCrewColors.ember;
    default:
      return PieCrewColors.line;
  }
}

ThemeData buildPieCrewTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
    headlineMedium: GoogleFonts.manrope(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: PieCrewColors.ink,
      letterSpacing: -0.5,
      height: 1.15,
    ),
    headlineSmall: GoogleFonts.manrope(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: PieCrewColors.ink,
      letterSpacing: -0.3,
    ),
    titleLarge: GoogleFonts.manrope(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: PieCrewColors.ink,
    ),
    titleMedium: GoogleFonts.manrope(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: PieCrewColors.ink,
    ),
    bodyLarge: GoogleFonts.manrope(fontSize: 15, color: PieCrewColors.ink, height: 1.45),
    bodyMedium: GoogleFonts.manrope(fontSize: 13.5, color: PieCrewColors.ink, height: 1.45),
    bodySmall: GoogleFonts.manrope(fontSize: 12, color: PieCrewColors.inkMuted),
    labelLarge: GoogleFonts.manrope(fontWeight: FontWeight.w700, letterSpacing: 0.1),
  );

  return base.copyWith(
    scaffoldBackgroundColor: PieCrewColors.crust,
    textTheme: textTheme,
    colorScheme: base.colorScheme.copyWith(
      primary: PieCrewColors.pie,
      onPrimary: Colors.white,
      secondary: PieCrewColors.ember,
      surface: PieCrewColors.card,
      error: PieCrewColors.pie,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: PieCrewColors.pie,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.manrope(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -0.2,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: PieCrewColors.card,
      indicatorColor: PieCrewColors.pieTint,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? PieCrewColors.pie : PieCrewColors.inkMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? PieCrewColors.pie : PieCrewColors.inkMuted);
      }),
    ),
    cardTheme: CardThemeData(
      color: PieCrewColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: PieCrewColors.line, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PieCrewColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PieCrewColors.line, width: 1.4),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PieCrewColors.line, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PieCrewColors.pie, width: 1.8),
      ),
      labelStyle: GoogleFonts.manrope(color: PieCrewColors.inkMuted, fontWeight: FontWeight.w600),
      hintStyle: GoogleFonts.manrope(color: PieCrewColors.inkFaint),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PieCrewColors.pie,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PieCrewColors.pie,
        side: const BorderSide(color: PieCrewColors.pie, width: 1.4),
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 13),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PieCrewColors.pie,
        textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w700),
      ),
    ),
    dividerTheme: const DividerThemeData(color: PieCrewColors.line, thickness: 1, space: 24),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PieCrewColors.pie,
      foregroundColor: Colors.white,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? PieCrewColors.pie : null),
      trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? PieCrewColors.pieTint : null),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? PieCrewColors.pie : PieCrewColors.card),
        foregroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? Colors.white : PieCrewColors.ink),
        side: const WidgetStatePropertyAll(BorderSide(color: PieCrewColors.line)),
        textStyle: WidgetStatePropertyAll(GoogleFonts.manrope(fontWeight: FontWeight.w700, fontSize: 12.5)),
      ),
    ),
  );
}
