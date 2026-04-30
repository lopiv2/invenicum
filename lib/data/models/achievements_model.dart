import 'package:flutter/material.dart';

class AchievementDefinition {
  final String id;
  final String title;
  final String desc;
  final IconData icon;
  final String category;
  final bool isLegendary;
  final bool unlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int? requiredValue;

  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.desc,
    required this.icon,
    this.category = 'general',
    this.isLegendary = false,
    this.unlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.requiredValue,
  });

  factory AchievementDefinition.fromJson(Map<String, dynamic> json) {
    return AchievementDefinition(
      id: json['id'].toString(),
      title: json['title'],
      desc: json['desc'],
      unlocked: json['unlocked'] ?? false,
      icon: json['iconName'] ?? 'help_outline',
      category: json['category'] ?? 'general',
      isLegendary: json['isLegendary'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
      progress: json['progress'] ?? 0,
      requiredValue: json['requiredValue'],
    );
  }
}
