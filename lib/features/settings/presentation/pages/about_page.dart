import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, ext),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildAppLogo(ext),
                    const SizedBox(height: 32),
                    _buildInfoCard(ext),
                    const SizedBox(height: 20),
                    _buildDeveloperCard(ext),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context, AppThemeExtension ext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ext.navBarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ext.inputBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ),
          ),
          const Spacer(),
          Text(
            'حول التطبيق',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ext.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── App Logo & Name ────────────────────────────────────────────────────────
  Widget _buildAppLogo(AppThemeExtension ext) {
    return Column(
      children: [
        // أيقونة التطبيق مع gradient
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryStart.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            'Dawen Notes',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'v1.0.0',
          style: TextStyle(
            fontSize: 13,
            color: ext.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── App Description Card ───────────────────────────────────────────────────
  Widget _buildInfoCard(AppThemeExtension ext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ext.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'عن التطبيق',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ext.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryStart.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryStart,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryStart.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Dawen Notes is a clean and powerful note-taking app that helps you capture ideas, organize your thoughts, and stay productive.',
            textAlign: TextAlign.left,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: ext.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Designed with simplicity in mind to help you stay focused and productive.',
            textAlign: TextAlign.left,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 14,
              height: 1.7,
              color: ext.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Developer Card ─────────────────────────────────────────────────────────
  Widget _buildDeveloperCard(AppThemeExtension ext) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ext.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // معلومات المطور
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Mohamed Anwar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ext.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'المطور',
                  style: TextStyle(
                    fontSize: 13,
                    color: ext.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // أفاتار المطور
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryStart.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}