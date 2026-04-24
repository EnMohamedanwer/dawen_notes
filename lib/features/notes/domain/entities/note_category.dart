import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class NoteCategory extends Equatable {
  const NoteCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.noteCount = 0,
  });

  final String id;
  final String name;
  final String icon;
  final Color color;
  final int noteCount;

  NoteCategory copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    int? noteCount,
  }) {
    return NoteCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      noteCount: noteCount ?? this.noteCount,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, color, noteCount];
}
