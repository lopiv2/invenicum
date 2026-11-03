import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invenicum/core/utils/constants.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/assets/local_widgets/status_section_widget.dart';

void main() {
  testWidgets('manual market value field shows full value and currency', (
    tester,
  ) async {
    final controller = TextEditingController(text: '1234.56');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatusSectionWidget(
              selectedCondition: ItemCondition.mint,
              onConditionChanged: (_) {},
              marketValueController: controller,
              currencyLabel: 'EUR',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1234.56'), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
