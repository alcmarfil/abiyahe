import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class PermissionUtils {
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt ?? 0;

    if (sdkInt >= 33) {
      // For Android 13 and above, request media permissions
      final photos = await Permission.photos.request();
      final videos = await Permission.videos.request();
      final audio = await Permission.audio.request();
      
      return photos.isGranted && videos.isGranted && audio.isGranted;
    } else {
      // For Android 12 and below, request storage permission
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
  }

  static Future<bool> checkStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt ?? 0;

    if (sdkInt >= 33) {
      // For Android 13 and above, check media permissions
      final photos = await Permission.photos.status;
      final videos = await Permission.videos.status;
      final audio = await Permission.audio.status;
      
      return photos.isGranted && videos.isGranted && audio.isGranted;
    } else {
      // For Android 12 and below, check storage permission
      final storage = await Permission.storage.status;
      return storage.isGranted;
    }
  }
} 