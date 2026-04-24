import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event_state.dart';
import '../widgets/note_card.dart';
import '../widgets/side_nav_bar.dart';
import 'note_editor_page.dart';
import 'categories_page.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_category.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/gradient_widgets.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../../core/services/lock_service.dart';
import '../../../../injection_container.dart';
import '../../../lock/presentation/widgets/pin_pad.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  NavItem _selectedNav = NavItem.home;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  UserProfile _extractProfile(ProfileState s) {
    if (s is ProfileLoaded) return s.profile;
    if (s is ProfileSaved) return s.profile;
    return UserProfile.empty;
  }

  void _onNavSelected(NavItem item) {
    setState(() => _selectedNav = item);
    final bloc = context.read<NotesBloc>();
    switch (item) {
      case NavItem.home:
      case NavItem.notes:
        bloc.add(const LoadNotesEvent());
        break;
      case NavItem.favorites:
        bloc.add(const LoadFavoriteNotesEvent());
        break;
      case NavItem.trash:
        bloc.add(const LoadArchivedNotesEvent());
        break;
      case NavItem.categories:
        bloc.add(const LoadCategoriesEvent());
        break;
      case NavItem.settings:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        ).then((_) {
          if (mounted) context.read<ProfileCubit>().loadProfile();
        });
        setState(() => _selectedNav = NavItem.home);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Row(
            children: [
              SideNavBar(
                  selected: _selectedNav,
                  onItemSelected: _onNavSelected),
              Expanded(
                child: BlocConsumer<NotesBloc, NotesState>(
                  listener: (ctx, state) {
                    if (state is NoteOperationSuccess) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.personalColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                    }
                    if (state is NotesError) {
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                  builder: (ctx, state) {
                    if (_selectedNav == NavItem.categories) {
                      return CategoriesPage(
                          onBack: () => _onNavSelected(NavItem.home));
                    }
                    if (state is NotesLoading) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (state is NotesLoaded) {
                      return _buildMain(ctx, state, ext);
                    }
                    return const Center(
                        child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openEditor(context, null),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: GradientContainer(
            borderRadius: BorderRadius.circular(30),
            padding: const EdgeInsets.all(14),
            child: const Icon(Icons.add_rounded,
                color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildMain(
      BuildContext context, NotesLoaded state, AppThemeExtension ext) {
    return Column(
      children: [
        _buildHeader(context, state, ext),
        _buildSearchBar(context, ext),
        _buildStats(context, state, ext),
        Expanded(child: _buildNotesList(context, state, ext)),
      ],
    );
  }

  Widget _buildHeader(
      BuildContext context, NotesLoaded state, AppThemeExtension ext) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, ps) {
        final profile = _extractProfile(ps);
        final name = profile.name.trim().isNotEmpty
            ? profile.name.trim()
            : 'مستخدم';
        final letter = name[0].toUpperCase();

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          color: ext.navBarBg,
          child: Row(children: [
            _buildAvatar(profile, letter),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: ext.textPrimary)),
              Text('مرحباً بك اليوم',
                  style:
                      TextStyle(fontSize: 12, color: ext.textHint)),
            ]),
            const Spacer(),
            Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                    color: ext.inputBg, shape: BoxShape.circle),
                child: const Icon(
                    Icons.notifications_outlined, size: 20),
              ),
              Positioned(
                top: 2, left: 2,
                child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                ),
              ),
            ]),
          ]),
        );
      },
    );
  }

  Widget _buildAvatar(UserProfile p, String letter) {
    if (p.hasAvatar) {
      return ClipOval(
        child: Image.file(File(p.avatarPath),
            width: 48, height: 48, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _letterAvatar(letter)),
      );
    }
    return _letterAvatar(letter);
  }

  Widget _letterAvatar(String l) => GradientContainer(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: 48, height: 48,
          child: Center(
            child: Text(l,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
        ),
      );

  Widget _buildSearchBar(BuildContext context, AppThemeExtension ext) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        controller: _searchController,
        textAlign: TextAlign.right,
        onChanged: (q) =>
            context.read<NotesBloc>().add(SearchNotesEvent(q)),
        decoration: InputDecoration(
          hintText: 'ابحث عن ملاحظة...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.primaryStart),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<NotesBloc>()
                        .add(const LoadNotesEvent());
                  })
              : null,
        ),
      ),
    );
  }

  Widget _buildStats(
      BuildContext context, NotesLoaded state, AppThemeExtension ext) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(children: [
        Expanded(
          child: _StatCard(
            label: 'إجمالي الملاحظات',
            value: state.notes.length.toString(),
            useGradient: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'جديد اليوم',
            value: state.todayCount.toString(),
            color: AppColors.workColor,
          ),
        ),
      ]),
    );
  }

  Widget _buildNotesList(
      BuildContext context, NotesLoaded state, AppThemeExtension ext) {
    if (state.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📝', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text('لا توجد ملاحظات بعد',
                style: TextStyle(
                    fontSize: 16, color: ext.textSecondary)),
            const SizedBox(height: 8),
            Text('اضغط + لإضافة ملاحظة جديدة',
                style: TextStyle(fontSize: 13, color: ext.textHint)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text('الملاحظات الأخيرة',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ext.textPrimary)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.notes.length,
            itemBuilder: (ctx, i) {
              final note = state.notes[i];
              final cat = state.categories
                  .cast<NoteCategory?>()
                  .firstWhere((c) => c?.id == note.categoryId,
                      orElse: () => null);
              return NoteCard(
                note: note,
                category: cat,
                onTap: () => _handleNoteTap(ctx, note, state),
                onDelete: () => context.read<NotesBloc>().add(
                      DeleteNoteEvent(
                        note.id,
                        viewContext: state.viewContext,
                        categoryId: state.activeCategoryId,
                      ),
                    ),
                onToggleFavorite: () => context
                    .read<NotesBloc>()
                    .add(ToggleFavoriteEvent(note.id)),
                onToggleArchive: () => context
                    .read<NotesBloc>()
                    .add(ToggleArchiveEvent(note.id)),
                onToggleLock: () =>
                    _handleToggleLock(ctx, note, state),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── فتح النوتة: تحقق من القفل أولاً ─────────────────────────────────────
  void _handleNoteTap(
      BuildContext context, Note note, NotesLoaded state) async {
    if (note.isLocked && note.notePin.isNotEmpty) {
      final unlocked = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PinPadDialog(
          title: 'ملاحظة محمية',
          subtitle: 'أدخل الـ PIN لفتح الملاحظة',
          onVerify: (pin) => pin == note.notePin,
        ),
      );
      if (unlocked != true) return;
    }
    if (mounted) _openEditor(context, note);
  }

  // ── تفعيل/إلغاء قفل النوتة ──────────────────────────────────────────────
  void _handleToggleLock(
      BuildContext context, Note note, NotesLoaded state) async {
    if (note.isLocked) {
      // تحقق من الـ PIN أولاً قبل الإزالة
      if (note.notePin.isNotEmpty) {
        final ok = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PinPadDialog(
            title: 'إزالة القفل',
            subtitle: 'أدخل الـ PIN الحالي',
            onVerify: (pin) => pin == note.notePin,
          ),
        );
        if (ok != true) return;
      }
      // إزالة القفل
      if (mounted) {
        context.read<NotesBloc>().add(
              UpdateNoteEvent(
                  note.copyWith(isLocked: false, notePin: '')),
            );
      }
    } else {
      // إنشاء PIN جديد للنوتة
      final pin = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PinPadDialog(
          title: 'قفل الملاحظة',
          subtitle: 'أدخل PIN من 4 أرقام',
          onVerify: (_) => true,
          confirmMode: true,
        ),
      );
      if (pin != null && pin.length == 4 && mounted) {
        context.read<NotesBloc>().add(
              UpdateNoteEvent(
                  note.copyWith(isLocked: true, notePin: pin)),
            );
      }
    }
  }

  void _openEditor(BuildContext context, Note? note) async {
    final categories =
        (context.read<NotesBloc>().state is NotesLoaded)
            ? (context.read<NotesBloc>().state as NotesLoaded).categories
            : <NoteCategory>[];

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NoteEditorPage(note: note, categories: categories),
      ),
    );
    if (mounted) {
      context.read<NotesBloc>().add(const LoadNotesEvent());
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      this.color,
      this.useGradient = false});
  final String label;
  final String value;
  final Color? color;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: ext.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: [
        useGradient
            ? GradientText(value,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold))
            : Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color)),
        const SizedBox(height: 4),
        Text(label,
            style:
                TextStyle(fontSize: 12, color: ext.textSecondary)),
      ]),
    );
  }
}
