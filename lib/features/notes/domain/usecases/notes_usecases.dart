import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/note.dart';
import '../entities/note_category.dart';
import '../repositories/notes_repository.dart';

// ─── Get All Notes ───────────────────────────────────────────────────────────
class GetAllNotes implements UseCase<List<Note>, NoParams> {
  GetAllNotes(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, List<Note>>> call(NoParams params) =>
      repository.getAllNotes();
}

// ─── Get Notes By Category ───────────────────────────────────────────────────
class GetNotesByCategory implements UseCase<List<Note>, String> {
  GetNotesByCategory(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, List<Note>>> call(String categoryId) =>
      repository.getNotesByCategory(categoryId);
}

// ─── Get Favorite Notes ──────────────────────────────────────────────────────
class GetFavoriteNotes implements UseCase<List<Note>, NoParams> {
  GetFavoriteNotes(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, List<Note>>> call(NoParams params) =>
      repository.getFavoriteNotes();
}

// ─── Search Notes ────────────────────────────────────────────────────────────
class SearchNotes implements UseCase<List<Note>, String> {
  SearchNotes(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, List<Note>>> call(String query) =>
      repository.searchNotes(query);
}

// ─── Create Note ─────────────────────────────────────────────────────────────
class CreateNote implements UseCase<Note, Note> {
  CreateNote(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, Note>> call(Note note) =>
      repository.createNote(note);
}

// ─── Update Note ─────────────────────────────────────────────────────────────
class UpdateNote implements UseCase<Note, Note> {
  UpdateNote(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, Note>> call(Note note) =>
      repository.updateNote(note);
}

// ─── Delete Note ─────────────────────────────────────────────────────────────
class DeleteNote implements UseCase<bool, String> {
  DeleteNote(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, bool>> call(String id) =>
      repository.deleteNote(id);
}

// ─── Toggle Favorite ─────────────────────────────────────────────────────────
class ToggleFavorite implements UseCase<bool, String> {
  ToggleFavorite(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, bool>> call(String id) =>
      repository.toggleFavorite(id);
}

// ─── Toggle Archive ──────────────────────────────────────────────────────────
class ToggleArchive implements UseCase<bool, String> {
  ToggleArchive(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, bool>> call(String id) =>
      repository.toggleArchive(id);
}

// ─── Get Categories ──────────────────────────────────────────────────────────
class GetCategories implements UseCase<List<NoteCategory>, NoParams> {
  GetCategories(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, List<NoteCategory>>> call(NoParams params) =>
      repository.getCategories();
}

// ─── Create Category ─────────────────────────────────────────────────────────
class CreateCategory implements UseCase<NoteCategory, NoteCategory> {
  CreateCategory(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, NoteCategory>> call(NoteCategory category) =>
      repository.createCategory(category);
}

// ─── Delete Category ──────────────────────────────────────────────────────────
class DeleteCategory implements UseCase<bool, String> {
  DeleteCategory(this.repository);
  final NotesRepository repository;

  @override
  Future<Either<Failure, bool>> call(String id) =>
      repository.deleteCategory(id);
}
