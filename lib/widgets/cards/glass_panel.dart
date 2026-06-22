import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/theme/app_shadows.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassPanel({super.key, required this.child, this.padding = const EdgeInsets.all(AppSizes.space16)});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final overlayGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x05FFFFFF),
              Color(0x02FFFFFF),
            ],
          )
        : AppShadows.subtleOverlay;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: overlayGradient,
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.8)),
            boxShadow: AppShadows.soft,
          ),
          child: child,
        ),
      ),
    );
  }
}

