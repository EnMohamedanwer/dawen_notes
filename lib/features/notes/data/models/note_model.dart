import 'package:hive/hive.dart';
import '../../domain/entities/note.dart';
import '../../../../core/constants/hive_constants.dart';

part 'note_model.g.dart';

@HiveType(typeId: HiveTypeIds.noteModel)
class NoteModel extends HiveObject {
  NoteModel({
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

  @HiveField(0) String id;
  @HiveField(1) String title;
  @HiveField(2) String contentJson;
  @HiveField(3) String categoryId;
  @HiveField(4) DateTime createdAt;
  @HiveField(5) DateTime updatedAt;
  @HiveField(6) bool isFavorite;
  @HiveField(7) bool isArchived;
  @HiveField(8) int wordCount;
  @HiveField(9) List<String> imagePaths;
  @HiveField(10) bool isLocked;
  @HiveField(11) String notePin;

  Note toEntity() => Note(
        id: id, title: title, contentJson: contentJson,
        categoryId: categoryId, createdAt: createdAt, updatedAt: updatedAt,
        isFavorite: isFavorite, isArchived: isArchived, wordCount: wordCount,
        imagePaths: List<String>.from(imagePaths),
        isLocked: isLocked, notePin: notePin,
      );

  factory NoteModel.fromEntity(Note note) => NoteModel(
        id: note.id, title: note.title, contentJson: note.contentJson,
        categoryId: note.categoryId, createdAt: note.createdAt,
        updatedAt: note.updatedAt, isFavorite: note.isFavorite,
        isArchived: note.isArchived, wordCount: note.wordCount,
        imagePaths: List<String>.from(note.imagePaths),
        isLocked: note.isLocked, notePin: note.notePin,
      );
}
