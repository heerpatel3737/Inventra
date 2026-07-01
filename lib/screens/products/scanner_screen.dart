import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/layouts/editorial_header.dart';
import '../../widgets/layouts/luxury_scaffold.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;
  Timer? _autoScanTimer;
  String _status = 'Initializing camera sensor...';
  bool _scanning = true;

  final List<Map<String, String>> _presetBarcodes = [
    {'code': '8801037837092', 'name': 'Premium Coffee Beans'},
    {'code': '4902430224321', 'name': 'Eco Hydration Flask'},
    {'code': '9780201379624', 'name': 'Software Architecture Manual'},
    {'code': '1937402840183', 'name': 'Ergonomic Desk Organiser'},
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );

    // Auto-scan a sample barcode after 2 seconds to make it feel responsive and automatic
    _autoScanTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted && _scanning) {
        _triggerScan(_presetBarcodes[0]['code']!);
      }
    });

    // Simulate sensor warmup text changes
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _status = 'Aligning laser guide lines...');
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _status = 'Reading capture window...');
    });
  }

  @override
  void dispose() {
    _laserController.dispose();
    _autoScanTimer?.cancel();
    super.dispose();
  }

  void _triggerScan(String code) {
    if (!_scanning) return;
    setState(() {
      _scanning = false;
      _status = 'Successfully scanned: $code';
    });

    // Visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('Captured Barcode: $code'),
          ],
        ),
      ),
    );

    // Return the code back to the Add Product Screen
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.pop(context, code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LuxuryScaffold(
      route: AppRoutes.scanner,
      title: 'Scanner Studio',
      header: const EditorialHeader(
        eyebrow: 'Capture Interface',
        title: 'Simulated Barcode Scanner',
        subtitle: 'Autonomously reads code from viewport or allows preset overrides for testing.',
      ),
      children: [
        // Viewport container
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'VIEWPORT VIEW',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _scanning ? colorScheme.outline : AppColors.success,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            // Simulated Camera static overlay
                            Opacity(
                              opacity: 0.15,
                              child: Center(
                                child: Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 140,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            // Pulsing green alignment lines
                            Center(
                              child: Container(
                                width: 180,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _scanning ? AppColors.accentGold : AppColors.success,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            // Scanning laser line animation
                            if (_scanning)
                              AnimatedBuilder(
                                animation: _laserAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    top: 70 + (_laserAnimation.value * 100),
                                    left: 40,
                                    right: 40,
                                    child: Container(
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: AppColors.accentGold,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.accentGold.withValues(alpha: 0.8),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: _scanning
                          ? const CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentGold)
                          : const Icon(Icons.check_rounded, color: AppColors.success, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Presets list for quick manual override/testing
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preset Test Codes (Tap to scan)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                ..._presetBarcodes.map((item) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.barcode_reader, color: AppColors.info),
                    title: Text(item['name']!),
                    subtitle: Text(item['code']!, style: const TextStyle(fontFamily: 'monospace')),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                    onTap: () => _triggerScan(item['code']!),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
