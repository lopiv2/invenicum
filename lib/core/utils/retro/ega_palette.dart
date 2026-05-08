import 'package:flutter/material.dart';

/// EGA palette — the 16 standard colors as used in LucasArts adventure games
/// (Monkey Island, Day of the Tentacle, etc.)
class EGA {
  EGA._();

  static const black     = Color(0xFF000000);
  static const darkBlue  = Color(0xFF0000AA);
  static const darkGreen = Color(0xFF00AA00);
  static const cyan      = Color(0xFF00AAAA);
  static const darkRed   = Color(0xFFAA0000);
  static const purple    = Color(0xFFAA00AA);
  static const brown     = Color(0xFFAA5500);
  static const lightGray = Color(0xFFAAAAAA);
  static const darkGray  = Color(0xFF555555);
  static const blue      = Color(0xFF5555FF);
  static const lime      = Color(0xFF55FF55);
  static const brightCyan= Color(0xFF55FFFF);
  static const red       = Color(0xFFFF5555);
  static const magenta   = Color(0xFFFF55FF); // ← differs from CGA
  static const yellow    = Color(0xFFFFFF55);
  static const white     = Color(0xFFFFFFFF);
}