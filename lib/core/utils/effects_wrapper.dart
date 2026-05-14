import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:invenicum/core/utils/retro/retro_effects.dart';
import 'package:invenicum/providers/theme_provider.dart';
import 'package:provider/provider.dart';

/// Isolated widget that watches ThemeProvider for effects.
/// Extracted from MaterialApp.router's builder to prevent whole-router
/// rebuilds that cause GoRouter GlobalKey collisions during transitions.
class EffectsWrapper extends StatelessWidget {
  final Widget child;
  const EffectsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final effects = context.watch<ThemeProvider>().activeEffects;
    return RetroEffectsLayer(
      effects: effects,
      child: FToastBuilder()(context, child),
    );
  }
}