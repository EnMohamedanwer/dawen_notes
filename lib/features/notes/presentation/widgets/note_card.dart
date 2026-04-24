import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_category.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.category,
    required this.onTap,
    this.onDelete,
    this.onToggleFavorite,
    this.onToggleArchive,
    this.onToggleLock,
  });

  final Note note;
  final NoteCategory? category;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onToggleArchive;
  final VoidCallback? onToggleLock;

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    return DateFormat('d MMM', 'ar').format(dt);
  }

  // ✅ تنظيف نص Quill Delta من كلمة "insert" والمسافات الزائدة
  String _cleanPreview(String raw) {
    return raw
        .replaceAll(RegExp(r'\binsert\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s{2,}'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final catColor = category?.color ?? const Color(0xFF667EEA);

    return Directionality(
      textDirection: ui.TextDirection.rtl, // ✅ دعم RTL
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: ext.cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ✅ قائمة الخيارات على اليسار
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: ext.textHint, size: 18),
                onSelected: (v) {
                  if (v == 'delete') onDelete?.call();
                  if (v == 'favorite') onToggleFavorite?.call();
                  if (v == 'archive') onToggleArchive?.call();
                  if (v == 'lock') onToggleLock?.call();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'favorite',
                    child: Row(children: [
                      Icon(
                          note.isFavorite
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 18),
                      const SizedBox(width: 8),
                      Text(note.isFavorite
                          ? 'إزالة من المفضلة'
                          : 'إضافة للمفضلة'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'lock',
                    child: Row(children: [
                      Icon(
                          note.isLocked
                              ? Icons.lock_open_rounded
                              : Icons.lock_rounded,
                          color: AppColors.primaryStart,
                          size: 18),
                      const SizedBox(width: 8),
                      Text(note.isLocked ? 'إزالة القفل' : 'قفل الملاحظة'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(children: [
                      Icon(
                          note.isArchived
                              ? Icons.unarchive_rounded
                              : Icons.archive_rounded,
                          color: Colors.grey,
                          size: 18),
                      const SizedBox(width: 8),
                      Text(note.isArchived ? 'إلغاء الأرشفة' : 'أرشفة'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_outline_rounded,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red.shade600)),
                    ]),
                  ),
                ],
              ),

              // ✅ المحتوى في المنتصف
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // RTL = يبدأ من اليمين
                    children: [
                      // العنوان + أيقونات الحالة
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: ext.textPrimary,
                              ),
                            ),
                          ),
                          if (note.isLocked)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.lock_rounded,
                                  color: AppColors.primaryStart, size: 16),
                            ),
                          if (note.isFavorite)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 16),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ✅ معاينة المحتوى مع إزالة "insert"
                      Text(
                        note.isLocked
                            ? '🔒 الملاحظة محمية بكلمة مرور'
                            : _cleanPreview(note.plainText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: note.isLocked
                              ? AppColors.primaryStart
                              : ext.textSecondary,
                          fontStyle: note.isLocked
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // التاريخ + التصنيف
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (category != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${category!.icon} ${category!.name}',
                                style: TextStyle(fontSize: 11, color: catColor),
                              ),
                            ),
                          Text(
                            _formatDate(note.updatedAt),
                            style: TextStyle(fontSize: 11, color: ext.textHint),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ شريط اللون على اليمين
              Container(
                width: 5,
                height: 85,
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12), // ✅ يمين
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
