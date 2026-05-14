import 'package:flutter/material.dart';
import 'package:invenicum/core/utils/retro/cga_palette.dart';
import 'package:invenicum/core/utils/retro/ega_palette.dart';
import 'package:invenicum/core/utils/retro/retro_theme_extension.dart';

/// ============================================================================
/// RETRO THEME
/// ============================================================================
///
/// Semantic color mapping for retro rendering modes.
///
/// Widgets should NEVER hardcode palette colors directly.
/// Everything should read from this theme.
///
/// Supports:
/// - CGA
/// - EGA
/// - Future VGA / Amiga / Macintosh themes
///
/// ============================================================================

@immutable
class RetroTheme {
  // ───────────────── CORE ─────────────────

  final Color border;
  final Color titleBar;
  final Color titleText;

  final Color messageBox;
  final Color messageText;

  final Color divider;

  // ───────────────── BUTTONS ─────────────────

  final Color buttonOk;
  final Color buttonCancel;
  final Color buttonHelp;

  // ───────────────── CONTROLS ─────────────────

  final Color radioSelected;

  const RetroTheme({
    required this.border,
    required this.titleBar,
    required this.titleText,
    required this.messageBox,
    required this.messageText,
    required this.divider,
    required this.buttonOk,
    required this.buttonCancel,
    required this.buttonHelp,
    required this.radioSelected,
  });

  // ==========================================================================
  // CGA THEME
  // ==========================================================================

  static const cga = RetroTheme(
    border: CGA.brightCyan,
    titleBar: CGA.blue,
    titleText: CGA.yellow,

    messageBox: CGA.black,
    messageText: CGA.white,

    divider: CGA.darkGray,

    buttonOk: CGA.brightGreen,
    buttonCancel: CGA.brightRed,
    buttonHelp: CGA.yellow,

    radioSelected: CGA.brightGreen,
  );

  // ==========================================================================
  // EGA THEME
  // ==========================================================================

  static const ega = RetroTheme(
    border: EGA.cyan,
    titleBar: EGA.purple,
    titleText: EGA.white,

    messageBox: EGA.black,
    messageText: EGA.lightGray,

    divider: EGA.darkGray,

    buttonOk: EGA.lime,
    buttonCancel: EGA.red,
    buttonHelp: EGA.yellow,

    radioSelected: EGA.lime,
  );

  static const scummCrt = RetroTheme(
    border: CGA.brightCyan,
    titleBar: CGA.blue,
    titleText: CGA.yellow,
    messageBox: CGA.black,
    messageText: CGA.white,
    divider: CGA.darkGray,
    buttonOk: CGA.brightGreen,
    buttonCancel: CGA.brightRed,
    buttonHelp: CGA.yellow,
    radioSelected: CGA.brightGreen,
  );

  // ==========================================================================
  // PIP-BOY 3000 THEME
  // ==========================================================================

  static const _pipboyGreen = Color(0xFF00FF41);
  static const _pipboyAmber = Color(0xFFFF8800);
  static const _pipboyLime = Color(0xFF88FF00);
  static const _pipboyBrightGreen = Color(0xFF33FF66);

  static const pipboy3000 = RetroTheme(
    border: _pipboyGreen,
    titleBar: Color(0xFF003300),
    titleText: _pipboyGreen,
    messageBox: Color(0xFF001800),
    messageText: _pipboyBrightGreen,
    divider: Color(0xFF004400),
    buttonOk: _pipboyGreen,
    buttonCancel: _pipboyAmber,
    buttonHelp: _pipboyLime,
    radioSelected: _pipboyGreen,
  );

  // ==========================================================================
  // THEME DATA
  // ==========================================================================

