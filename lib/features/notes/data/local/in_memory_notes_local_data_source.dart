import 'dart:collection';

import 'package:offline_notes/features/notes/data/local/notes_local_data_source.dart';
import 'package:offline_notes/features/notes/domain/note.dart';

class InMemoryNotesLocalDataSource implements NotesLocalDataSource {
  final Map<String, Note> _notesById = HashMap<String, Note>();
  final Map<String, int> _lastSyncAtByKey = HashMap<String, int>();

  @override
  Future<void> upsertNote(Note note) async {
    _notesById[note.id] = note;
  }

  @override
  Future<void> upsertNotesInTransaction(List<Note> notes) async {
    for (final note in notes) {
      _notesById[note.id] = note;
    }
  }

  @override
  Future<Note?> getById(String id) async {
    return _notesById[id];
  }

  @override
  Future<List<Note>> getAllNonDeletedSorted() async {
    final list = _notesById.values.where((n) => !n.deleted).toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  Future<List<Note>> getAllIncludingDeleted() async {
    final list = _notesById.values.toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  @override
  Future<List<Note>> getDirtyNotes() async {
    return _notesById.values.where((n) => n.dirty).toList(growable: false);
  }

  @override
  Future<void> markDeleted(String id, {required int updatedAt}) async {
    final existing = _notesById[id];
    if (existing == null) return;

    _notesById[id] = existing.copyWith(
      deleted: true,
      dirty: true,
      updatedAt: updatedAt,
    );
  }

  @override
  Future<void> markClean(List<String> ids) async {
    for (final id in ids) {
      final existing = _notesById[id];
      if (existing == null) continue;
      _notesById[id] = existing.copyWith(dirty: false);
    }
  }

  @override
  Future<void> purgeDeleted() async {
    final toRemove = _notesById.values.where((n) => n.deleted && !n.dirty).map((n) => n.id).toList();
    for (final id in toRemove) {
      _notesById.remove(id);
    }
  }

  @override
  Future<int> getLastSyncAt(String key) async {
    return _lastSyncAtByKey[key] ?? 0;
  }

  @override
  Future<void> setLastSyncAt(String key, int value) async {
    _lastSyncAtByKey[key] = value;
  }
}
