import 'package:offline_notes/features/notes/data/local/notes_dao.dart';
import 'package:offline_notes/features/notes/data/local/notes_database.dart';
import 'package:offline_notes/features/notes/data/remote/in_memory_notes_api.dart';
import 'package:offline_notes/features/notes/data/remote/notes_api.dart';
import 'package:offline_notes/features/notes/data/repository/default_notes_repository.dart';
import 'package:offline_notes/features/notes/data/repository/notes_repository.dart';

class Services {
  Services._(this.repository);

  final NotesRepository repository;

  static Services? _instance;

  // PUBLIC_INTERFACE
  /// Initializes and returns app-wide services singleton.
  ///
  /// Tests can supply a custom [repository] to avoid platform/SQLite dependencies.
  static Future<Services> init({NotesRepository? repository}) async {
    if (_instance != null) return _instance!;
    if (repository != null) {
      _instance = Services._(repository);
      return _instance!;
    }

    final db = await NotesDatabase.open();
    final dao = NotesDao(db.db);
    final NotesApi api = InMemoryNotesApi();
    final repo = DefaultNotesRepository(dao: dao, api: api);
    _instance = Services._(repo);
    return _instance!;
  }

  // PUBLIC_INTERFACE
  /// Resets the singleton. Intended for tests to ensure isolation.
  static void resetForTest() {
    _instance = null;
  }

  // PUBLIC_INTERFACE
  /// Returns already-initialized singleton instance.
  static Services instance() {
    final inst = _instance;
    if (inst == null) {
      throw StateError('Services not initialized. Call Services.init() first.');
    }
    return inst;
  }
}
