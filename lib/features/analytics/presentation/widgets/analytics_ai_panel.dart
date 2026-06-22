import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/ai_service.dart';
import '../providers/ai_providers.dart';

class AnalyticsAiPanel extends ConsumerWidget {
  const AnalyticsAiPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(aiAnalysisTypeProvider);
    final isLoading = ref.watch(aiLoadingProvider);
    final resultText = ref.watch(aiResultTextProvider);
    final errorText = ref.watch(aiErrorProvider);
    final activeProvider = ref.watch(aiActiveProviderProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: AppColors.accentGold, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('AI Cognitive Forecast', style: Theme.of(context).textTheme.titleLarge),
                ),
                // Active provider badge
                if (activeProvider != AiProviderStatus.none)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _providerColor(activeProvider).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _providerColor(activeProvider).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_providerIcon(activeProvider), size: 12, color: _providerColor(activeProvider)),
                        const SizedBox(width: 4),
                        Text(
                          activeProvider.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _providerColor(activeProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Select analysis type, then tap "Run Analysis" to query the AI engine.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip(context, ref, 'health', 'Health Audit', Icons.health_and_safety_rounded, selectedType),
                  const SizedBox(width: 8),
                  _buildChip(context, ref, 'demand', '30d Demand', Icons.trending_up_rounded, selectedType),
                  const SizedBox(width: 8),
                  _buildChip(context, ref, 'reorder', 'Reorder Plan', Icons.shopping_cart_checkout_rounded, selectedType),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Run Analysis button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () => runAiAnalysis(ref),
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(isLoading ? 'Analyzing...' : 'Run Analysis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Results container
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: _buildResultContent(context, isLoading, resultText, errorText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent(
    BuildContext context,
    bool isLoading,
    String? resultText,
    String? errorText,
  ) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Querying AI operations room...', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      );
    }

    if (errorText != null) {
      return Center(
        child: Text(
          errorText,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (resultText != null) {
      return SelectableText(
        resultText,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Select an analysis type and tap "Run Analysis" to get AI-powered insights.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Color _providerColor(AiProviderStatus provider) {
    switch (provider) {
      case AiProviderStatus.gemini:
        return const Color(0xFF4285F4);
      case AiProviderStatus.groq:
        return const Color(0xFFF55036);
      case AiProviderStatus.localRuleEngine:
        return const Color(0xFF34A853);
      case AiProviderStatus.none:
        return Colors.grey;
    }
  }

  IconData _providerIcon(AiProviderStatus provider) {
    switch (provider) {
      case AiProviderStatus.gemini:
        return Icons.auto_awesome;
      case AiProviderStatus.groq:
        return Icons.bolt;
      case AiProviderStatus.localRuleEngine:
        return Icons.computer;
      case AiProviderStatus.none:
        return Icons.cloud_off;
    }
  }

  Widget _buildChip(
    BuildContext context,
    WidgetRef ref,
    String type,
    String label,
    IconData icon,
    String selected,
  ) {
    final isSelected = selected == type;
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      avatar: Icon(
        icon,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        size: 16,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          ref.read(aiAnalysisTypeProvider.notifier).state = type;
        }
      },
    );
  }
}
