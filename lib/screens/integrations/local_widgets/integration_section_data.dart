import 'package:flutter/material.dart';
import 'package:invenicum/data/models/integration_field_type.dart';

class IntegrationSectionData {
  const IntegrationSectionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.integrations,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<IntegrationModel> integrations;
}
