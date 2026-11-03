import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invenicum/l10n/app_localizations.dart';
import 'package:invenicum/screens/home/local_widgets/charts/top_loaned_bar_chart_widget.dart';
import 'package:invenicum/screens/home/local_widgets/charts/top_loaned_filters.dart';

void main() {
  Future<void> pumpMobile(
    WidgetTester tester,
    Widget child, {
    double width = 360,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('loan filters do not overflow on narrow screens', (tester) async {
    await pumpMobile(
      tester,
      TopLoanedFilters(
        selectedYear: 2024,
        selectedMonth: 9,
        years: const [2023, 2024],
        onYearChanged: (_) {},
        onMonthChanged: (_) {},
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('loaned bar chart does not overflow on narrow screens', (
    tester,
  ) async {
    await pumpMobile(
      tester,
      const TopLoanedBarChartContent(
        topItems: {
          'A very long board game title here': 12,
          'Another quite long item name': 8,
          'Third item with a long name too': 5,
        },
        isDark: false,
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
