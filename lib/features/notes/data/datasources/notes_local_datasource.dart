import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/note_model.dart';
import '../models/note_category_model.dart';

abstract class NotesLocalDataSource {
  Future<List<NoteModel>> getAllNotes();
  Future<List<NoteModel>> getNotesByCategory(String categoryId);
  Future<List<NoteModel>> getFavoriteNotes();
  Future<List<NoteModel>> getArchivedNotes();
  Future<List<NoteModel>> searchNotes(String query);
  Future<NoteModel> getNoteById(String id);
  Future<NoteModel> insertNote(NoteModel note);
  Future<NoteModel> updateNote(NoteModel note);
  Future<bool> deleteNote(String id);
  Future<bool> toggleFavorite(String id);
  Future<bool> toggleArchive(String id);

  Future<List<NoteCategoryModel>> getCategories();
  Future<NoteCategoryModel> insertCategory(NoteCategoryModel category);
  Future<bool> deleteCategory(String id);
}

class NotesLocalDataSourceImpl implements NotesLocalDataSource {
  Box<NoteModel> get _notesBox => Hive.box<NoteModel>(HiveBoxNames.notes);
  Box<NoteCategoryModel> get _catBox =>
      Hive.box<NoteCategoryModel>(HiveBoxNames.categories);

  // ── Notes ────────────────────────────────────────────────────────────────
  @override
  Future<List<NoteModel>> getAllNotes() async {
    final notes = _notesBox.values
        .where((n) => !n.isArchived)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<List<NoteModel>> getNotesByCategory(String categoryId) async {
    final notes = _notesBox.values
        .where((n) => n.categoryId == categoryId && !n.isArchived)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<List<NoteModel>> getFavoriteNotes() async {
    final notes = _notesBox.values
        .where((n) => n.isFavorite)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<List<NoteModel>> getArchivedNotes() async {
    final notes = _notesBox.values
        .where((n) => n.isArchived)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<List<NoteModel>> searchNotes(String query) async {
    final q = query.toLowerCase();
    final notes = _notesBox.values
        .where((n) =>
            !n.isArchived &&
            (n.title.toLowerCase().contains(q) ||
                n.contentJson.toLowerCase().contains(q)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  @override
  Future<NoteModel> getNoteById(String id) async {
    final note = _notesBox.get(id);
    if (note == null) throw Exception('Note not found: $id');
    return note;
  }

  @override
  Future<NoteModel> insertNote(NoteModel note) async {
    await _notesBox.put(note.id, note);
    return note;
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    await _notesBox.put(note.id, note);
    return note;
  }

  @override
  Future<bool> deleteNote(String id) async {
    await _notesBox.delete(id);
    return true;
  }

  @override
  Future<bool> toggleFavorite(String id) async {
    final note = await getNoteById(id);
    note.isFavorite = !note.isFavorite;
    await note.save();
    return note.isFavorite;
  }

  @override
  Future<bool> toggleArchive(String id) async {
    final note = await getNoteById(id);
    note.isArchived = !note.isArchived;
    await note.save();
    return note.isArchived;
  }

  // ── Categories ───────────────────────────────────────────────────────────
  @override
  Future<List<NoteCategoryModel>> getCategories() async {
    // Seed defaults if empty
    if (_catBox.isEmpty) {
      for (final cat in AppConstants.defaultCategories) {
        final model = NoteCategoryModel(
          id: cat['id'] as String,
          name: cat['name'] as String,
          icon: cat['icon'] as String,
          colorValue: cat['color'] as int,
        );
        await _catBox.put(model.id, model);
      }
    }

    // Attach note counts
    final cats = _catBox.values.toList();
    return cats.map((cat) {
      final count = _notesBox.values
          .where((n) => n.categoryId == cat.id && !n.isArchived)
          .length;
      return NoteCategoryModel(
        id: cat.id, name: cat.name,
        icon: cat.icon, colorValue: cat.colorValue,
        noteCount: count,
      );
    }).toList();
  }

  @override
  Future<NoteCategoryModel> insertCategory(NoteCategoryModel category) async {
    await _catBox.put(category.id, category);
    return category;
  }

  @override
  Future<bool> deleteCategory(String id) async {
    await _catBox.delete(id);
    return true;
  }
}
