import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'package:offline_notes/features/notes/data/repository/notes_repository.dart';
import 'package:offline_notes/features/notes/data/sync/sync_status.dart';
import 'package:offline_notes/features/notes/domain/note.dart';

class NotesListController extends ChangeNotifier {
  NotesListController({
    required NotesRepository repository,
    Connectivity? connectivity,
  })  : _repository = repository,
        _connectivity = connectivity ?? Connectivity() {
    _syncStatus = repository.observeSyncStatus();
    _syncStatus.addListener(_onSyncStatusChanged);
  }

  final NotesRepository _repository;
  final Connectivity _connectivity;

  late final ValueListenable<SyncStatus> _syncStatus;

  StreamSubscription<List<Note>>? _notesSub;
  StreamSubscription<List<ConnectivityResult>>? _connSub;

  List<Note> notes = const <Note>[];
  String query = '';
  SyncStatus syncStatus = const SyncIdle();

  bool _initialized = false;

  // PUBLIC_INTERFACE
  /// Initializes subscriptions. Must be called once from widget `initState`.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    syncStatus = _syncStatus.value;
    _subscribeNotes();

    // Opportunistic sync when connectivity becomes available.
    _connSub = _connectivity.onConnectivityChanged.listen((results) {
      final hasNetwork = results.any((r) => r != ConnectivityResult.none);
      if (hasNetwork) {
        // Fire-and-forget (controller does not touch context after await).
        unawaited(_repository.syncNow());
      }
    });

    // Opportunistic sync on startup as well.
    unawaited(_repository.syncNow());
  }

  void _onSyncStatusChanged() {
    syncStatus = _syncStatus.value;
    notifyListeners();
  }

  void _subscribeNotes() {
    _notesSub?.cancel();
    _notesSub = _repository.observeNotes(query).listen((value) {
      notes = value;
      notifyListeners();
    });
  }

  // PUBLIC_INTERFACE
  /// Updates the search query and refreshes the observed stream.
  void setQuery(String value) {
    final next = value;
    if (next == query) return;
    query = next;
    _subscribeNotes();
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  /// Manually triggers sync and updates sync status via repository notifier.
  Future<void> manualSync() async {
    await _repository.triggerManualSync();
  }

  @override
  void dispose() {
    _notesSub?.cancel();
    _connSub?.cancel();
    _syncStatus.removeListener(_onSyncStatusChanged);
    super.dispose();
  }
}
