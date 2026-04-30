import 'package:flutter/material.dart';
import 'package:invenicum/data/models/achievements_model.dart';
import 'package:invenicum/data/services/achievements_service.dart';
import 'package:invenicum/core/utils/constants.dart';

class AchievementProvider with ChangeNotifier {
  final AchievementService _service;
  AchievementProvider(this._service);

  List<AchievementDefinition> _achievements = [];
  bool _isLoading = false;

  List<AchievementDefinition> get achievements => _achievements;
  bool get isLoading => _isLoading;
  int get unlockedCount => _achievements.where((a) => a.unlocked).length;
  double get progressPercentage =>
      _achievements.isEmpty ? 0 : unlockedCount / _achievements.length;

  Future<void> fetchAchievements(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final serverData = await _service.getAchievements();
      final staticDefs = AppAchievements.getDefinitions(context);
      final map = {for (final s in serverData) s['id'].toString(): s};

      _achievements = staticDefs.map((def) {
        final s = map[def.id] ?? {};
        return AchievementDefinition(
          id: def.id,
          title: def.title,
          desc: def.desc,
          icon: def.icon,
          category: def.category,
          isLegendary: def.isLegendary,
          unlocked: s['unlocked'] ?? false,
          progress: s['progress'] ?? 0,
          requiredValue: s['requiredValue'],
          unlockedAt: s['unlockedAt'] != null
              ? DateTime.tryParse(s['unlockedAt'])
              : null,
        );
      }).toList();
    } catch (e) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Llama a esto después de cualquier acción que pueda desbloquear logros.
  /// Devuelve la lista de logros recién desbloqueados para mostrar el toast.
  Future<List<AchievementDefinition>> trackEvent(
    BuildContext context,
    String type, {
    int value = 1,
    Map<String, dynamic>? metadata,
  }) async {
    final newUnlocks = await _service.processEvent(
      type,
      value: value,
      metadata: metadata,
    );
    if (newUnlocks.isEmpty) {
      return [];
    }

    // Actualizar estado local sin refetch completo
    final staticDefs = AppAchievements.getDefinitions(context);
    final unlockedIds = newUnlocks.map((u) => u['id'].toString()).toSet();

    _achievements = _achievements.map((a) {
      if (!unlockedIds.contains(a.id)) return a;
      return AchievementDefinition(
        id: a.id,
        title: a.title,
        desc: a.desc,
        icon: a.icon,
        category: a.category,
        isLegendary: a.isLegendary,
        unlocked: true,
        unlockedAt: DateTime.now(),
        progress: a.requiredValue ?? 1,
        requiredValue: a.requiredValue,
      );
    }).toList();

    notifyListeners();
    // Devolver las definiciones completas (con IconData) de los desbloqueados
    return staticDefs
        .where((def) => unlockedIds.contains(def.id))
        .map(
          (def) => AchievementDefinition(
            id: def.id,
            title: def.title,
            desc: def.desc,
            icon: def.icon,
            category: def.category,
            isLegendary: def.isLegendary,
            unlocked: true,
            unlockedAt: DateTime.now(),
          ),
        )
        .toList();
  }
}
