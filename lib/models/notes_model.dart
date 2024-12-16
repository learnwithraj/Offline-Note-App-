// // class Note {
// //   int? id;
// //   String title;
// //   String content;

// //   Note({
// //     this.id,
// //     required this.title,
// //     required this.content,
// //   });

// //   Map<String, dynamic> toMap() {
// //     return {
// //       'id': id,
// //       'title': title,
// //       'content': content,
// //     };
// //   }

// //   factory Note.fromMap(Map<String, dynamic> map) {
// //     return Note(
// //       id: map['id'],
// //       title: map['title'],
// //       content: map['content'],
// //     );
// //   }
// // }

// // Note Model
import 'package:flutter/material.dart';
import 'package:notes_app/providers/notes_provider.dart';

class Note {
  final String? id;
  final String title;
  final String content;
  final List<String>? tags;
  final NotePriority? priority;
  final Color? color;
  final DateTime? createdAt;
  final DateTime? lastEdited;

  Note({
    this.id,
    required this.title,
    required this.content,
    this.tags,
    this.priority = NotePriority.low,
    this.color,
    this.createdAt,
    this.lastEdited,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags?.join(','),
      'priority': priority?.index,
      'color': color?.value,
      'createdAt': createdAt?.toIso8601String(),
      'lastEdited': lastEdited?.toIso8601String(),
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id']?.toString(),
      title: map['title'],
      content: map['content'],
      tags: map['tags'] != null ? map['tags'].toString().split(',') : [],
      priority: NotePriority.values[map['priority'] ?? 2],
      color: map['color'] != null ? Color(map['color']) : null,
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      lastEdited:
          map['lastEdited'] != null ? DateTime.parse(map['lastEdited']) : null,
    );
  }
}
