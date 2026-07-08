import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/layouts/editorial_header.dart';
import '../../widgets/layouts/luxury_scaffold.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.qrCode,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.itf14,
    ],
  );

  bool _scanning = true;
  String _status = 'Point the camera at a barcode or QR code';
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_scanning) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    _completeScan(raw);
  }

  void _completeScan(String code) {
    if (!_scanning) return;
    setState(() {
      _scanning = false;
      _status = 'Scanned: $code';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Captured: $code')),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        Navigator.pop(context, code);
      }
    });
  }

  void _retryScan() {
    setState(() {
      _scanning = true;
      _errorMessage = null;
      _status = 'Point the camera at a barcode or QR code';
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cameraSupported = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return LuxuryScaffold(
      route: AppRoutes.scanner,
      title: 'Scanner Studio',
      header: const EditorialHeader(
        eyebrow: 'Capture Interface',
        title: 'Barcode & QR Scanner',
        subtitle: 'Scan EAN-13, UPC, Code-128, QR codes and more using your device camera.',
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (!cameraSupported)
                  _UnsupportedPlatform(onManualEntry: _showManualEntry)
                else if (_errorMessage != null)
                  _ScannerError(message: _errorMessage!, onRetry: _retryScan)
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 280,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MobileScanner(
                            controller: _controller,
                            onDetect: _onDetect,
                            errorBuilder: (context, error) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted && _errorMessage == null) {
                                  setState(() {
                                    _errorMessage = _cameraErrorMessage(error);
                                  });
                                }
                              });
                              return const SizedBox.shrink();
                            },
                          ),
                          Center(
                            child: Container(
                              width: 240,
                              height: 140,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _scanning ? AppColors.accentGold : AppColors.success,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          if (!_scanning)
                            Container(
                              color: Colors.black54,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 64,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _scanning ? Icons.camera_alt_outlined : Icons.check_rounded,
                      size: 18,
                      color: _scanning ? colorScheme.primary : AppColors.success,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
                if (cameraSupported && _errorMessage == null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        tooltip: 'Toggle torch',
                        onPressed: () => _controller.toggleTorch(),
                        icon: const Icon(Icons.flash_on_outlined),
                      ),
                      IconButton(
                        tooltip: 'Switch camera',
                        onPressed: () => _controller.switchCamera(),
                        icon: const Icon(Icons.cameraswitch_outlined),
                      ),
                      TextButton.icon(
                        onPressed: _showManualEntry,
                        icon: const Icon(Icons.keyboard_outlined, size: 18),
                        label: const Text('Enter manually'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _cameraErrorMessage(MobileScannerException error) {
    switch (error.errorCode) {
      case MobileScannerErrorCode.permissionDenied:
        return 'Camera permission denied. Enable camera access in system settings.';
      case MobileScannerErrorCode.unsupported:
        return 'Camera scanning is not supported on this device.';
      default:
        return error.errorDetails?.message ?? 'Camera error. Please try again.';
    }
  }

  Future<void> _showManualEntry() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter barcode'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Barcode or QR value',
          ),
          keyboardType: TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Use code'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (code != null && code.isNotEmpty) {
      _completeScan(code);
    }
  }
}

class _UnsupportedPlatform extends StatelessWidget {
  const _UnsupportedPlatform({required this.onManualEntry});

  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.qr_code_scanner_rounded, size: 48),
          const SizedBox(height: 12),
          const Text('Camera scanning is available on Android and iOS.'),
          const SizedBox(height: 8),
          TextButton(onPressed: onManualEntry, child: const Text('Enter barcode manually')),
        ],
      ),
    );
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
