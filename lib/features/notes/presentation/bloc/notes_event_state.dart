import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_category.dart';

// ─── View context (to reload correct screen after delete) ──────────────────
enum NotesViewContext { all, byCategory, favorites, archived, search }

// ─── Events ──────────────────────────────────────────────────────────────────
abstract class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotesEvent extends NotesEvent { const LoadNotesEvent(); }

class LoadNotesByCategoryEvent extends NotesEvent {
  const LoadNotesByCategoryEvent(this.categoryId);
  final String categoryId;
  @override List<Object?> get props => [categoryId];
}

class LoadFavoriteNotesEvent extends NotesEvent { const LoadFavoriteNotesEvent(); }
class LoadArchivedNotesEvent extends NotesEvent { const LoadArchivedNotesEvent(); }

class SearchNotesEvent extends NotesEvent {
  const SearchNotesEvent(this.query);
  final String query;
  @override List<Object?> get props => [query];
}

class CreateNoteEvent extends NotesEvent {
  const CreateNoteEvent(this.note);
  final Note note;
  @override List<Object?> get props => [note];
}

class UpdateNoteEvent extends NotesEvent {
  const UpdateNoteEvent(this.note);
  final Note note;
  @override List<Object?> get props => [note];
}

/// احذف النوتة وارجع لنفس الـ view الحالي
class DeleteNoteEvent extends NotesEvent {
  const DeleteNoteEvent(this.id, {this.viewContext = NotesViewContext.all, this.categoryId});
  final String id;
  final NotesViewContext viewContext;
  final String? categoryId;
  @override List<Object?> get props => [id, viewContext, categoryId];
}

class ToggleFavoriteEvent extends NotesEvent {
  const ToggleFavoriteEvent(this.id);
  final String id;
  @override List<Object?> get props => [id];
}

class ToggleArchiveEvent extends NotesEvent {
  const ToggleArchiveEvent(this.id);
  final String id;
  @override List<Object?> get props => [id];
}

class LoadCategoriesEvent extends NotesEvent { const LoadCategoriesEvent(); }

class CreateCategoryEvent extends NotesEvent {
  const CreateCategoryEvent(this.category);
  final NoteCategory category;
  @override List<Object?> get props => [category];
}

class DeleteCategoryEvent extends NotesEvent {
  const DeleteCategoryEvent(this.id);
  final String id;
  @override List<Object?> get props => [id];
}

// ─── States ──────────────────────────────────────────────────────────────────
abstract class NotesState extends Equatable {
  const NotesState();
  @override List<Object?> get props => [];
}

class NotesInitial extends NotesState { const NotesInitial(); }
class NotesLoading extends NotesState { const NotesLoading(); }

class NotesLoaded extends NotesState {
  const NotesLoaded({
    required this.notes,
    required this.categories,
    this.todayCount = 0,
    this.viewContext = NotesViewContext.all,
    this.activeCategoryId,
  });
  final List<Note> notes;
  final List<NoteCategory> categories;
  final int todayCount;
  final NotesViewContext viewContext;
  final String? activeCategoryId;

  @override
  List<Object?> get props =>
      [notes, categories, todayCount, viewContext, activeCategoryId];
}

class NoteOperationSuccess extends NotesState {
  const NoteOperationSuccess(this.message);
  final String message;
  @override List<Object?> get props => [message];
}

class NotesError extends NotesState {
  const NotesError(this.message);
  final String message;
  @override List<Object?> get props => [message];
}

class CategoriesLoaded extends NotesState {
  const CategoriesLoaded(this.categories);
  final List<NoteCategory> categories;
  @override List<Object?> get props => [categories];
}
