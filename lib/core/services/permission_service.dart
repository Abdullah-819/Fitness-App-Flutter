import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper over `permission_handler` for the permissions the app needs.
class PermissionService {
  PermissionService._();

  static final PermissionService instance = PermissionService._();

  Future<bool> hasActivity() async =>
      (await Permission.activityRecognition.status).isGranted;

  Future<bool> hasLocation() async =>
      (await Permission.locationWhenInUse.status).isGranted;

  /// Asks for physical activity (step counter) access.
  Future<bool> requestActivity() => _request(Permission.activityRecognition);

  /// Asks for location access while the app is in use.
  Future<bool> requestLocation() => _request(Permission.locationWhenInUse);

  Future<bool> _request(Permission permission) async {
    try {
      var status = await permission.status;
      if (status.isGranted) return true;

      status = await permission.request();
      if (status.isPermanentlyDenied) {
        // The system prompt won't show again; send the user to app settings.
        await openAppSettings();
      }
      return status.isGranted;
    } catch (e) {
      debugPrint('PermissionService: request failed ($e)');
      return false;
    }
  }
}
