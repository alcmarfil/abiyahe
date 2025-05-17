import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeScreen extends StatefulWidget {
  final String travelId;
  const QrCodeScreen({super.key, required this.travelId});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSaving = false;

  Future<void> _saveQrCode() async {
    setState(() => _isSaving = true);
    try {
      // Handle permissions
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt ?? 0;

        PermissionStatus status;
        if (sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }

        if (!status.isGranted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission denied. Cannot save QR code.')),
          );
          return;
        }
      }

      // Capture QR image from boundary
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception("Could not find QR boundary");

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final String fileName = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';

      // Get downloads directory
      final Directory downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final filePath = '${downloadsDir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Trigger media scanner
      if (Platform.isAndroid) {
        final result = await Process.run('am', [
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d',
          'file://$filePath'
        ]);
        debugPrint('Media scan result: ${result.stdout}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR code saved to Downloads: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save QR code: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,  // Add white background
                padding: const EdgeInsets.all(20),  // Add some padding
                child: QrImageView(
                  data: widget.travelId,
                  version: QrVersions.auto,
                  size: 200.0,
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveQrCode,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}