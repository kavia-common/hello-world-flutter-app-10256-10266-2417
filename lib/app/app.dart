import 'package:flutter/material.dart';

import 'package:offline_notes/app/theme.dart';
import 'package:offline_notes/features/notes/presentation/screens/notes_list_screen.dart';

/// Root widget of the Offline Notes application.
class OfflineNotesApp extends StatelessWidget {
  /// Creates the root app widget.
  const OfflineNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightGrey(),
      home: const NotesListScreen(),
    );
  }
}
