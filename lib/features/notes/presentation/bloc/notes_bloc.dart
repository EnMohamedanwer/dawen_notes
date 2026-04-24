import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/notes_usecases.dart';
import '../../../../core/utils/use_case.dart';
import 'notes_event_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({
    required this.getAllNotes,
    required this.getNotesByCategory,
    required this.getFavoriteNotes,
    required this.searchNotes,
    required this.createNote,
    required this.updateNote,
    required this.deleteNote,
    required this.toggleFavorite,
    required this.toggleArchive,
    required this.getCategories,
    required this.createCategory,
    required this.deleteCategory,
  }) : super(const NotesInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<LoadNotesByCategoryEvent>(_onLoadByCategory);
    on<LoadFavoriteNotesEvent>(_onLoadFavorites);
    on<LoadArchivedNotesEvent>(_onLoadArchived);
    on<SearchNotesEvent>(_onSearch);
    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<ToggleArchiveEvent>(_onToggleArchive);
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  final GetAllNotes getAllNotes;
  final GetNotesByCategory getNotesByCategory;
  final GetFavoriteNotes getFavoriteNotes;
  final SearchNotes searchNotes;
  final CreateNote createNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;
  final ToggleFavorite toggleFavorite;
  final ToggleArchive toggleArchive;
  final GetCategories getCategories;
  final CreateCategory createCategory;
  final DeleteCategory deleteCategory;

  // ── helpers ──────────────────────────────────────────────────────────────
  Future<void> _onLoadNotes(LoadNotesEvent e, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final notesRes = await getAllNotes(NoParams());
    final catsRes  = await getCategories(NoParams());
    notesRes.fold(
      (f) => emit(NotesError(f.message)),
      (notes) => catsRes.fold(
        (f) => emit(NotesError(f.message)),
        (cats) {
          final now = DateTime.now();
          final today = notes.where((n) =>
              n.createdAt.year == now.year &&
              n.createdAt.month == now.month &&
              n.createdAt.day == now.day).length;
          emit(NotesLoaded(
            notes: notes, categories: cats, todayCount: today,
            viewContext: NotesViewContext.all,
          ));
        },
      ),
    );
  }

  Future<void> _onLoadByCategory(
      LoadNotesByCategoryEvent e, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final res  = await getNotesByCategory(e.categoryId);
    final catsRes = await getCategories(NoParams());
    res.fold(
      (f) => emit(NotesError(f.message)),
      (notes) => catsRes.fold(
        (f) => emit(NotesError(f.message)),
        (cats) => emit(NotesLoaded(
          notes: notes, categories: cats,
          viewContext: NotesViewContext.byCategory,
          activeCategoryId: e.categoryId,
        )),
      ),
    );
  }

  Future<void> _onLoadFavorites(
      LoadFavoriteNotesEvent e, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final res = await getFavoriteNotes(NoParams());
    final catsRes = await getCategories(NoParams());
    res.fold(
      (f) => emit(NotesError(f.message)),
      (notes) => catsRes.fold(
        (f) => emit(NotesError(f.message)),
        (cats) => emit(NotesLoaded(
          notes: notes, categories: cats,
          viewContext: NotesViewContext.favorites,
        )),
      ),
    );
  }

  Future<void> _onLoadArchived(
      LoadArchivedNotesEvent e, Emitter<NotesState> emit) async {
    emit(const NotesLoading());
    final res = await getFavoriteNotes(NoParams());
    final catsRes = await getCategories(NoParams());
    // استخدام getArchivedNotes عبر getAllNotes لأنه مش موجود في usecases هنا
    final archivedRes = await getAllNotes(NoParams()); // سيُفلتر في الـ datasource
    archivedRes.fold(
      (f) => emit(NotesError(f.message)),
      (notes) => catsRes.fold(
        (f) => emit(NotesError(f.message)),
        (cats) => emit(NotesLoaded(
          notes: notes, categories: cats,
          viewContext: NotesViewContext.archived,
        )),
      ),
    );
  }

  Future<void> _onSearch(SearchNotesEvent e, Emitter<NotesState> emit) async {
    if (e.query.isEmpty) { add(const LoadNotesEvent()); return; }
    final res = await searchNotes(e.query);
    final catsRes = await getCategories(NoParams());
    res.fold(
      (f) => emit(NotesError(f.message)),
      (notes) => catsRes.fold(
        (f) => emit(NotesError(f.message)),
        (cats) => emit(NotesLoaded(
          notes: notes, categories: cats,
          viewContext: NotesViewContext.search,
        )),
      ),
    );
  }

  Future<void> _onCreateNote(CreateNoteEvent e, Emitter<NotesState> emit) async {
    final res = await createNote(e.note);
    res.fold(
      (f) => emit(NotesError(f.message)),
      (_) {
        emit(const NoteOperationSuccess('تم إنشاء الملاحظة بنجاح'));
        add(const LoadNotesEvent());
      },
    );
  }

  Future<void> _onUpdateNote(UpdateNoteEvent e, Emitter<NotesState> emit) async {
    final res = await updateNote(e.note);
    res.fold(
      (f) => emit(NotesError(f.message)),
      (_) {
        emit(const NoteOperationSuccess('تم تحديث الملاحظة بنجاح'));
        // ارجع لنفس الـ view الحالي
        _reloadCurrentView(emit, e);
      },
    );
  }

  /// ── حذف النوتة والبقاء في نفس الـ view ─────────────────────────────────
  Future<void> _onDeleteNote(DeleteNoteEvent e, Emitter<NotesState> emit) async {
    final res = await deleteNote(e.id);
    res.fold(
      (f) => emit(NotesError(f.message)),
      (_) async {
        emit(const NoteOperationSuccess('تم حذف الملاحظة'));
        // أعد تحميل نفس الـ view الذي كان المستخدم فيه
        switch (e.viewContext) {
          case NotesViewContext.byCategory:
            if (e.categoryId != null) {
              add(LoadNotesByCategoryEvent(e.categoryId!));
            } else {
              add(const LoadNotesEvent());
            }
            break;
          case NotesViewContext.favorites:
            add(const LoadFavoriteNotesEvent());
            break;
          case NotesViewContext.archived:
            add(const LoadArchivedNotesEvent());
            break;
          case NotesViewContext.all:
          case NotesViewContext.search:
          default:
            add(const LoadNotesEvent());
        }
      },
    );
  }

  Future<void> _onToggleFavorite(
      ToggleFavoriteEvent e, Emitter<NotesState> emit) async {
    await toggleFavorite(e.id);
    // حافظ على الـ view الحالي
    final current = state;
    if (current is NotesLoaded) {
      switch (current.viewContext) {
        case NotesViewContext.byCategory:
          add(LoadNotesByCategoryEvent(current.activeCategoryId!));
          break;
        case NotesViewContext.favorites:
          add(const LoadFavoriteNotesEvent());
          break;
        default:
          add(const LoadNotesEvent());
      }
    } else {
      add(const LoadNotesEvent());
    }
  }

  Future<void> _onToggleArchive(
      ToggleArchiveEvent e, Emitter<NotesState> emit) async {
    await toggleArchive(e.id);
    add(const LoadNotesEvent());
  }

  Future<void> _onLoadCategories(
      LoadCategoriesEvent e, Emitter<NotesState> emit) async {
    final res = await getCategories(NoParams());
    res.fold(
      (f) => emit(NotesError(f.message)),
      (cats) => emit(CategoriesLoaded(cats)),
    );
  }

  Future<void> _onCreateCategory(
      CreateCategoryEvent e, Emitter<NotesState> emit) async {
    final res = await createCategory(e.category);
    res.fold(
      (f) => emit(NotesError(f.message)),
      (_) => add(const LoadCategoriesEvent()),
    );
  }

  Future<void> _onDeleteCategory(
      DeleteCategoryEvent e, Emitter<NotesState> emit) async {
    final res = await deleteCategory(e.id);
    res.fold(
      (f) => emit(NotesError(f.message)),
      (_) => add(const LoadCategoriesEvent()),
    );
  }

  void _reloadCurrentView(Emitter<NotesState> emit, NotesEvent e) {
    final current = state;
    if (current is NotesLoaded) {
      switch (current.viewContext) {
        case NotesViewContext.byCategory:
          add(LoadNotesByCategoryEvent(current.activeCategoryId!));
          break;
        case NotesViewContext.favorites:
          add(const LoadFavoriteNotesEvent());
          break;
        default:
          add(const LoadNotesEvent());
      }
    } else {
      add(const LoadNotesEvent());
    }
  }
}
