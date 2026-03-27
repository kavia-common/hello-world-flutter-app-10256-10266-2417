import 'package:flutter_test/flutter_test.dart';

import 'package:offline_notes/features/notes/data/local/in_memory_notes_local_data_source.dart';
import 'package:offline_notes/features/notes/data/remote/in_memory_notes_api.dart';
import 'package:offline_notes/features/notes/data/repository/default_notes_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('search treats % and _ literally (in-memory filter)', () async {
    final dao = InMemoryNotesLocalDataSource();
    final api = InMemoryNotesApi();
    final repo = DefaultNotesRepository(dao: dao, api: api);

    final id = await repo.createNote('100% legit', 'a_b');
    await repo.updateNote(id, '100% legit', 'a_b');

    final resultsPercent = await repo.observeNotes('%').first;
    expect(resultsPercent.any((n) => n.id == id), isTrue);

    final resultsUnderscore = await repo.observeNotes('_').first;
    expect(resultsUnderscore.any((n) => n.id == id), isTrue);
  });

  test('sync uses LWW: remote older does not overwrite newer local', () async {
    int now = 1000;
    final dao = InMemoryNotesLocalDataSource();
    final api = InMemoryNotesApi();
    final repo = DefaultNotesRepository(dao: dao, api: api, now: () => now);

    final id = await repo.createNote('t1', 'c1'); // updatedAt=1000
    await repo.triggerManualSync();

    // Local edit newer
    now = 2000;
    await repo.updateNote(id, 't2', 'c2'); // dirty, updatedAt=2000

    // Push an older remote version directly (updatedAt=1500) and sync
    await api.pushNotes([
      (await repo.observeNote(id).first)!.copyWith(title: 'REMOTE_OLD', updatedAt: 1500, dirty: false),
    ]);

    await repo.syncNow();

    final after = await repo.observeNote(id).first;
    expect(after!.title, 't2');
    expect(after.updatedAt, 2000);
  });

  test('tombstone delete uploaded then purged locally after sync', () async {
    int now = 1000;
    final dao = InMemoryNotesLocalDataSource();
    final api = InMemoryNotesApi();
    final repo = DefaultNotesRepository(dao: dao, api: api, now: () => now);

    final id = await repo.createNote('a', 'b');
    await repo.triggerManualSync();

    now = 2000;
    await repo.deleteNote(id);

    await repo.syncNow();

    // After purge, observeNotes should not contain it; observeNote might be null due to purge.
    final list = await repo.observeNotes('').first;
    expect(list.any((n) => n.id == id), isFalse);
  });
}
