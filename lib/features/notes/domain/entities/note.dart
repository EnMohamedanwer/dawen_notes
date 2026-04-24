import 'package:equatable/equatable.dart';

class Note extends Equatable {
  const Note({
    required this.id,
    required this.title,
    required this.contentJson,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isArchived = false,
    this.wordCount = 0,
    this.imagePaths = const [],
    this.isLocked = false,
    this.notePin = '',
  });

  final String id;
  final String title;
  final String contentJson;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isArchived;
  final int wordCount;
  final List<String> imagePaths;
  final bool isLocked;
  final String notePin;

  String get plainText {
    try {
      return contentJson
          .replaceAll(RegExp(r'[\[\]{}"\\]'), ' ')
          .replaceAll('insert:', '')
          .replaceAll('attributes:', '')
          .replaceAll('\\n', ' ')
          .trim();
    } catch (_) {
      return contentJson;
    }
  }

  Note copyWith({
    String? id, String? title, String? contentJson, String? categoryId,
    DateTime? createdAt, DateTime? updatedAt, bool? isFavorite,
    bool? isArchived, int? wordCount, List<String>? imagePaths,
    bool? isLocked, String? notePin,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      contentJson: contentJson ?? this.contentJson,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      wordCount: wordCount ?? this.wordCount,
      imagePaths: imagePaths ?? this.imagePaths,
      isLocked: isLocked ?? this.isLocked,
      notePin: notePin ?? this.notePin,
    );
  }

  @override
  List<Object?> get props => [
        id, title, contentJson, categoryId,
        createdAt, updatedAt, isFavorite, isArchived,
        wordCount, imagePaths, isLocked, notePin,
      ];
}
