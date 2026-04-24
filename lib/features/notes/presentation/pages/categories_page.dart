import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event_state.dart';
import '../widgets/category_card.dart';
import '../../domain/entities/note_category.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/gradient_widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart' show Color;

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  static const _defaultIds = {'work', 'personal', 'ideas', 'shopping'};

  // ── Selection Mode ──────────────────────────────────────
  String? _selectedCatId;
  bool get _isSelectionMode => _selectedCatId != null;

  // ── Animation for bottom action bar ────────────────────
  late final AnimationController _barCtrl;
  late final Animation<Offset> _barAnim;

  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(const LoadCategoriesEvent());

    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _barAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _barCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _barCtrl.dispose();
    super.dispose();
  }

  void _selectCategory(String id) {
    setState(() => _selectedCatId = id);
    _barCtrl.forward();
  }

  void _clearSelection() {
    _barCtrl.reverse().then((_) {
      if (mounted) setState(() => _selectedCatId = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        final categories = state is CategoriesLoaded
            ? state.categories
            : state is NotesLoaded
                ? state.categories
                : <NoteCategory>[];

        final selectedCat = _selectedCatId == null
            ? null
            : categories.where((c) => c.id == _selectedCatId).firstOrNull;

        final isSelectedDefault =
            _selectedCatId != null && _defaultIds.contains(_selectedCatId);

        return GestureDetector(
          // ضغطة في الخلفية تلغي التحديد
          onTap: _isSelectionMode ? _clearSelection : null,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Header ──────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    color: _isSelectionMode
                        ? AppColors.primaryStart.withValues(alpha: 0.08)
                        : ext.navBarBg,
                    child: Row(
                      children: [
                        // زر إلغاء التحديد أو أيقونة الإعدادات
                        GestureDetector(
                          onTap: _isSelectionMode ? _clearSelection : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _isSelectionMode
                                  ? AppColors.primaryStart
                                      .withValues(alpha: 0.15)
                                  : ext.inputBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isSelectionMode
                                  ? Icons.close_rounded
                                  : Icons.tune_rounded,
                              color: AppColors.primaryStart,
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isSelectionMode ? 'تم التحديد' : 'أنواع الملاحظات',
                            key: ValueKey(_isSelectionMode),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ext.textPrimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: widget.onBack,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                color: ext.inputBg, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward_ios_rounded,
                                size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── All Notes Card ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: GestureDetector(
                      onTap: () {
                        if (_isSelectionMode) {
                          _clearSelection();
                          return;
                        }
                        context.read<NotesBloc>().add(const LoadNotesEvent());
                      },
                      child: GradientContainer(
                        borderRadius: BorderRadius.circular(18),
                        padding: const EdgeInsets.all(20),
                        child: Row(children: [
                          Text(
                            '${categories.fold<int>(0, (s, c) => s + c.noteCount)}',
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text('كل الملاحظات',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              SizedBox(height: 4),
                              Text('جميع ملاحظاتك في مكان واحد',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle),
                            child: const Center(
                                child:
                                    Text('📝', style: TextStyle(fontSize: 26))),
                          ),
                        ]),
                      ),
                    ),
                  ),

                  // ── Category List ────────────────────────────────
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      // padding سفلي عشان الـ action bar ما يغطيش آخر عنصر
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (ctx, i) {
                        final cat = categories[i];
                        final isDefault = _defaultIds.contains(cat.id);
                        final isSelected = _selectedCatId == cat.id;

                        return GestureDetector(
                          // ✅ ضغطة عادية: لو في selection mode تلغيه، لو لا تفتح القسم
                          onTap: () {
                            if (_isSelectionMode) {
                              _clearSelection();
                              return;
                            }
                            context
                                .read<NotesBloc>()
                                .add(LoadNotesByCategoryEvent(cat.id));
                          },
                          // ✅ ضغطة طويلة: تحدد القسم
                          onLongPress: () => _selectCategory(cat.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              // هايلايت للعنصر المحدد
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primaryStart,
                                      width: 2,
                                    )
                                  : Border.all(
                                      color: Colors.transparent,
                                      width: 2,
                                    ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryStart
                                            .withValues(alpha: 0.18),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            child: CategoryCard(
                              category: cat,
                              onTap:
                                  () {}, // onTap مُتحكَّم فيه من GestureDetector فوق
                              onDelete: isDefault
                                  ? null
                                  : () => _confirmDelete(context, cat),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Add Category ─────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: GestureDetector(
                      onTap: () => _showAddCategoryDialog(context),
                      child: DottedBorderContainer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_rounded,
                                color: AppColors.primaryStart, size: 20),
                            const SizedBox(width: 8),
                            Text('إضافة تصنيف جديد',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryStart)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Bottom Action Bar (يظهر عند التحديد) ────────────
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _barAnim,
                  child: _buildActionBar(
                    context,
                    selectedCat: selectedCat,
                    isDefault: isSelectedDefault,
                    ext: ext,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Action Bar ───────────────────────────────────────────────────────────
  Widget _buildActionBar(
    BuildContext context, {
    required NoteCategory? selectedCat,
    required bool isDefault,
    required AppThemeExtension ext,
  }) {
    if (selectedCat == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: ext.navBarBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── زر الحذف (فعّال فقط للأقسام غير الافتراضية) ────────
          Expanded(
            child: GestureDetector(
              onTap: isDefault
                  ? null
                  : () {
                      _clearSelection();
                      _confirmDelete(context, selectedCat);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDefault
                      ? Colors.red.withValues(alpha: 0.08)
                      : Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: isDefault
                          ? Colors.red.withValues(alpha: 0.35)
                          : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'حذف القسم',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDefault
                            ? Colors.red.withValues(alpha: 0.35)
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ── رسالة "محمي" لو كان افتراضياً ──────────────────────
          if (isDefault)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryStart.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        color: AppColors.primaryStart, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'قسم افتراضي',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primaryStart,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // ── زر إلغاء التحديد ───────────────────────────────────
            Expanded(
              child: GestureDetector(
                onTap: _clearSelection,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: ext.inputBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close_rounded,
                          color: ext.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ext.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Confirm Delete Dialog ────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, NoteCategory cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('حذف "${cat.name}"', style: const TextStyle(fontSize: 17)),
            const SizedBox(width: 8),
            Text(cat.icon, style: const TextStyle(fontSize: 22)),
          ],
        ),
        content: Text(
          'سيتم حذف التصنيف "${cat.name}" نهائياً.\nالملاحظات المرتبطة به لن تُحذف.',
          textAlign: TextAlign.end,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(_);
              context.read<NotesBloc>().add(DeleteCategoryEvent(cat.id));
            },
            child: const Text('حذف',
                style: TextStyle(color: AppColors.importantColor)),
          ),
        ],
      ),
    );
  }

  // ── Add Category Dialog ──────────────────────────────────────────────────
  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String selectedIcon = '📌';
    int selectedColor = AppColors.primaryStart.value;

    final icons = ['📌', '🏆', '💰', '🎯', '📚', '🎨', '🏋️', '🌿'];
    final colors = [
      AppColors.workColor.value,
      AppColors.personalColor.value,
      AppColors.ideasColor.value,
      AppColors.shoppingColor.value,
      AppColors.importantColor.value,
      AppColors.primaryStart.value,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('تصنيف جديد', textAlign: TextAlign.end),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                textAlign: TextAlign.end,
                decoration: const InputDecoration(hintText: 'اسم التصنيف'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: icons
                    .map((ic) => GestureDetector(
                          onTap: () => setS(() => selectedIcon = ic),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              border: selectedIcon == ic
                                  ? Border.all(
                                      color: AppColors.primaryStart, width: 2)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                Text(ic, style: const TextStyle(fontSize: 22)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: colors
                    .map((c) => GestureDetector(
                          onTap: () => setS(() => selectedColor = c),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: selectedColor == c
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                context.read<NotesBloc>().add(
                      CreateCategoryEvent(NoteCategory(
                        id: const Uuid().v4(),
                        name: nameCtrl.text.trim(),
                        icon: selectedIcon,
                        color: Color(selectedColor),
                      )),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DottedBorderContainer ────────────────────────────────────────────────────
class DottedBorderContainer extends StatelessWidget {
  const DottedBorderContainer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        width: double.infinity,
        child: child,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryStart
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 5.0, dashSpace = 4.0;
    final borderRadius = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(25),
    );
    final path = Path()..addRRect(borderRadius);
    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
            metric.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
