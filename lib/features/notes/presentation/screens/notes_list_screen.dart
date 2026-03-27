import 'package:flutter/material.dart';

import 'package:offline_notes/app/services.dart';
import 'package:offline_notes/features/notes/data/sync/sync_status.dart';
import 'package:offline_notes/features/notes/presentation/controllers/notes_list_controller.dart';
import 'package:offline_notes/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:offline_notes/features/notes/presentation/widgets/note_list_tile.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> with WidgetsBindingObserver {
  NotesListController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Opportunistic sync on resume; no context usage after await.
      _controller?.manualSync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _ensureInitialized() async {
    await Services.init();

    // Build controller once after services are ready.
    final already = _controller;
    if (already != null) return;

    final controller = NotesListController(repository: Services.instance().repository);
    await controller.init();
    if (!mounted) return;

    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ensureInitialized(),
      builder: (context, snapshot) {
        final controller = _controller;
        if (controller == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Notes'),
                actions: <Widget>[
                  IconButton(
                    tooltip: 'Sync',
                    onPressed: () {
                      controller.manualSync();
                    },
                    icon: const Icon(Icons.sync),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const NoteEditorScreen(noteId: null),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
              body: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search notes…',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: controller.setQuery,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SyncStatusRow(status: controller.syncStatus),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: controller.notes.isEmpty
                        ? const Center(child: Text('No notes yet. Tap + to create one.'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            itemBuilder: (context, index) {
                              final note = controller.notes[index];
                              return NoteListTile(
                                note: note,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => NoteEditorScreen(noteId: note.id),
                                    ),
                                  );
                                },
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemCount: controller.notes.length,
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _SyncStatusRow extends StatelessWidget {
  final SyncStatus status;

  const _SyncStatusRow({required this.status});

  String _label() {
    return switch (status) {
      SyncRunning() => 'Syncing…',
      SyncSuccess() => 'Synced',
      SyncError() => 'Sync error',
      _ => 'Idle',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(Icons.cloud_done, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          _label(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
