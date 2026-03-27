import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:offline_notes/features/notes/data/local/notes_local_data_source.dart';
import 'package:offline_notes/features/notes/data/remote/notes_api.dart';
import 'package:offline_notes/features/notes/data/repository/notes_repository.dart';
import 'package:offline_notes/features/notes/data/sync/sync_status.dart';
import 'package:offline_notes/features/notes/domain/note.dart';

class DefaultNotesRepository implements NotesRepository {
  DefaultNotesRepository({
    required NotesLocalDataSource dao,
    required NotesApi api,
    Uuid? uuid,
    int Function()? now,
  })  : _dao = dao,
        _api = api,
        _uuid = uuid ?? const Uuid(),
        _now = now ?? (() => DateTime.now().millisecondsSinceEpoch);

  final NotesLocalDataSource _dao;
  final NotesApi _api;
  final Uuid _uuid;
  final int Function() _now;

  final String _syncKey = 'notes';

  // ValueNotifier's constructor is not const.
  final ValueNotifier<SyncStatus> _syncStatus = ValueNotifier<SyncStatus>(const SyncIdle());

  final StreamController<void> _dbChanged = StreamController<void>.broadcast();

  void _emitDbChanged() {
    if (!_dbChanged.isClosed) {
      _dbChanged.add(null);
    }
  }

  Stream<void> get _changes async* {
    // Ensure initial emission happens immediately on subscription.
    yield null;
    yield* _dbChanged.stream;
  }

  // PUBLIC_INTERFACE
  /// Disposes internal resources. Call from app lifecycle when needed.
  void dispose() {
    _syncStatus.dispose();
    _dbChanged.close();
  }

  @override
  Stream<List<Note>> observeNotes(String query) {
    final q = query.trim();
    return _changes.asyncMap((_) async {
      // Implement search in-memory to guarantee `%` and `_` are treated literally
      // (and avoid SQL LIKE escaping complexities).
      final all = await _dao.getAllNonDeletedSorted();
      if (q.isEmpty) return all;

      final lower = q.toLowerCase();
      return all
          .where(
            (n) => n.title.toLowerCase().contains(lower) || n.content.toLowerCase().contains(lower),
          )
          .toList(growable: false)
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }).distinct(_listNotesEquals);
  }

  @override
  Stream<Note?> observeNote(String id) {
    return _changes.asyncMap((_) => _dao.getById(id)).distinct();
  }

  @override
  ValueListenable<SyncStatus> observeSyncStatus() => _syncStatus;

  @override
  Future<String> createNote(String title, String content) async {
    final now = _now();
    final id = _uuid.v4();
    final note = Note(
      id: id,
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      deleted: false,
      dirty: true,
    );
    await _dao.upsertNote(note);
    _emitDbChanged();
    return id;
  }

  @override
  Future<void> updateNote(String id, String title, String content) async {
    final now = _now();
    final existing = await _dao.getById(id);
    final createdAt = existing?.createdAt ?? now;

    // Updating a deleted note restores it (deleted=false), matching Kotlin behavior.
    final note = Note(
      id: id,
      title: title,
      content: content,
      createdAt: createdAt,
      updatedAt: now,
      deleted: false,
      dirty: true,
    );
    await _dao.upsertNote(note);
    _emitDbChanged();
  }

  @override
  Future<void> deleteNote(String id) async {
    final now = _now();
    await _dao.markDeleted(id, updatedAt: now);
    _emitDbChanged();
  }

  @override
  Future<void> triggerManualSync() async {
    _syncStatus.value = const SyncRunning();
    try {
      await syncNow();
      _syncStatus.value = SyncSuccess(_now());
    } catch (e) {
      _syncStatus.value = SyncError(e.toString());
      rethrow;
    }
  }

  @override
  Future<void> syncNow() async {
    final lastSyncAt = await _dao.getLastSyncAt(_syncKey);
    var maxObservedUpdatedAt = lastSyncAt;

    // 1) Upload dirty local notes (including tombstones).
    final dirtyLocal = await _dao.getDirtyNotes();
    if (dirtyLocal.isNotEmpty) {
      final localMax = dirtyLocal.map((n) => n.updatedAt).reduce((a, b) => a > b ? a : b);
      maxObservedUpdatedAt = maxObservedUpdatedAt > localMax ? maxObservedUpdatedAt : localMax;

      await _api.pushNotes(dirtyLocal);
      await _dao.markClean(dirtyLocal.map((n) => n.id).toList(growable: false));
    }

    // 2) Download remote updated since lastSyncAt
    final remote = await _api.fetchNotesUpdatedSince(lastSyncAt);

    // 3) Merge remote into local with LWW: apply only if remote.updatedAt > local.updatedAt
    final List<Note> toUpsert = <Note>[];
    for (final remoteNote in remote) {
      if (remoteNote.updatedAt > maxObservedUpdatedAt) {
        maxObservedUpdatedAt = remoteNote.updatedAt;
      }

      final local = await _dao.getById(remoteNote.id);
      final shouldApplyRemote = local == null || remoteNote.updatedAt > local.updatedAt;

      if (shouldApplyRemote) {
        toUpsert.add(remoteNote.copyWith(dirty: false));
      }
    }

    if (toUpsert.isNotEmpty) {
      await _dao.upsertNotesInTransaction(toUpsert);
    }

    // 4) Persist lastSyncAt monotonic (max observed from local+remote)
    await _dao.setLastSyncAt(_syncKey, maxObservedUpdatedAt);

    // 5) Purge deleted notes locally after successful sync
    await _dao.purgeDeleted();

    _emitDbChanged();
  }

  static bool _listNotesEquals(List<Note> a, List<Note> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
