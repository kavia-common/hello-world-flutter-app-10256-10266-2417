import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:offline_notes/app/app.dart';
import 'package:offline_notes/app/services.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await Services.init();
    await tester.pumpWidget(const OfflineNotesApp());
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsOneWidget);
  });

  testWidgets('create note shows in list', (tester) async {
    await Services.init();
    await tester.pumpWidget(const OfflineNotesApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Hello');
    await tester.enterText(find.byType(TextField).at(1), 'World');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
  });
}
