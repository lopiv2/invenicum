import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invenicum/data/services/api_service.dart';
import 'package:invenicum/data/services/asset_print_service.dart';
import 'package:invenicum/data/services/asset_type_service.dart';
import 'package:invenicum/data/services/container_service.dart';
import 'package:invenicum/data/services/inventory_item_service.dart';
import 'package:invenicum/data/services/location_service.dart';
import 'package:invenicum/data/services/preferences_service.dart';
import 'package:invenicum/data/services/scraper_service.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/providers/container_provider.dart';
import 'package:invenicum/providers/inventory_item_provider.dart';
import 'package:invenicum/providers/preferences_provider.dart';
import 'package:invenicum/screens/home/local_widgets/charts/market_value_evolution_chart.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('market value chart does not overflow on mobile width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = ApiService();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => PreferencesProvider(PreferencesService(api)),
            ),
            ChangeNotifierProvider(
              create: (_) => ContainerProvider(
                ContainerService(api),
                AssetTypeService(api),
                LocationService(api),
                ScraperService(api),
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => InventoryItemProvider(
                InventoryItemService(api),
                // ignore: avoid_redundant_argument_values
                AssetPrintService(api),
              ),
            ),
          ],
          child: const Scaffold(
            body: SingleChildScrollView(child: MarketValueEvolutionChart()),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
