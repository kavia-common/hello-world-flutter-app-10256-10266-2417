import 'package:flutter/foundation.dart';

@immutable
class Note {
  final String id;
  final String title;
  final String content;
  final int createdAt;
  final int updatedAt;
  final bool deleted;
  final bool dirty;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
    required this.dirty,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    int? createdAt,
    int? updatedAt,
    bool? deleted,
    bool? dirty,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      dirty: dirty ?? this.dirty,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deleted == deleted &&
        other.dirty == dirty;
  }

  @override
  int get hashCode => Object.hash(id, title, content, createdAt, updatedAt, deleted, dirty);
}
