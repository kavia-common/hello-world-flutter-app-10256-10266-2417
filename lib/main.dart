import 'package:flutter/material.dart';

import 'package:offline_notes/app/app.dart';

/// Main entry point for the Offline Notes Flutter app.
///
/// Offline-first notes with:
/// - Local SQLite persistence
/// - Reactive UI updates from local DB
/// - Client-only sync against an in-memory backend
/// - Last-write-wins conflict resolution by `updatedAt`
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OfflineNotesApp());
}
