import 'package:invenicum/data/models/inventory_item.dart';

class CloneBusterService {
  static ({bool isDuplicate, InventoryItem? duplicateOf, double similarityScore}) checkForDuplicates({
    required InventoryItem newItem,
    required List<InventoryItem> existingItems,
    int? excludeItemId,
  }) {
    final String newName = newItem.name.toLowerCase().trim();
    final String? newDescription = newItem.description?.toLowerCase().trim();
    final String? newBarcode = newItem.barcode?.trim();
    final String? newSerial = newItem.serialNumber?.trim();

    double highestSimilarity = 0.0;
    InventoryItem? mostSimilarItem;

    for (final existing in existingItems) {
      if (excludeItemId != null && existing.id == excludeItemId) {
        continue;
      }

      double similarity = 0.0;
      int weightSum = 0;

      final String existingName = existing.name.toLowerCase().trim();
      final int nameWeight = 40;
      weightSum += nameWeight;

      if (newName == existingName) {
        similarity += nameWeight.toDouble();
      } else {
        final nameSimilarity = _levenshteinSimilarity(newName, existingName);
        similarity += nameSimilarity * nameWeight;
      }

      if (newBarcode != null && newBarcode.isNotEmpty) {
        final int barcodeWeight = 30;
        weightSum += barcodeWeight;
        if (existing.barcode != null && existing.barcode!.trim().isNotEmpty) {
          if (newBarcode == existing.barcode!.trim()) {
            similarity += barcodeWeight.toDouble();
          }
        }
      }

      if (newSerial != null && newSerial.isNotEmpty) {
        final int serialWeight = 30;
        weightSum += serialWeight;
        if (existing.serialNumber != null && existing.serialNumber!.trim().isNotEmpty) {
          if (newSerial == existing.serialNumber!.trim()) {
            similarity += serialWeight.toDouble();
          }
        }
      }

      if (newDescription != null && newDescription.isNotEmpty) {
        final String? existingDescription = existing.description?.toLowerCase().trim();
        final int descWeight = 20;
        weightSum += descWeight;

        if (existingDescription != null && existingDescription.isNotEmpty) {
          final descSimilarity = _levenshteinSimilarity(newDescription, existingDescription);
          similarity += descSimilarity * descWeight;
        }
      }

      final Map<String, dynamic>? newCustom = newItem.customFieldValues;
      final Map<String, dynamic>? existingCustom = existing.customFieldValues;

      if (newCustom != null && existingCustom != null && newCustom.isNotEmpty) {
        final int customWeight = 10;
        weightSum += customWeight;

        int matchingFields = 0;
        int totalComparedFields = 0;

        for (final key in newCustom.keys) {
          final String newVal = newCustom[key]?.toString().toLowerCase().trim() ?? '';
          if (newVal.isEmpty) continue;

          if (existingCustom.containsKey(key)) {
            totalComparedFields++;
            final String existingVal = existingCustom[key]?.toString().toLowerCase().trim() ?? '';
            if (newVal == existingVal) {
              matchingFields++;
            }
          }
        }

        if (totalComparedFields > 0) {
          similarity += (matchingFields / totalComparedFields) * customWeight;
        }
      }

      final double normalizedScore = weightSum > 0 ? (similarity / weightSum) * 100 : 0;

      if (normalizedScore > highestSimilarity) {
        highestSimilarity = normalizedScore;
        mostSimilarItem = existing;
      }
    }

    return (
      isDuplicate: highestSimilarity >= 70.0,
      duplicateOf: highestSimilarity >= 70.0 ? mostSimilarItem : null,
      similarityScore: highestSimilarity,
    );
  }

  static double _levenshteinSimilarity(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;

    final int len1 = s1.length;
    final int len2 = s2.length;

    if (len1 == len2 && s1 == s2) return 1.0;

    final int maxLen = len1 > len2 ? len1 : len2;
    if (maxLen == 0) return 1.0;

    final int distance = _levenshteinDistance(s1, s2);
    return 1.0 - (distance / maxLen);
  }

  static int _levenshteinDistance(String s1, String s2) {
    final int len1 = s1.length;
    final int len2 = s2.length;

    if (len1 == 0) return len2;
    if (len2 == 0) return len1;

    final List<List<int>> matrix = List.generate(
      len1 + 1,
      (i) => List<int>.filled(len2 + 1, 0),
    );

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = _min3(
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        );
      }
    }

    return matrix[len1][len2];
  }

  static int _min3(int a, int b, int c) {
    int min = a;
    if (b < min) min = b;
    if (c < min) min = c;
    return min;
  }
}