  ThemeData toThemeData() {
    final scheme = ColorScheme.dark(
      primary: border,
      secondary: titleText,
      surface: messageBox,

      onPrimary: titleText,
      onSecondary: Colors.black,
      onSurface: messageText,
    );

    return ThemeData(
      useMaterial3: true,

      // ───────────────── EXTENSIONS ─────────────────
      extensions: [RetroThemeExtension(this)],

      // ───────────────── CORE ─────────────────
      brightness: Brightness.dark,

      fontFamily: 'IBMPlexMono',

      colorScheme: scheme,

      scaffoldBackgroundColor: Colors.black,

      canvasColor: Colors.black,

      splashColor: border.withValues(alpha: 0.15),

      highlightColor: border.withValues(alpha: 0.08),

      hoverColor: border.withValues(alpha: 0.08),

      disabledColor: divider,

      // ───────────────── APP BAR ─────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: titleBar,
        foregroundColor: titleText,
        elevation: 0,
        centerTitle: true,

        titleTextStyle: TextStyle(
          color: titleText,
          fontFamily: 'monospace',
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),

        iconTheme: IconThemeData(color: titleText),
      ),

      // ───────────────── CARD ─────────────────
      cardTheme: CardThemeData(
        color: messageBox,
        elevation: 0,
        margin: const EdgeInsets.all(4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: border, width: 1),
        ),
      ),

      // ───────────────── DIALOG ─────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: messageBox,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: border, width: 1),
        ),

        titleTextStyle: TextStyle(
          color: titleText,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),

        contentTextStyle: TextStyle(
          color: messageText,
          fontFamily: 'monospace',
          fontSize: 12,
        ),
      ),

      // ───────────────── DIVIDER ─────────────────
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),

      // ───────────────── LIST TILE ─────────────────
      listTileTheme: ListTileThemeData(
        textColor: messageText,
        iconColor: border,
        tileColor: Colors.transparent,
        selectedTileColor: border.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // ───────────────── ICONS ─────────────────
      iconTheme: IconThemeData(color: border, size: 20),

      // ───────────────── SWITCH ─────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? buttonOk : divider;
        }),

        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? buttonOk.withValues(alpha: 0.35)
              : Colors.black;
        }),

        trackOutlineColor: WidgetStateProperty.all(border),
      ),

      // ───────────────── CHECKBOX ─────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? buttonOk
              : Colors.black;
        }),

        checkColor: WidgetStateProperty.all(Colors.black),

        side: BorderSide(color: border, width: 1),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      // ───────────────── RADIO ─────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(radioSelected),
      ),

      // ───────────────── BUTTONS ─────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,

          backgroundColor: Colors.black,

          foregroundColor: buttonOk,

          disabledBackgroundColor: Colors.black,

          disabledForegroundColor: divider,

          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: border, width: 1),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: titleText,
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ───────────────── INPUTS ─────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: Colors.black,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),

        hintStyle: TextStyle(color: divider, fontFamily: 'monospace'),

        labelStyle: TextStyle(color: titleText, fontFamily: 'monospace'),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: titleText, width: 2),
        ),
      ),

      // ───────────────── SNACKBAR ─────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black,

        contentTextStyle: TextStyle(
          color: messageText,
          fontFamily: 'monospace',
          fontSize: 12,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: border),
        ),

        behavior: SnackBarBehavior.floating,
      ),

      // ───────────────── BOTTOM SHEET ─────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: messageBox,

        elevation: 0,

        modalBackgroundColor: messageBox,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: border),
        ),
      ),

      // ───────────────── POPUP MENU ─────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: messageBox,

        elevation: 0,

        textStyle: TextStyle(color: messageText, fontFamily: 'monospace'),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: border),
        ),
      ),

      // ───────────────── TEXT SELECTION ─────────────────
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: titleText,
        selectionColor: border.withValues(alpha: 0.35),
        selectionHandleColor: titleText,
      ),

      // ───────────────── TEXT ─────────────────
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: messageText,
          fontFamily: 'monospace',
          fontSize: 14,
          height: 1.4,
        ),

        bodyMedium: TextStyle(
          color: messageText,
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.4,
        ),

        bodySmall: TextStyle(
          color: messageText,
          fontFamily: 'monospace',
          fontSize: 11,
        ),

        titleLarge: TextStyle(
          color: titleText,
          fontFamily: 'monospace',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),

        titleMedium: TextStyle(
          color: titleText,
          fontFamily: 'monospace',
          fontSize: 14,
          letterSpacing: 1.5,
        ),

        labelLarge: TextStyle(
          color: titleText,
          fontFamily: 'monospace',
          fontSize: 12,
          letterSpacing: 1,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
