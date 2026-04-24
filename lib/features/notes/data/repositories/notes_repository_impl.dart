import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_category.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_local_datasource.dart';
import '../models/note_model.dart';
import '../models/note_category_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl(this._localDataSource);

  final NotesLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, List<Note>>> getAllNotes() async {
    try {
      final notesModels = await _localDataSource.getAllNotes();
      // تحويل الـ List من Model لـ Entity
      return Right(notesModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> getNotesByCategory(
      String categoryId) async {
    try {
      final notesModels = await _localDataSource.getNotesByCategory(categoryId);
      return Right(notesModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> getFavoriteNotes() async {
    try {
      final notesModels = await _localDataSource.getFavoriteNotes();
      return Right(notesModels.map((model) => model .toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> getArchivedNotes() async {
    try {
      final notesModels = await _localDataSource.getArchivedNotes();
      return Right(notesModels.map((model) => model .toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Note>>> searchNotes(String query) async {
    try {
      final notesModels = await _localDataSource.searchNotes(query);
      return Right(notesModels.map((model) => model .toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Note>> getNoteById(String id) async {
    try {
      final noteModel = await _localDataSource.getNoteById(id);
      return Right(noteModel .toEntity()); // تحويل الـ Single object
    } catch (e) {
      return Left(NotFoundFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Note>> createNote(Note note) async {
    try {
      final model = NoteModel.fromEntity(note);
      final result = await _localDataSource.insertNote(model);
      return Right(result .toEntity());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Note>> updateNote(Note note) async {
    try {
      final model = NoteModel.fromEntity(note);
      final result = await _localDataSource.updateNote(model);
      return Right(result .toEntity());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  // الدوال اللي بترجع bool مش محتاجة تغيير لأن bool هو bool
  @override
  Future<Either<Failure, bool>> deleteNote(String id) async {
    try {
      final result = await _localDataSource.deleteNote(id);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite(String id) async {
    try {
      final result = await _localDataSource.toggleFavorite(id);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleArchive(String id) async {
    try {
      final result = await _localDataSource.toggleArchive(id);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NoteCategory>>> getCategories() async {
    try {
      final categoryModels = await _localDataSource.getCategories();
      return Right(
          categoryModels.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, NoteCategory>> createCategory(
      NoteCategory category) async {
    try {
      final model = NoteCategoryModel.fromEntity(category);
      final result = await _localDataSource.insertCategory(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(String id) async {
    try {
      final result = await _localDataSource.deleteCategory(id);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
