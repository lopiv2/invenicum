import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invenicum/data/models/scraper.dart';
import 'package:invenicum/screens/assets/local_widgets/scraper_field_chips.dart';

void main() {
  List<ScraperField> buildFields() => [
    ScraperField(id: 1, name: 'Title', xpath: '//h1', scraperId: 9),
    ScraperField(id: 2, name: 'Price', xpath: '//span', scraperId: 9),
  ];

  Future<void> pumpChips(
    WidgetTester tester, {
    required Set<int> excluded,
    required ValueChanged<int> onToggle,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScraperFieldChips(
            fields: buildFields(),
            excludedFieldIds: excluded,
            onToggleField: onToggle,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a chip toggles its exclusion', (tester) async {
    var excluded = <int>{};
    int? toggledId;
    await pumpChips(
      tester,
      excluded: excluded,
      onToggle: (id) => toggledId = id,
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.byIcon(Icons.block), findsNothing);

    Finder priceChip() =>
        find.ancestor(of: find.text('Price'), matching: find.byType(InputChip));

    await tester.tap(priceChip());
    await tester.pumpAndSettle();
    expect(toggledId, 2);

    // Rebuild with the field excluded: red state, block icon.
    excluded = {2};
    await pumpChips(tester, excluded: excluded, onToggle: (_) {});
    expect(find.byIcon(Icons.block), findsOneWidget);

    // Tapping again re-includes it.
    int? reToggledId;
    await pumpChips(
      tester,
      excluded: excluded,
      onToggle: (id) => reToggledId = id,
    );
    await tester.tap(priceChip());
    await tester.pumpAndSettle();
    expect(reToggledId, 2);

    expect(tester.takeException(), isNull);
  });
}
