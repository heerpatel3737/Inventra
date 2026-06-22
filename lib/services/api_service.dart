import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/database/database_helper.dart';
import '../data/models/product_model.dart';
import '../models/category_model.dart';
import 'sync_service.dart';
import '../models/sync_queue_item.dart';

class ApiService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<ProductModel>> fetchAndStoreExternalProducts() async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<ProductModel> fetchedProducts = [];

      for (final item in data) {
        final productName = (item['title'] as String).trim();
        final categoryName = (item['category'] as String).trim();

        // Capitalize category name for consistent display and matching
        final formattedCategoryName = categoryName
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
            .join(' ');

        // Double check existence in the database directly to prevent duplicates
        final existingProducts = await _dbHelper.getProducts();
        final productExists = existingProducts.any(
          (p) => p.name.toLowerCase().trim() == productName.toLowerCase(),
        );

        if (productExists) {
          continue;
        }

        // Auto-create category if it doesn't exist (match case-insensitively)
        final existingCategories = await _dbHelper.getCategories();
        final categoryExists = existingCategories.any(
          (c) => c.name.toLowerCase().trim() == formattedCategoryName.toLowerCase(),
        );

        if (!categoryExists) {
          final categoryId = 'C${DateTime.now().millisecondsSinceEpoch}';
          final newCategory = CategoryModel(
            id: categoryId,
            name: formattedCategoryName,
            description: 'Auto-created from API import',
            totalProducts: 0,
          );
          await _dbHelper.upsertCategory(newCategory);

          // Queue category for Firestore sync
          await _dbHelper.insertQueueItem(SyncQueueItem(
            collection: 'categories',
            action: 'CREATE',
            recordId: categoryId,
            data: newCategory.toMap(),
            createdAt: DateTime.now(),
          ));
        }

        final product = ProductModel(
          name: productName,
          price: (item['price'] as num).toDouble(),
          stock: 15, // Default stock for imported items
          category: formattedCategoryName, // Use formatted category name for consistent display
          supplier: 'FakeStore REST API',
        );

        // Save locally first
        final id = await _dbHelper.insertProduct(product);
        final savedProduct = product.copyWith(id: id);
        fetchedProducts.add(savedProduct);

        // Queue action for Firestore synchronization
        await _dbHelper.insertQueueItem(SyncQueueItem(
          collection: 'products',
          action: 'CREATE',
          recordId: id.toString(),
          data: savedProduct.toMap(),
          createdAt: DateTime.now(),
        ));
      }

      // Sync the queue in the background
      SyncService.instance.syncQueue();

      return fetchedProducts;
    } else {
      throw Exception('Failed to load products from API (Status: ${response.statusCode})');
    }
  }
}
