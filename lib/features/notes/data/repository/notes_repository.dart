import 'package:flutter/foundation.dart';

import 'package:offline_notes/features/notes/data/sync/sync_status.dart';
import 'package:offline_notes/features/notes/domain/note.dart';

abstract class NotesRepository {
  Stream<List<Note>> observeNotes(String query);
  Stream<Note?> observeNote(String id);

  ValueListenable<SyncStatus> observeSyncStatus();

  Future<String> createNote(String title, String content);
  Future<void> updateNote(String id, String title, String content);
  Future<void> deleteNote(String id);

  Future<void> triggerManualSync();
  Future<void> syncNow();
}
