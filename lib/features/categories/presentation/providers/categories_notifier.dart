import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/category_model.dart';
import '../../data/categories_repository.dart';

class CategoriesNotifier extends StateNotifier<List<CategoryModel>> {
  CategoriesNotifier(this._repository) : super([]) {
    loadCategories();
  }

  final CategoriesRepository _repository;

  Future<void> loadCategories() async {
    try {
      final list = await _repository.fetchCategories();
      // Seed default categories if database is empty
      if (list.isEmpty) {
        for (final seed in _seedCategories) {
          await _repository.saveCategory(seed);
        }
        state = await _repository.fetchCategories();
      } else {
        state = list;
      }
    } catch (_) {}
  }

  static const _seedCategories = [
    CategoryModel(id: 'C001', name: 'Electronics', description: 'Devices and hardware', totalProducts: 0),
    CategoryModel(id: 'C002', name: 'Office', description: 'Office essentials', totalProducts: 0),
    CategoryModel(id: 'C003', name: 'Warehouse', description: 'Warehouse supplies', totalProducts: 0),
    CategoryModel(id: 'C004', name: 'Consumables', description: 'Consumable inventory', totalProducts: 0),
  ];

  Future<void> addCategory({required String name, String description = ''}) async {
    final category = CategoryModel(
      id: 'C${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      description: description.trim(),
    );
    try {
      await _repository.saveCategory(category);
      await loadCategories();
    } catch (e) {
      state = [...state, category];
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String description = '',
  }) async {
    final existing = state.firstWhere((c) => c.id == id);
    final category = existing.copyWith(
      name: name.trim(),
      description: description.trim(),
    );
    try {
      await _repository.saveCategory(category);
      await loadCategories();
    } catch (e) {
      state = [
        for (final c in state)
          if (c.id == id) category else c,
      ];
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      state = state.where((category) => category.id != id).toList();
    }
  }
}
