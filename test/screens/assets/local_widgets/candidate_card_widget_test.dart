import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invenicum/screens/assets/local_widgets/candidate_card_widget.dart';

void main() {
  testWidgets('compact candidate card wraps full title and subtitle', (
    tester,
  ) async {
    const title = 'The 7 Wonders of the World: A Very Long Board Game Title';
    const subtitle = 'Año: 2012 • Autor: Antoine Bauza';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: CandidateCard(
                candidate: {'name': title},
                subtitle: subtitle,
                isCompact: true,
              ),
            ),
          ),
        ),
      ),
    );

    final titleWidget = tester.widget<Text>(find.text(title));
    final subtitleWidget = tester.widget<Text>(find.text(subtitle));

    expect(titleWidget.maxLines, isNull);
    expect(titleWidget.overflow, isNull);
    expect(subtitleWidget.maxLines, isNull);
    expect(subtitleWidget.overflow, isNull);
    expect(tester.takeException(), isNull);
  });
}
