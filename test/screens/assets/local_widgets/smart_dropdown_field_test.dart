import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/assets/local_widgets/smart_dropdown_field.dart';

void main() {
  testWidgets('disposing with open dropdown does not throw', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AppDropdownField<String>(
            label: 'Options',
            values: const ['Alpha', 'Beta'],
            itemLabel: (v) => v,
            selectedValue: null,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open the overlay dropdown.
    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsOneWidget);

    // Dispose the whole tree while the overlay is still open.
    await tester.pumpWidget(Container());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
