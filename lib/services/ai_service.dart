import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../data/models/product_model.dart';

/// AI provider status for UI display.
enum AiProviderStatus {
  gemini('Gemini 1.5 Flash'),
  groq('Groq Llama 3'),
  localRuleEngine('Local Rule Engine'),
  none('Unavailable');

  final String label;
  const AiProviderStatus(this.label);
}

/// Result from an AI analysis call.
class AiResult {
  final String text;
  final AiProviderStatus provider;

  const AiResult({required this.text, required this.provider});
}

class AIService {
  String? get _geminiKey => dotenv.env['GEMINI_API_KEY'];
  String? get _groqKey => dotenv.env['GROQ_API_KEY'];

  bool _isValidKey(String? key) =>
      key != null && key.isNotEmpty && key != 'your_key_here';

  // ─── Public API ─────────────────────────────────────────────

  Future<AiResult> analyzeInventory(List<ProductModel> products) async {
    if (products.isEmpty) {
      return const AiResult(
        text: 'The product catalog is currently empty. Add products to analyze inventory health.',
        provider: AiProviderStatus.none,
      );
    }

    final productSummary = products
        .map((p) => '- SKU: ${p.skuLabel}, Name: ${p.name}, Category: ${p.category}, Stock: ${p.stock}, Price: \$${p.price.toStringAsFixed(2)}')
        .join('\n');

    final prompt = '''
You are an expert inventory operations consultant. Analyze the following inventory catalog:
$productSummary

Provide a brief, high-level summary of:
1. Overall inventory health.
2. Immediate anomalies, dead stock risks, or imbalances (e.g. products with extremely low or high stock levels).
3. Actionable optimization suggestions.
Format as brief Markdown bullet points.
''';

    return _callAiWithFailover(prompt, products);
  }

  Future<AiResult> predictDemand(List<ProductModel> products) async {
    if (products.isEmpty) {
      return const AiResult(
        text: 'The product catalog is currently empty. Add products to forecast demand trends.',
        provider: AiProviderStatus.none,
      );
    }

    final productSummary = products
        .map((p) => '- Name: ${p.name}, Category: ${p.category}, Current Stock: ${p.stock}')
        .join('\n');

    final prompt = '''
You are an expert supply chain data analyst. Based on current stock levels and categories:
$productSummary

Provide a 30-day predictive demand forecast:
1. Identify items at high risk of stockouts.
2. List seasonal demand assumptions based on the category.
3. Suggest a safe buffer stock policy.
Format as brief Markdown bullet points.
''';

    return _callAiWithFailover(prompt, products);
  }

  Future<AiResult> generateReorderSuggestions(List<ProductModel> products) async {
    if (products.isEmpty) {
      return const AiResult(
        text: 'The product catalog is currently empty. Add products to generate reorder proposals.',
        provider: AiProviderStatus.none,
      );
    }

    final productSummary = products
        .map((p) => '- Name: ${p.name}, Category: ${p.category}, Stock: ${p.stock}, Supplier: ${p.supplier}')
        .join('\n');

    final prompt = '''
You are a procurement optimization assistant. Generate a reorder proposal based on these items:
$productSummary

For products with low stock (typically 10 or fewer units), propose:
1. Recommended reorder quantities.
2. Estimated priority (High/Medium/Low).
3. Supplier to contact.
Format as brief Markdown bullet points.
''';

    return _callAiWithFailover(prompt, products);
  }

  // ─── Failover Chain: Gemini → Groq → Local Rule Engine ─────

  Future<AiResult> _callAiWithFailover(String prompt, List<ProductModel> products) async {
    // 1. Try Gemini
    if (_isValidKey(_geminiKey)) {
      try {
        final text = await _callGemini(prompt);
        if (text != null) {
          return AiResult(text: text, provider: AiProviderStatus.gemini);
        }
      } catch (e) {
        debugPrint('[AIService] Gemini failed: $e');
      }
    }

    // 2. Try Groq
    if (_isValidKey(_groqKey)) {
      try {
        final text = await _callGroq(prompt);
        if (text != null) {
          return AiResult(text: text, provider: AiProviderStatus.groq);
        }
      } catch (e) {
        debugPrint('[AIService] Groq failed: $e');
      }
    }

    // 3. Fallback to Local Rule Engine (always available, never fails)
    final localResult = _localRuleEngine(products);
    return AiResult(text: localResult, provider: AiProviderStatus.localRuleEngine);
  }

  // ─── Provider Implementations ──────────────────────────────

