import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notes_app/features/settings/presentation/pages/about_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/gradient_widgets.dart';
import '../../../../core/services/lock_service.dart';
import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/pages/edit_profile_page.dart';
import '../widgets/app_lock_tile.dart';
import '../../../../injection_container.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  UserProfile _extractProfile(ProfileState s) {
    if (s is ProfileLoaded) return s.profile;
    if (s is ProfileSaved) return s.profile;
    return UserProfile.empty;
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context, ext),
          Expanded(
            child: BlocBuilder<ProfileCubit, ProfileState>(
              builder: (ctx, ps) {
                final profile = _extractProfile(ps);
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildProfileCard(context, profile, ext),
                      SizedBox(height: 20.h),
                      _sectionTitle('إعدادات الحساب', ext),
                      SizedBox(height: 8.h),
                      _settingItem(
                        context: context,
                        ext: ext,
                        icon: Icons.person_outline_rounded,
                        iconBg: const Color(0xFFE8EAF6),
                        iconColor: AppColors.primaryStart,
                        title: 'معلومات الحساب',
                        subtitle: 'الاسم، البريد، الصورة',
                        onTap: () => _openEditProfile(context, profile),
                      ),
                      // _settingItem(
                      //   context: context, ext: ext,
                      //   icon: Icons.lock_outline_rounded,
                      //   iconBg: const Color(0xFFFFF3E0),
                      //   iconColor: AppColors.workColor,
                      //   title: 'الأمان والخصوصية',
                      //   subtitle: 'كلمة المرور، المصادقة',
                      //   onTap: () {},
                      // ),
                      const SizedBox(height: 20),
                      _sectionTitle('إعدادات التطبيق', ext),
                      const SizedBox(height: 8),
                      // ── قفل التطبيق ─────────────────────────────
                      // AppLockTile(lockService: sl<LockService>()),
                      // ── الوضع الليلي ─────────────────────────────
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (_, themeMode) {
                          final isDark = themeMode == ThemeMode.dark;
                          return _toggleItem(
                            context: context,
                            ext: ext,
                            icon: Icons.dark_mode_rounded,
                            iconBg: const Color(0xFFE8F5E9),
                            iconColor: AppColors.personalColor,
                            title: 'الوضع الليلي',
                            subtitle: isDark ? 'مظلم' : 'فاتح',
                            value: isDark,
                            onChanged: (_) =>
                                context.read<ThemeCubit>().toggle(),
                          );
                        },
                      ),
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        builder: (_, tm) => _settingItem(
                          context: context,
                          ext: ext,
                          icon: Icons.palette_outlined,
                          iconBg: const Color(0xFFF3E5F5),
                          iconColor: AppColors.ideasColor,
                          title: 'المظهر',
                          subtitle: _themeLabel(tm),
                          onTap: () => _showThemePicker(
                              context, context.read<ThemeCubit>()),
                        ),
                      ),
                      // _settingItem(
                      //   context: context, ext: ext,
                      //   icon: Icons.notifications_outlined,
                      //   iconBg: const Color(0xFFF3E5F5),
                      //   iconColor: AppColors.ideasColor,
                      //   title: 'الإشعارات',
                      //   subtitle: 'تنبيهات وتذكيرات',
                      //   onTap: () {},
                      // ),
                      _settingItem(
                        context: context,
                        ext: ext,
                        icon: Icons.backup_outlined,
                        iconBg: const Color(0xFFE1F5FE),
                        iconColor: AppColors.shoppingColor,
                        title: 'النسخ الاحتياطي',
                        subtitle: 'حفظ واستعادة البيانات',
                        onTap: () {},
                      ),
                      SizedBox(height: 20.h),
                      _sectionTitle('أخرى', ext),
                      SizedBox(height: 8.h),
                      Row(children: [
                        // Expanded(child: _smallCard(
                        //   icon: Icons.logout_rounded,
                        //   iconBg: const Color(0xFFFFEBEE),
                        //   iconColor: AppColors.importantColor,
                        //   title: 'تسجيل خروج',
                        //   isDestructive: true,
                        //   onTap: () => _showLogoutDialog(context),
                        //   ext: ext,
                        // )),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _smallCard(
                          icon: Icons.info_outline_rounded,
                          iconBg: const Color(0xFFFFF3E0),
                          iconColor: AppColors.workColor,
                          title: 'حول التطبيق',
                          subtitle: 'v 1.4.2',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AboutPage()),
                            );
                          },
                          ext: ext,
                        )),
                      ]),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _openEditProfile(BuildContext ctx, UserProfile p) async {
    await Navigator.push(
        ctx,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: ctx.read<ProfileCubit>(),
            child: EditProfilePage(profile: p),
          ),
        ));
    if (mounted) context.read<ProfileCubit>().loadProfile();
  }

  String _themeLabel(ThemeMode m) {
    switch (m) {
      case ThemeMode.dark:
        return 'مظلم';
      case ThemeMode.system:
        return 'تلقائي';
      default:
        return 'فاتح';
    }
  }

  Widget _buildHeader(BuildContext ctx, AppThemeExtension ext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: ext.navBarBg,
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
          child: Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(color: ext.inputBg, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_ios_rounded, size: 18)),
        ),
        const Spacer(),
        Text('الإعدادات',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ext.textPrimary)),
        const Spacer(),
        const SizedBox(width: 40),
      ]),
    );
  }

  Widget _buildProfileCard(
      BuildContext ctx, UserProfile p, AppThemeExtension ext) {
    final letter =
        p.name.trim().isNotEmpty ? p.name.trim()[0].toUpperCase() : '؟';
    return GestureDetector(
      onTap: () => _openEditProfile(ctx, p),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ext.cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(children: [
          Text('تعديل الملف ←',
              style: TextStyle(fontSize: 12, color: AppColors.primaryStart)),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(p.name,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: ext.textPrimary)),
            const SizedBox(height: 4),
            Text(p.email, style: TextStyle(fontSize: 12, color: ext.textHint)),
            if (p.phone.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(p.phone,
                  style: TextStyle(fontSize: 12, color: ext.textHint)),
            ],
          ]),
          const SizedBox(width: 16),
          Stack(children: [
            ClipOval(
              child: p.hasAvatar
                  ? Image.file(File(p.avatarPath),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _letterAvatar(letter, 70, 30))
                  : _letterAvatar(letter, 70, 30),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: GradientContainer(
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: Icon(Icons.edit_rounded,
                        color: Colors.white, size: 13)),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _letterAvatar(String l, double size, double fs) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient, shape: BoxShape.circle),
      child: Center(
          child: Text(l,
              style: TextStyle(
                  fontSize: fs,
                  fontWeight: FontWeight.bold,
                  color: Colors.white))),
    );
  }

  Widget _sectionTitle(String t, AppThemeExtension ext) => Text(t,
      textAlign: TextAlign.end,
      style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: ext.textSecondary));

  Widget _settingItem({
    required BuildContext context,
    required AppThemeExtension ext,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: ext.cardBg,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1))
          ],
        ),
        child: Row(children: [
          Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: ext.textHint),
          const Spacer(),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title, style: TextStyle(fontSize: 15, color: ext.textPrimary)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: ext.textHint)),
          ]),
          const SizedBox(width: 12),
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20)),
        ]),
      ),
    );
  }

  Widget _toggleItem({
    required BuildContext context,
    required AppThemeExtension ext,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ext.cardBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(children: [
        Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryStart),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(title, style: TextStyle(fontSize: 15, color: ext.textPrimary)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: ext.textHint)),
        ]),
        const SizedBox(width: 12),
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20)),
      ]),
    );
  }

  Widget _smallCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    required AppThemeExtension ext,
    String subtitle = '',
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ext.cardBg,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1))
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDestructive
                        ? AppColors.importantColor
                        : ext.textPrimary)),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: TextStyle(fontSize: 11, color: ext.textHint)),
          ]),
          const SizedBox(width: 12),
          Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18)),
        ]),
      ),
    );
  }

  void _showThemePicker(BuildContext ctx, ThemeCubit cubit) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('اختر المظهر',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
              onTap: () {
                cubit.setLight();
                Navigator.pop(_);
              },
              leading: const Icon(Icons.light_mode_rounded),
              title: const Text('فاتح'),
              trailing: cubit.state == ThemeMode.light
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.primaryStart)
                  : null),
          ListTile(
              onTap: () {
                cubit.setDark();
                Navigator.pop(_);
              },
              leading: const Icon(Icons.dark_mode_rounded),
              title: const Text('مظلم'),
              trailing: cubit.state == ThemeMode.dark
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.primaryStart)
                  : null),
          ListTile(
              onTap: () {
                cubit.setSystem();
                Navigator.pop(_);
              },
              leading: const Icon(Icons.settings_suggest_rounded),
              title: const Text('تلقائي (حسب النظام)'),
              trailing: cubit.state == ThemeMode.system
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.primaryStart)
                  : null),
        ]),
      ),
    );
  }
}
