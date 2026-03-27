import 'package:offline_notes/features/notes/domain/note.dart';

class NoteMapper {
  static Note fromRow(Map<String, Object?> row) {
    return Note(
      id: row['id']! as String,
      title: row['title']! as String,
      content: row['content']! as String,
      createdAt: row['created_at']! as int,
      updatedAt: row['updated_at']! as int,
      deleted: (row['deleted']! as int) == 1,
      dirty: (row['dirty']! as int) == 1,
    );
  }

  static Map<String, Object?> toRow(Note note) {
    return <String, Object?>{
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'created_at': note.createdAt,
      'updated_at': note.updatedAt,
      'deleted': note.deleted ? 1 : 0,
      'dirty': note.dirty ? 1 : 0,
    };
  }
}
