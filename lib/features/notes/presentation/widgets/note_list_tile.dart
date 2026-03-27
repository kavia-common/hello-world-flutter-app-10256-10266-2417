import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:offline_notes/features/notes/domain/note.dart';

class NoteListTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  const NoteListTile({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.fromMillisecondsSinceEpoch(note.updatedAt);
    final formatted = DateFormat.yMMMd().add_jm().format(dt);

    // Kotlin shows a 3-line stack inside a bordered, slightly rounded card.
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                note.title.isEmpty ? '(Untitled)' : note.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                note.content.isEmpty ? ' ' : note.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Modified: $formatted',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
