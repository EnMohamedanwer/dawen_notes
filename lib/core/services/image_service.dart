import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'permission_service.dart';

class ImageService {
  ImageService(this._permissionService);

  final PermissionService _permissionService;
  final _picker = ImagePicker();

  /// Pick image from gallery – returns saved local path or null
  Future<String?> pickFromGallery() async {
    final granted = await _permissionService.requestGalleryPermission();
    if (!granted) return null;

    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xFile == null) return null;
    return _saveToAppDir(xFile);
  }

  /// Capture image from camera – returns saved local path or null
  Future<String?> pickFromCamera() async {
    final granted = await _permissionService.requestCameraPermission();
    if (!granted) return null;

    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (xFile == null) return null;
    return _saveToAppDir(xFile);
  }

  /// Save picked file into app documents directory
  Future<String> _saveToAppDir(XFile xFile) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(dir.path, 'note_images'));
    if (!await imagesDir.exists()) await imagesDir.create(recursive: true);

    final ext = p.extension(xFile.path);
    final fileName = '${const Uuid().v4()}$ext';
    final destPath = p.join(imagesDir.path, fileName);

    await File(xFile.path).copy(destPath);
    return destPath;
  }

  /// Delete image file from disk
  Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
