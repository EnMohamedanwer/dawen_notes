import 'package:flutter/material.dart';
import '../../domain/entities/note_category.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.onDelete,          // null = تصنيف افتراضي لا يُحذف
    this.isHighlighted = false,
  });

  final NoteCategory category;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: ext.cardBg,
          borderRadius: BorderRadius.circular(15),
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
            // ── زر الحذف (يسار في RTL) ────────────────────────
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.importantColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.importantColor, size: 16),
                ),
              )
            else
              const SizedBox(width: 32),

            const SizedBox(width: 8),

            // ── عداد النوتات ──────────────────────────────────
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${category.noteCount}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: category.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── الاسم والوصف ─────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    category.name,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ext.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.noteCount} ملاحظة',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 12, color: ext.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── الأيقونة ─────────────────────────────────────
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(category.icon,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 8),

            // ── شريط اللون ────────────────────────────────────
            Container(
              width: 4, height: 50,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