  Future<String?> _callGemini(String prompt) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_geminiKey');
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ]
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      return text?.trim();
    }
    debugPrint('[AIService] Gemini HTTP ${response.statusCode}: ${response.body}');
    return null;
  }

  Future<String?> _callGroq(String prompt) async {
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_groqKey',
          },
          body: jsonEncode({
            'model': 'llama3-8b-8192',
            'messages': [
              {'role': 'user', 'content': prompt}
            ],
            'max_tokens': 1024,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['choices']?[0]?['message']?['content'] as String?;
      return text?.trim();
    }
    debugPrint('[AIService] Groq HTTP ${response.statusCode}: ${response.body}');
    return null;
  }

  // ─── Local Rule Engine (offline, deterministic) ────────────

  String _localRuleEngine(List<ProductModel> products) {
    if (products.isEmpty) {
      return '📦 **No products found.** Add inventory items to generate analysis.';
    }

    final totalProducts = products.length;
    final totalStock = products.fold<int>(0, (sum, p) => sum + p.stock);
    final totalValue = products.fold<double>(0, (sum, p) => sum + (p.price * p.stock));
    final avgStock = totalStock / totalProducts;

    final criticalItems = products.where((p) => p.stock <= 5).toList();
    final lowStockItems = products.where((p) => p.stock > 5 && p.stock <= 15).toList();
    final overstocked = products.where((p) => p.stock > 100).toList();
    final zeroStock = products.where((p) => p.stock == 0).toList();

    // Category breakdown
    final categoryMap = <String, int>{};
    for (final p in products) {
      categoryMap[p.category] = (categoryMap[p.category] ?? 0) + 1;
    }

    final buffer = StringBuffer();
    buffer.writeln('## 📊 Inventory Health Analysis (Local Engine)');
    buffer.writeln();
    buffer.writeln('**Catalog Overview:**');
    buffer.writeln('- **${totalProducts}** products across **${categoryMap.length}** categories');
    buffer.writeln('- **${totalStock}** total units in stock');
    buffer.writeln('- **\$${totalValue.toStringAsFixed(2)}** total inventory valuation');
    buffer.writeln('- **${avgStock.toStringAsFixed(1)}** average units per product');
    buffer.writeln();

    if (zeroStock.isNotEmpty) {
      buffer.writeln('### 🚨 Out of Stock (${zeroStock.length} items)');
      for (final p in zeroStock) {
        buffer.writeln('- **${p.name}** — \$${p.price.toStringAsFixed(2)} — IMMEDIATE reorder required');
      }
      buffer.writeln();
    }

    if (criticalItems.isNotEmpty) {
      buffer.writeln('### ⚠️ Critical Stock (≤5 units) — ${criticalItems.length} items');
      for (final p in criticalItems.where((p) => p.stock > 0)) {
        buffer.writeln('- **${p.name}** — ${p.stock} units remaining — Priority: **HIGH**');
      }
      buffer.writeln();
    }

    if (lowStockItems.isNotEmpty) {
      buffer.writeln('### 📉 Low Stock (6–15 units) — ${lowStockItems.length} items');
      for (final p in lowStockItems.take(5)) {
        buffer.writeln('- **${p.name}** — ${p.stock} units — Priority: **MEDIUM**');
      }
      if (lowStockItems.length > 5) {
        buffer.writeln('- _...and ${lowStockItems.length - 5} more_');
      }
      buffer.writeln();
    }

    if (overstocked.isNotEmpty) {
      buffer.writeln('### 📦 Overstocked (>100 units) — ${overstocked.length} items');
      for (final p in overstocked.take(5)) {
        buffer.writeln('- **${p.name}** — ${p.stock} units — Consider promotions or redistribution');
      }
      buffer.writeln();
    }

    buffer.writeln('### 📂 Category Breakdown');
    for (final entry in categoryMap.entries) {
      buffer.writeln('- **${entry.key}**: ${entry.value} products');
    }

    buffer.writeln();
    buffer.writeln('### 💡 Recommendations');
    if (criticalItems.isNotEmpty || zeroStock.isNotEmpty) {
      buffer.writeln('- **Urgent**: Reorder ${criticalItems.length + zeroStock.length} critical/out-of-stock items immediately');
    }
    if (overstocked.isNotEmpty) {
      buffer.writeln('- **Optimize**: Review ${overstocked.length} overstocked items for markdown or redistribution');
    }
    buffer.writeln('- Maintain safety stock of 10+ units for high-turnover categories');
    buffer.writeln('- Configure API keys (GEMINI_API_KEY or GROQ_API_KEY) for AI-powered analysis');

    return buffer.toString();
  }
}
