import 'package:offline_notes/features/notes/data/local/notes_dao.dart';
import 'package:offline_notes/features/notes/data/local/notes_database.dart';
import 'package:offline_notes/features/notes/data/remote/in_memory_notes_api.dart';
import 'package:offline_notes/features/notes/data/repository/default_notes_repository.dart';
import 'package:offline_notes/features/notes/data/repository/notes_repository.dart';

class Services {
  Services._(this.repository);

  final NotesRepository repository;

  static Services? _instance;

  // PUBLIC_INTERFACE
  /// Initializes and returns app-wide services singleton.
  static Future<Services> init() async {
    if (_instance != null) return _instance!;
    final db = await NotesDatabase.open();
    final dao = NotesDao(db.db);
    final api = InMemoryNotesApi();
    final repo = DefaultNotesRepository(dao: dao, api: api);
    _instance = Services._(repo);
    return _instance!;
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
