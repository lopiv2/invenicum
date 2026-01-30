// lib/models/custom_theme_model.dart
import 'package:flutter/material.dart';

class CustomTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Brightness brightness;

  CustomTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    this.brightness = Brightness.light,
  });

  // Para guardar en SharedPreferences
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'primaryColor': primaryColor.value,
    'brightness': brightness == Brightness.light ? 'light' : 'dark',
  };

  factory CustomTheme.fromJson(Map<String, dynamic> json) => CustomTheme(
    id: json['id'],
    name: json['name'],
    primaryColor: Color(json['primaryColor']),
    brightness: json['brightness'] == 'light' ? Brightness.light : Brightness.dark,
  );
}