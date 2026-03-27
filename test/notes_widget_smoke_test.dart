import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:offline_notes/app/app.dart';
import 'package:offline_notes/app/services.dart';

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 3),
  Duration step = const Duration(milliseconds: 50),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }

  throw TimeoutException('Timed out waiting for $finder');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Ensure sqflite is usable in host tests (no platform channels).
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  testWidgets('app boots', (tester) async {
    await Services.init();
    await tester.pumpWidget(const OfflineNotesApp());

    // Avoid pumpAndSettle() hangs due to ongoing timers/streams.
    await _pumpUntilFound(tester, find.text('Notes'));

    expect(find.text('Notes'), findsOneWidget);
  });

  testWidgets('create note shows in list', (tester) async {
    await Services.init();
    await tester.pumpWidget(const OfflineNotesApp());

    await _pumpUntilFound(tester, find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(const Duration(milliseconds: 100));

    await _pumpUntilFound(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField).at(0), 'Hello');
    await tester.enterText(find.byType(TextField).at(1), 'World');

    await _pumpUntilFound(tester, find.byIcon(Icons.check));
    await tester.tap(find.byIcon(Icons.check));

    await _pumpUntilFound(tester, find.text('Hello'));
    expect(find.text('Hello'), findsOneWidget);
  });
}
