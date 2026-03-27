import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesDatabase {
  NotesDatabase._(this.db);

  final Database db;

  static const int _schemaVersion = 1;

  // PUBLIC_INTERFACE
  /// Opens (and migrates if needed) the notes SQLite database.
  ///
  /// In production, this resolves the app documents directory via `path_provider`.
  /// In tests, pass [dbDirectoryPath] to avoid platform channel usage.
  static Future<NotesDatabase> open({String? dbDirectoryPath}) async {
    final String directoryPath;
    if (dbDirectoryPath != null) {
      directoryPath = dbDirectoryPath;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      directoryPath = dir.path;
    }

    // Ensure directory exists when running in tests (temporary directories).
    await Directory(directoryPath).create(recursive: true);

    final path = p.join(directoryPath, 'offline_notes.db');

    final db = await openDatabase(
      path,
      version: _schemaVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
CREATE TABLE notes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  deleted INTEGER NOT NULL,
  dirty INTEGER NOT NULL
)
''');

        await db.execute('''
CREATE TABLE sync_state (
  key TEXT PRIMARY KEY,
  last_sync_at INTEGER NOT NULL
)
''');

        await db.insert('sync_state', <String, Object?>{'key': 'notes', 'last_sync_at': 0});
      },
    );

    return NotesDatabase._(db);
  }
}
