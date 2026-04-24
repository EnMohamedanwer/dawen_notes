import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/theme_cubit.dart';
import 'core/services/permission_service.dart';
import 'core/services/image_service.dart';
import 'core/services/lock_service.dart';
import 'features/notes/data/datasources/notes_local_datasource.dart';
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/domain/repositories/notes_repository.dart';
import 'features/notes/domain/usecases/notes_usecases.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/profile/data/datasources/profile_local_datasource.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/profile_usecases.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // ── Services ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => PermissionService());
  sl.registerLazySingleton(() => ImageService(sl()));
  sl.registerLazySingleton(() => LockService(sl()));

  // ── Core ──────────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => ThemeCubit(sl()));

  // ── Notes Data ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NotesLocalDataSource>(
      () => NotesLocalDataSourceImpl());
  sl.registerLazySingleton<NotesRepository>(
      () => NotesRepositoryImpl(sl()));

  // ── Notes Use Cases ───────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetAllNotes(sl()));
  sl.registerLazySingleton(() => GetNotesByCategory(sl()));
  sl.registerLazySingleton(() => GetFavoriteNotes(sl()));
  sl.registerLazySingleton(() => SearchNotes(sl()));
  sl.registerLazySingleton(() => CreateNote(sl()));
  sl.registerLazySingleton(() => UpdateNote(sl()));
  sl.registerLazySingleton(() => DeleteNote(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => ToggleArchive(sl()));
  sl.registerLazySingleton(() => GetCategories(sl()));
  sl.registerLazySingleton(() => CreateCategory(sl()));
  sl.registerLazySingleton(() => DeleteCategory(sl()));

  // ── Notes BLoC ────────────────────────────────────────────────────────────
  sl.registerFactory(() => NotesBloc(
        getAllNotes: sl(), getNotesByCategory: sl(),
        getFavoriteNotes: sl(), searchNotes: sl(),
        createNote: sl(), updateNote: sl(), deleteNote: sl(),
        toggleFavorite: sl(), toggleArchive: sl(),
        getCategories: sl(), createCategory: sl(),
        deleteCategory: sl(),
      ));

  // ── Profile ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl());
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => SaveProfile(sl()));
  sl.registerFactory(() => ProfileCubit(
        getProfile: sl(), saveProfile: sl()));
}
