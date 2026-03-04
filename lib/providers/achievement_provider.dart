import 'package:flutter/material.dart';
import 'package:invenicum/data/models/achievements_model.dart';
import 'package:invenicum/data/services/achievements_service.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:intl/intl.dart';

class AchievementProvider with ChangeNotifier {
  final AchievementService _service;

  List<AchievementDefinition> _achievements = [];
  bool _isLoading = false;

  AchievementProvider(this._service);

  // --- Getters ---
  List<AchievementDefinition> get achievements => _achievements;
  bool get isLoading => _isLoading;
  int get unlockedCount => _achievements.where((a) => a.unlocked).length;
  
  double get progressPercentage => _achievements.isEmpty 
      ? 0 
      : (unlockedCount / _achievements.length);

  /// Carga los logros del servidor y los fusiona con las constantes locales
  Future<void> fetchAchievements(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Obtener el progreso del usuario desde el servidor
      // Se espera una lista de: {"id": "1", "unlocked": true, "unlockedAt": "2024..."}
      final List<Map<String, dynamic>> serverData = await _service.getAchievements();

      // 2. Obtener las definiciones constantes (donde están tus IconData y textos)
      final staticDefs = AppAchievements.getDefinitions(context);

      // 3. Fusionar ambos mundos
      _achievements = staticDefs.map((staticDef) {
        // Buscamos si el servidor tiene info de este logro específico
        final serverMatch = serverData.firstWhere(
          (s) => s['id'].toString() == staticDef.id,
          orElse: () => {},
        );

        // Retornamos la definición completa con el estado de desbloqueo real
        return AchievementDefinition(
          id: staticDef.id,
          title: staticDef.title,
          desc: staticDef.desc,
          icon: staticDef.icon, // IconData directo de la constante
          category: staticDef.category,
          isLegendary: staticDef.isLegendary,
          unlocked: serverMatch['unlocked'] ?? false,
          unlockedAt: serverMatch['unlockedAt'] != null 
              ? DateTime.parse(serverMatch['unlockedAt']) 
              : null,
        );
      }).toList();

    } catch (e) {
      debugPrint('--- Error AchievementProvider ---');
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper para formatear la fecha de desbloqueo de forma bonita
  String getFormattedDate(String achievementId) {
    try {
      final ach = _achievements.firstWhere((a) => a.id == achievementId);
      if (ach.unlockedAt == null) return '';
      
      // Ejemplo: "24 Feb. 2024"
      return DateFormat.yMMMd().format(ach.unlockedAt!);
    } catch (e) {
      return '';
    }
  }

  /// Método para disparar una verificación manual (opcional)
  Future<void> checkAchievementsStatus(BuildContext context) async {
    // Útil si el usuario acaba de realizar una acción y queremos refrescar
    await fetchAchievements(context);
  }
}