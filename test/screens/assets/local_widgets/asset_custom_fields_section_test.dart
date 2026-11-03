import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/data/services/preferences_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/screens/assets/local_widgets/custom_fields_section.dart';
import 'package:provider/provider.dart';

void main() {
  List<CustomFieldDefinition> buildFields() => [
    const CustomFieldDefinition(
      id: 1,
      name: 'First',
      type: CustomFieldType.text,
    ),
    const CustomFieldDefinition(
      id: 2,
      name: 'Second',
      type: CustomFieldType.text,
    ),
    const CustomFieldDefinition(
      id: 3,
      name: 'Third',
      type: CustomFieldType.text,
    ),
  ];

  Map<int, TextEditingController> buildControllers() => {
    1: TextEditingController(),
    2: TextEditingController(),
    3: TextEditingController(),
  };

  testWidgets('asset custom fields can be reordered via drag handle', (
    tester,
  ) async {
    final current = buildFields();
    final controllers = buildControllers();
    addTearDown(() {
      for (final c in controllers.values) {
        c.dispose();
      }
    });
    final prefsProvider = PreferencesProvider(PreferencesService(ApiService()));
    addTearDown(prefsProvider.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ChangeNotifierProvider<PreferencesProvider>.value(
          value: prefsProvider,
          child: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return CustomFieldsSectionWidget(
                    containerId: '1',
                    fieldDefinitions: current,
                    customControllers: controllers,
                    listFieldValues: const {},
                    selectedListValues: const {},
                    booleanFieldValues: const {},
                    highlightedFields: const {},
                    onControllerText: (_, _) {},
                    onDropdownChanged: (_, _) {},
                    onBooleanChanged: (_, _) {},
                    onReorderFields: (oldIndex, newIndex) {
                      setState(() {
                        final field = current.removeAt(oldIndex);
                        current.insert(newIndex, field);
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    double topOf(String name) => tester.getTopLeft(find.text(name)).dy;

    // Initial order: First, Second, Third.
    expect(topOf('First') < topOf('Second'), isTrue);
    expect(topOf('Second') < topOf('Third'), isTrue);

    // Drag the first field below the second one.
    final gesture = await tester.startGesture(
      tester.getCenter(find.byIcon(Icons.drag_handle).first),
    );
    await gesture.moveBy(const Offset(0, 600));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 600));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(topOf('Second') < topOf('First'), isTrue);
    expect(tester.takeException(), isNull);
  });
}
