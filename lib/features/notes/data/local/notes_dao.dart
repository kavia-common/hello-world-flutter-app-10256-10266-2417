import 'package:sqflite/sqflite.dart';

import 'package:offline_notes/features/notes/data/local/note_mapper.dart';
import 'package:offline_notes/features/notes/data/local/notes_local_data_source.dart';
import 'package:offline_notes/features/notes/domain/note.dart';

class NotesDao implements NotesLocalDataSource {
  final Database db;

  NotesDao(this.db);

  @override
  Future<void> upsertNote(Note note) async {
    await db.insert(
      'notes',
      NoteMapper.toRow(note),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertNotesInTransaction(List<Note> notes) async {
    await db.transaction((txn) async {
      for (final note in notes) {
        await txn.insert(
          'notes',
          NoteMapper.toRow(note),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<Note?> getById(String id) async {
    final rows = await db.query('notes', where: 'id = ?', whereArgs: <Object?>[id], limit: 1);
    if (rows.isEmpty) return null;
    return NoteMapper.fromRow(rows.first);
  }

  @override
  Future<List<Note>> getAllNonDeletedSorted() async {
    final rows = await db.query(
      'notes',
      where: 'deleted = 0',
      orderBy: 'updated_at DESC',
    );
    return rows.map(NoteMapper.fromRow).toList(growable: false);
  }

  @override
  Future<List<Note>> getAllIncludingDeleted() async {
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(NoteMapper.fromRow).toList(growable: false);
  }

  @override
  Future<List<Note>> getDirtyNotes() async {
    final rows = await db.query('notes', where: 'dirty = 1');
    return rows.map(NoteMapper.fromRow).toList(growable: false);
  }

  @override
  Future<void> markDeleted(String id, {required int updatedAt}) async {
    await db.update(
      'notes',
      <String, Object?>{'deleted': 1, 'dirty': 1, 'updated_at': updatedAt},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  @override
  Future<void> markClean(List<String> ids) async {
    if (ids.isEmpty) return;

    final placeholders = List<String>.filled(ids.length, '?').join(',');
    await db.update(
      'notes',
      <String, Object?>{'dirty': 0},
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
  }

  @override
  Future<void> purgeDeleted() async {
    await db.delete('notes', where: 'deleted = 1 AND dirty = 0');
  }

  @override
  Future<int> getLastSyncAt(String key) async {
    final rows = await db.query('sync_state', where: 'key = ?', whereArgs: <Object?>[key], limit: 1);
    if (rows.isEmpty) return 0;
    return (rows.first['last_sync_at'] as int?) ?? 0;
  }

  @override
  Future<void> setLastSyncAt(String key, int value) async {
    await db.insert(
      'sync_state',
      <String, Object?>{'key': key, 'last_sync_at': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
