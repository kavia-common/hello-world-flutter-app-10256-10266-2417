import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:offline_notes/features/notes/data/repository/notes_repository.dart';
import 'package:offline_notes/features/notes/domain/note.dart';

class NoteEditorController extends ChangeNotifier {
  NoteEditorController({
    required NotesRepository repository,
    required String? noteId,
  })  : _repository = repository,
        _noteId = noteId;

  final NotesRepository _repository;
  final String? _noteId;

  StreamSubscription<Note?>? _noteSub;

  Note? note;
  bool isLoading = true;

  // PUBLIC_INTERFACE
  /// Initializes editor by observing the note (if editing).
  void init() {
    if (_noteId == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

    _noteSub = _repository.observeNote(_noteId!).listen((value) {
      note = value;
      isLoading = false;
      notifyListeners();
    });
  }

  bool get isEditing => _noteId != null;

  // PUBLIC_INTERFACE
  /// Saves current content (create or update).
  Future<String?> save({required String title, required String content}) async {
    if (_noteId == null) {
      final id = await _repository.createNote(title, content);
      return id;
    }
    await _repository.updateNote(_noteId, title, content);
    return _noteId;
  }

  // PUBLIC_INTERFACE
  /// Tombstone-deletes the note (only for existing notes).
  Future<void> delete() async {
    final id = _noteId;
    if (id == null) return;
    await _repository.deleteNote(id);
  }

  @override
  void dispose() {
    _noteSub?.cancel();
    super.dispose();
  }
}
