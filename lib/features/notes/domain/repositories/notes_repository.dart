import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/note.dart';
import '../entities/note_category.dart';

abstract class NotesRepository {
  // Notes CRUD
  Future<Either<Failure, List<Note>>> getAllNotes();
  Future<Either<Failure, List<Note>>> getNotesByCategory(String categoryId);
  Future<Either<Failure, List<Note>>> getFavoriteNotes();
  Future<Either<Failure, List<Note>>> getArchivedNotes();
  Future<Either<Failure, List<Note>>> searchNotes(String query);
  Future<Either<Failure, Note>> getNoteById(String id);
  Future<Either<Failure, Note>> createNote(Note note);
  Future<Either<Failure, Note>> updateNote(Note note);
  Future<Either<Failure, bool>> deleteNote(String id);
  Future<Either<Failure, bool>> toggleFavorite(String id);
  Future<Either<Failure, bool>> toggleArchive(String id);

  // Categories
  Future<Either<Failure, List<NoteCategory>>> getCategories();
  Future<Either<Failure, NoteCategory>> createCategory(NoteCategory category);
  Future<Either<Failure, bool>> deleteCategory(String id);
}
