import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invenicum/data/models/custom_field_definition.dart';
import 'package:invenicum/data/models/custom_field_definition_model.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/asset_types/local_widgets/asset_type_custom_fields_section.dart';

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

  testWidgets('custom fields can be reordered via drag handle', (tester) async {
    final current = buildFields();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return AssetTypeCustomFieldsSection(
                  fieldDefinitions: current,
                  availableDataLists: const [],
                  isLoading: false,
                  onAddField: () {},
                  onRemoveField: (_) {},
                  onUpdateField: (_, _) {},
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
    );
    await tester.pumpAndSettle();

    double topOf(String name) =>
        tester.getTopLeft(find.text('Campo: "$name"')).dy;

    // Initial order: First, Second, Third.
    expect(topOf('First') < topOf('Second'), isTrue);
    expect(topOf('Second') < topOf('Third'), isTrue);

    // Drag the first field below the second one.
    final handle = find.byIcon(Icons.drag_handle).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
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
