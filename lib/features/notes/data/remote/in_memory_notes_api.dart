import 'dart:collection';

import 'package:offline_notes/features/notes/data/remote/notes_api.dart';
import 'package:offline_notes/features/notes/domain/note.dart';

class InMemoryNotesApi implements NotesApi {
  final Map<String, Note> _store = HashMap<String, Note>();

  @override
  Future<void> pushNotes(List<Note> notes) async {
    for (final incoming in notes) {
      final existing = _store[incoming.id];
      if (existing == null || incoming.updatedAt >= existing.updatedAt) {
        _store[incoming.id] = incoming.copyWith(dirty: false);
      }
    }
  }

  @override
  Future<List<Note>> fetchNotesUpdatedSince(int sinceEpochMillis) async {
    final list = _store.values.where((n) => n.updatedAt > sinceEpochMillis).toList(growable: false)
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }
}
