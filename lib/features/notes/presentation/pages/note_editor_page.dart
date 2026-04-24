import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_category.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/gradient_widgets.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/permission_service.dart';

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, this.note, required this.categories});
  final Note? note;
  final List<NoteCategory> categories;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _titleCtrl;
  late final QuillController _quillCtrl;
  late String _selectedCategoryId;
  bool _isFavorite = false;
  List<String> _imagePaths = [];

  final _imageService = ImageService(PermissionService());
  final _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _isFavorite = widget.note?.isFavorite ?? false;
    _imagePaths = List<String>.from(widget.note?.imagePaths ?? []);
    _selectedCategoryId = widget.note?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : 'work');

    if (widget.note != null && widget.note!.contentJson.isNotEmpty) {
      try {
        final doc = Document.fromJson(
            jsonDecode(widget.note!.contentJson) as List<dynamic>);
        _quillCtrl = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _quillCtrl = QuillController.basic();
      }
    } else {
      _quillCtrl = QuillController.basic();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _quillCtrl.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _quillCtrl.document.toPlainText();
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  String get _contentJson => jsonEncode(_quillCtrl.document.toDelta().toJson());

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء إدخال عنوان للملاحظة'),
            behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id ?? const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      contentJson: _contentJson,
      categoryId: _selectedCategoryId,
      createdAt: widget.note?.createdAt ?? now,
      updatedAt: now,
      isFavorite: _isFavorite,
      wordCount: _wordCount,
      imagePaths: _imagePaths,
    );
    if (widget.note == null) {
      context.read<NotesBloc>().add(CreateNoteEvent(note));
    } else {
      context.read<NotesBloc>().add(UpdateNoteEvent(note));
    }
    Navigator.pop(context);
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    String? path;
    if (fromCamera) {
      final ok = await _permissionService.requestCameraPermission();
      if (!ok) {
        _showPermissionDenied('الكاميرا');
        return;
      }
      path = await _imageService.pickFromCamera();
    } else {
      final ok = await _permissionService.requestGalleryPermission();
      if (!ok) {
        _showPermissionDenied('المعرض');
        return;
      }
      path = await _imageService.pickFromGallery();
    }
    if (path != null && mounted) setState(() => _imagePaths.add(path!));
  }

  Future<void> _showImageOptions() async {
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
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4))),
              const SizedBox(height: 16),
              Text('إضافة صورة',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: ext.textPrimary)),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: ext.inputBg,
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.primaryStart),
                title: Text('التقاط صورة',
                    style: TextStyle(color: ext.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(fromCamera: true);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: ext.inputBg,
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.ideasColor),
                title:
                    Text('من المعرض', style: TextStyle(color: ext.textPrimary)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(fromCamera: false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPermissionDenied(String src) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تعذر الوصول إلى $src', textAlign: TextAlign.end),
        content:
            Text('يرجى السماح للتطبيق من الإعدادات.', textAlign: TextAlign.end),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(_);
              _permissionService.openSettings();
            },
            child: const Text('الإعدادات'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(ext),
            _buildMetaBar(ext),
            _buildQuillToolbar(ext),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      textAlign: TextAlign.end,
                      textDirection: ui.TextDirection.ltr,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ext.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'عنوان الملاحظة',
                        hintTextDirection: ui.TextDirection.ltr,
                        border: InputBorder.none,
                        filled: false,
                        hintStyle: TextStyle(
                            color: ext.textHint, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Divider(color: ext.divider, thickness: 1),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(minHeight: 200),
                      child: QuillEditor.basic(
                        controller: _quillCtrl,
                        config: QuillEditorConfig(
                          placeholder: 'اكتب ملاحظتك هنا...',
                          padding: const EdgeInsets.only(bottom: 16),
                        ),
                      ),
                    ),
                    if (_imagePaths.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildImagesGrid(ext),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildBottomToolbar(ext),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AppThemeExtension ext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          onTap: _save,
          child: GradientContainer(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Text('حفظ',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => setState(() => _isFavorite = !_isFavorite),
          child: Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: ext.inputBg, shape: BoxShape.circle),
            child: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: _isFavorite ? Colors.amber : ext.textHint,
              size: 22,
            ),
          ),
        ),
        const Spacer(),
        // Text('$_wordCount كلمة',
        //     style: TextStyle(fontSize: 11, color: ext.textHint)),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: ext.inputBg, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ),
        ),
      ]),
    );
  }

  Widget _buildMetaBar(AppThemeExtension ext) {
    final category = widget.categories
        .cast<NoteCategory?>()
        .firstWhere((c) => c?.id == _selectedCategoryId, orElse: () => null);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text('📅 ${DateFormat('d MMMM yyyy', 'ar').format(DateTime.now())}',
            style: TextStyle(fontSize: 12, color: ext.textHint)),
        const Spacer(),
        GestureDetector(
          onTap: _showCategoryPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (category?.color ?? AppColors.workColor)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '${category?.icon ?? "💼"} ${category?.name ?? "العمل"}',
              style: TextStyle(
                  fontSize: 13,
                  color: category?.color ?? AppColors.workColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildQuillToolbar(AppThemeExtension ext) {
    return Container(
      decoration: BoxDecoration(
        color: ext.navBarBg,
        border: Border.symmetric(horizontal: BorderSide(color: ext.divider)),
      ),
      child: QuillSimpleToolbar(
        controller: _quillCtrl,
        config: const QuillSimpleToolbarConfig(
          multiRowsDisplay: false,
        ),
      ),
    );
  }

  Widget _buildImagesGrid(AppThemeExtension ext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Text('الصور المرفقة (${_imagePaths.length})',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ext.textSecondary)),
        ]),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1),
          itemCount: _imagePaths.length,
          itemBuilder: (_, i) => _buildImageTile(i, ext),
        ),
      ],
    );
  }

  Widget _buildImageTile(int index, AppThemeExtension ext) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(File(_imagePaths[index]),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  color: ext.inputBg,
                  child: const Icon(Icons.broken_image_outlined,
                      color: Colors.grey))),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: GestureDetector(
            onTap: () => setState(() => _imagePaths.removeAt(index)),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomToolbar(AppThemeExtension ext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: ext.navBarBg,
        border: Border(top: BorderSide(color: ext.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _ToolBtn(
              icon: Icons.image_outlined,
              label: 'صورة',
              onTap: _showImageOptions,
              color: AppColors.ideasColor),
          const SizedBox(width: 8),
          _ToolBtn(
              icon: Icons.camera_alt_outlined,
              label: 'كاميرا',
              onTap: () => _pickImage(fromCamera: true),
              color: AppColors.primaryStart),
          const SizedBox(width: 8),
          // _ToolBtn(
          //     icon: Icons.attach_file_rounded,
          //     label: 'مرفق',
          //     onTap: () {},
          //     color: AppColors.workColor),
        ],
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('اختر التصنيف',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...widget.categories.map((cat) => ListTile(
                onTap: () {
                  setState(() => _selectedCategoryId = cat.id);
                  Navigator.pop(context);
                },
                trailing: Text(cat.icon, style: const TextStyle(fontSize: 24)),
                title: Text(cat.name, textAlign: TextAlign.end),
                selected: cat.id == _selectedCategoryId,
                selectedColor: cat.color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              )),
        ]),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  const _ToolBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      required this.color});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
