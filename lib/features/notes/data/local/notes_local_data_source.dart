import 'package:offline_notes/features/notes/domain/note.dart';

abstract class NotesLocalDataSource {
  // PUBLIC_INTERFACE
  /// Inserts or replaces a note in the local store.
  Future<void> upsertNote(Note note);

  // PUBLIC_INTERFACE
  /// Inserts or replaces multiple notes atomically.
  Future<void> upsertNotesInTransaction(List<Note> notes);

  // PUBLIC_INTERFACE
  /// Returns a note by id or null if it doesn't exist.
  Future<Note?> getById(String id);

  // PUBLIC_INTERFACE
  /// Returns all notes that are not deleted, sorted by updatedAt descending.
  Future<List<Note>> getAllNonDeletedSorted();

  // PUBLIC_INTERFACE
  /// Returns all notes including deleted, sorted by updatedAt descending.
  Future<List<Note>> getAllIncludingDeleted();

  // PUBLIC_INTERFACE
  /// Returns all dirty notes (including tombstones).
  Future<List<Note>> getDirtyNotes();

  // PUBLIC_INTERFACE
  /// Marks a note as deleted and dirty, updating updatedAt.
  Future<void> markDeleted(String id, {required int updatedAt});

  // PUBLIC_INTERFACE
  /// Marks notes as clean (dirty=false).
  Future<void> markClean(List<String> ids);

  // PUBLIC_INTERFACE
  /// Purges notes that are deleted and already clean (synced).
  Future<void> purgeDeleted();

  // PUBLIC_INTERFACE
  /// Gets the last sync timestamp for the given key.
  Future<int> getLastSyncAt(String key);

  // PUBLIC_INTERFACE
  /// Sets the last sync timestamp for the given key.
  Future<void> setLastSyncAt(String key, int value);
}
