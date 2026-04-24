import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'core/services/lock_service.dart';
import 'features/notes/data/models/note_model.dart';
import 'features/notes/data/models/note_category_model.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';
import 'features/notes/presentation/bloc/notes_event_state.dart';
import 'features/notes/presentation/pages/home_page.dart';
import 'features/profile/data/models/user_profile_model.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/lock/presentation/pages/app_lock_page.dart';
import 'core/constants/hive_constants.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(NoteCategoryModelAdapter());
  Hive.registerAdapter(UserProfileModelAdapter());
  await Hive.openBox<NoteModel>(HiveBoxNames.notes);
  await Hive.openBox<NoteCategoryModel>(HiveBoxNames.categories);
  await Hive.openBox<UserProfileModel>(HiveBoxNames.userProfile);

  await initializeDateFormatting('ar', null);
  await di.init();

  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => di.sl<ThemeCubit>()),
        BlocProvider<NotesBloc>(
            create: (_) =>
                di.sl<NotesBloc>()..add(const LoadNotesEvent())),
        BlocProvider<ProfileCubit>(
            create: (_) => di.sl<ProfileCubit>()..loadProfile()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Notes_App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar')],
            themeMode: themeMode,
            locale: const Locale('ar'),
            // ── AppLock wrapper ──────────────────────────────────
            home: _AppLockWrapper(),
          );
        },
      ),
    );
  }
}

/// يعرض شاشة القفل لو مفعّل، وإلا يذهب مباشرة للـ HomePage
class _AppLockWrapper extends StatefulWidget {
  @override
  State<_AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends State<_AppLockWrapper>
    with WidgetsBindingObserver {
  late final LockService _lockService;
  bool _isLocked = false;
  // قفل التطبيق عند الخروج للخلفية
  DateTime? _backgroundTime;

  @override
  void initState() {
    super.initState();
    _lockService = di.sl<LockService>();
    _isLocked = _lockService.isAppLockEnabled;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backgroundTime = DateTime.now();
    }
    if (state == AppLifecycleState.resumed) {
      // أعد القفل إذا مر أكثر من 30 ثانية في الخلفية
      if (_backgroundTime != null) {
        final diff = DateTime.now().difference(_backgroundTime!);
        if (diff.inSeconds > 30 && _lockService.isAppLockEnabled) {
          setState(() => _isLocked = true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked && _lockService.isAppLockEnabled) {
      return AppLockPage(
        lockService: _lockService,
        onUnlocked: () => setState(() => _isLocked = false),
      );
    }
    return const HomePage();
  }
}
