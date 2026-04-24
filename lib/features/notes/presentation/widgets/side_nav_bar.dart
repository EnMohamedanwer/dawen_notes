import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum NavItem { home, notes, categories, favorites, trash, settings }

class SideNavBar extends StatelessWidget {
  const SideNavBar({
    super.key,
    required this.selected,
    required this.onItemSelected,
  });

  final NavItem selected;
  final ValueChanged<NavItem> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          _NavIcon(
            icon: Icons.home_rounded,
            item: NavItem.home,
            selected: selected,
            onTap: onItemSelected,
          ),
          _NavIcon(
            icon: Icons.category_rounded,
            item: NavItem.categories,
            selected: selected,
            onTap: onItemSelected,
          ),
          _NavIcon(
            icon: Icons.star_rounded,
            item: NavItem.favorites,
            selected: selected,
            onTap: onItemSelected,
          ),
          const Spacer(),
          _NavIcon(
            icon: Icons.settings_rounded,
            item: NavItem.settings,
            selected: selected,
            onTap: onItemSelected,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final NavItem item;
  final NavItem selected;
  final ValueChanged<NavItem> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == item;
    return GestureDetector(
      onTap: () => onTap(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected
              ? AppColors.primaryStart
              : Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
