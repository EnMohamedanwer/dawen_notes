import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request gallery / photos permission
  Future<bool> requestGalleryPermission() async {
    // Android 13+ uses READ_MEDIA_IMAGES, older uses READ_EXTERNAL_STORAGE
    PermissionStatus status;
    if (await Permission.photos.status.isDenied) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.storage.request();
    }
    return status.isGranted ||
        await Permission.photos.isGranted ||
        await Permission.storage.isGranted;
  }

  /// Check and request both camera and gallery
  Future<Map<String, bool>> requestMediaPermissions() async {
    final camera = await requestCameraPermission();
    final gallery = await requestGalleryPermission();
    return {'camera': camera, 'gallery': gallery};
  }

  /// Open app settings if permission permanently denied
  Future<bool> openSettings() => openAppSettings();
}
