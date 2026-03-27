import 'package:flutter/material.dart';

import 'package:offline_notes/app/services.dart';
import 'package:offline_notes/features/notes/presentation/controllers/note_editor_controller.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;

  const NoteEditorScreen({super.key, required this.noteId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final NoteEditorController _controller;

  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();

  bool _initialTextSet = false;
  bool _shouldPop = false;

  @override
  void initState() {
    super.initState();
    _controller = NoteEditorController(
      repository: Services.instance().repository,
      noteId: widget.noteId,
    )..init();
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;

    // Only set initial controller text once when editing.
    if (!_initialTextSet && _controller.note != null) {
      _initialTextSet = true;
      _title.text = _controller.note!.title;
      _content.text = _controller.note!.content;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  void _save() {
    // Avoid awaiting with context usage. Instead set a flag to pop in build.
    _controller
        .save(title: _title.text.trim(), content: _content.text.trim())
        .then((_) => _shouldPop = true)
        .whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  void _delete() {
    _controller.delete().then((_) => _shouldPop = true).whenComplete(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_shouldPop) {
      // Navigation executed in build to avoid context usage after await.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    final isEditing = widget.noteId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'New Note'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Save',
            onPressed: _save,
            icon: const Icon(Icons.check),
          ),
          if (isEditing)
            IconButton(
              tooltip: 'Delete',
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: _controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(hintText: 'Title'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _content,
                      decoration: const InputDecoration(hintText: 'Write something…'),
                      maxLines: null,
                      expands: true,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
