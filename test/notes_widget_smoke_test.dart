import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:offline_notes/app/app.dart';
import 'package:offline_notes/app/services.dart';
import 'package:offline_notes/features/notes/data/local/in_memory_notes_local_data_source.dart';
import 'package:offline_notes/features/notes/data/remote/in_memory_notes_api.dart';
import 'package:offline_notes/features/notes/data/repository/default_notes_repository.dart';

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

  DefaultNotesRepository makeTestRepository() {
    final dao = InMemoryNotesLocalDataSource();
    final api = InMemoryNotesApi();
    return DefaultNotesRepository(dao: dao, api: api);
  }

  testWidgets('app boots', (tester) async {
    Services.resetForTest();
    await Services.init(repository: makeTestRepository());

    await tester.pumpWidget(const OfflineNotesApp());

    // Avoid pumpAndSettle() hangs due to ongoing timers/streams.
    await _pumpUntilFound(tester, find.text('Notes'));

    expect(find.text('Notes'), findsOneWidget);
  });

  testWidgets('create note shows in list', (tester) async {
    Services.resetForTest();
    await Services.init(repository: makeTestRepository());

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
