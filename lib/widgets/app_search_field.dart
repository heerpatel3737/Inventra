import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  final String hint;
  final Widget? trailing;

  const AppSearchField({super.key, required this.hint, this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: colorScheme.onSurface.withValues(alpha: 0.62)),
          const SizedBox(width: 10),
          Expanded(child: Text(hint, style: Theme.of(context).textTheme.bodyMedium)),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
