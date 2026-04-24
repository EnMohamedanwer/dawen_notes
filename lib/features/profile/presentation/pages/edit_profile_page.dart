import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/gradient_widgets.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/permission_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.profile});
  final UserProfile profile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;

  String _avatarPath = '';
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService(PermissionService());

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.profile.name);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(text: widget.profile.phone);
    _bioCtrl   = TextEditingController(text: widget.profile.bio);
    _avatarPath = widget.profile.avatarPath;

    // أعد بناء الـ avatar لحظياً لما يتغير الاسم
    _nameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  /// أول حرف من الاسم المكتوب حالياً
  String get _firstLetter {
    final name = _nameCtrl.text.trim();
    return name.isNotEmpty ? name[0].toUpperCase() : '؟';
  }

  Future<void> _pickAvatar() async {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    showModalBottomSheet(
      context: context,
      backgroundColor: ext.cardBg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 20),
              Text('تغيير الصورة الشخصية',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ext.textPrimary)),
              const SizedBox(height: 20),
              _PickerOption(
                icon: Icons.camera_alt_rounded,
                color: AppColors.primaryStart,
                label: 'التقاط صورة',
                onTap: () async {
                  Navigator.pop(context);
                  final path = await _imageService.pickFromCamera();
                  if (path != null && mounted) {
                    setState(() => _avatarPath = path);
                  }
                },
              ),
              const SizedBox(height: 12),
              _PickerOption(
                icon: Icons.photo_library_rounded,
                color: AppColors.ideasColor,
                label: 'من المعرض',
                onTap: () async {
                  Navigator.pop(context);
                  final path = await _imageService.pickFromGallery();
                  if (path != null && mounted) {
                    setState(() => _avatarPath = path);
                  }
                },
              ),
              if (_avatarPath.isNotEmpty) ...[
                const SizedBox(height: 12),
                _PickerOption(
                  icon: Icons.delete_outline_rounded,
                  color: AppColors.importantColor,
                  label: 'حذف الصورة',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _avatarPath = '');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updated = widget.profile.copyWith(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      avatarPath: _avatarPath,
    );

    await context.read<ProfileCubit>().save(updated);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return BlocListener<ProfileCubit, ProfileState>(
      listener: (ctx, state) {
        if (state is ProfileSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: const Text('✅  تم حفظ البيانات بنجاح'),
              backgroundColor: AppColors.personalColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(ctx, state.profile);
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.importantColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(ext),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildAvatarSection(ext),
                        const SizedBox(height: 32),
                        _buildSection(
                          title: 'المعلومات الأساسية',
                          ext: ext,
                          children: [
                            _buildField(
                              controller: _nameCtrl,
                              label: 'الاسم الكامل',
                              icon: Icons.person_outline_rounded,
                              ext: ext,
                              validator: (v) => v == null || v.isEmpty
                                  ? 'الاسم مطلوب'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _buildField(
                              controller: _emailCtrl,
                              label: 'البريد الإلكتروني',
                              icon: Icons.email_outlined,
                              ext: ext,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'البريد مطلوب';
                                if (!v.contains('@'))
                                  return 'بريد غير صحيح';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildField(
                              controller: _phoneCtrl,
                              label: 'رقم الهاتف',
                              icon: Icons.phone_outlined,
                              ext: ext,
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSection(
                          title: 'نبذة شخصية',
                          ext: ext,
                          children: [
                            _buildField(
                              controller: _bioCtrl,
                              label: 'اكتب نبذة عنك...',
                              icon: Icons.info_outline_rounded,
                              ext: ext,
                              maxLines: 4,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(AppThemeExtension ext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: ext.navBarBg,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration:
                BoxDecoration(color: ext.inputBg, shape: BoxShape.circle),
            child:
                const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ),
        ),
        const Spacer(),
        Text('تعديل الملف الشخصي',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ext.textPrimary)),
        const Spacer(),
        const SizedBox(width: 40),
      ]),
    );
  }

  Widget _buildAvatarSection(AppThemeExtension ext) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickAvatar,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              // ── الأفاتار الكبير ──
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryStart.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _avatarPath.isNotEmpty
                      // صورة شخصية لو موجودة
                      ? Image.file(
                          File(_avatarPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildLetterAvatar(_firstLetter, 100, 42),
                        )
                      // أول حرف من الاسم المكتوب حالياً
                      : _buildLetterAvatar(_firstLetter, 100, 42),
                ),
              ),
              // زر الكاميرا الصغير
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _pickAvatar,
          child: const Text(
            'تغيير الصورة الشخصية',
            style: TextStyle(
                color: AppColors.primaryStart,
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  /// أفاتار بالتدرج يعرض الحرف الأول
  Widget _buildLetterAvatar(String letter, double size, double fontSize) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient, shape: BoxShape.circle),
      child: Center(
        child: Text(letter,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required AppThemeExtension ext,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ext.textSecondary)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ext.cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppThemeExtension ext,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(color: ext.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: ext.textHint),
        hintTextDirection: TextDirection.rtl,
        prefixIcon: Icon(icon, color: AppColors.primaryStart, size: 20),
        filled: true,
        fillColor: ext.inputBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primaryStart, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.importantColor, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _save,
      child: GradientContainer(
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: _isSaving
                ? const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text('حفظ التغييرات',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

// ── Picker option tile ────────────────────────────────────────────────────────
class _PickerOption extends StatelessWidget {
  const _PickerOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: ext.inputBg,
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  color: ext.textPrimary,
                  fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}