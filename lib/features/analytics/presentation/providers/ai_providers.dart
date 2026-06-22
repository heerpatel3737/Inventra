import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/product_provider.dart';
import '../../../../services/ai_service.dart';

final aiServiceProvider = Provider<AIService>((ref) => AIService());

/// Currently selected analysis type (health, demand, reorder).
final aiAnalysisTypeProvider = StateProvider<String>((ref) => 'health');

/// Tracks which AI provider is currently active.
final aiActiveProviderProvider = StateProvider<AiProviderStatus>((ref) => AiProviderStatus.none);

/// Holds the last AI result text. Null until user triggers analysis.
final aiResultTextProvider = StateProvider<String?>((ref) => null);

/// True while an AI call is in progress.
final aiLoadingProvider = StateProvider<bool>((ref) => false);

/// Error text if the last AI call failed.
final aiErrorProvider = StateProvider<String?>((ref) => null);

/// Manually triggered AI analysis. Does NOT auto-fire on widget build.
Future<void> runAiAnalysis(WidgetRef ref) async {
  final aiService = ref.read(aiServiceProvider);
  final analysisType = ref.read(aiAnalysisTypeProvider);
  final productsAsync = ref.read(productsProvider);
  final products = productsAsync.value ?? [];

  // Set loading state
  ref.read(aiLoadingProvider.notifier).state = true;
  ref.read(aiErrorProvider.notifier).state = null;
  ref.read(aiResultTextProvider.notifier).state = null;

  try {
    AiResult result;
    if (analysisType == 'health') {
      result = await aiService.analyzeInventory(products);
    } else if (analysisType == 'demand') {
      result = await aiService.predictDemand(products);
    } else {
      result = await aiService.generateReorderSuggestions(products);
    }

    ref.read(aiResultTextProvider.notifier).state = result.text;
    ref.read(aiActiveProviderProvider.notifier).state = result.provider;
  } catch (e) {
    ref.read(aiErrorProvider.notifier).state = 'Analysis failed: $e';
    ref.read(aiActiveProviderProvider.notifier).state = AiProviderStatus.none;
  } finally {
    ref.read(aiLoadingProvider.notifier).state = false;
  }
}
