import 'package:offline_notes/features/notes/domain/note.dart';

abstract class NotesApi {
  Future<void> pushNotes(List<Note> notes);

  Future<List<Note>> fetchNotesUpdatedSince(int sinceEpochMillis);
}
