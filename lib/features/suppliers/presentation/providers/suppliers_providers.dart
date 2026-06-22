import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/supplier_model.dart';
import '../../../../providers/product_provider.dart';
import '../../data/suppliers_repository.dart';
import 'suppliers_notifier.dart';

final suppliersRepositoryProvider = Provider<SuppliersRepository>((ref) {
  return SuppliersRepository(ref.watch(databaseHelperProvider));
});

final suppliersProvider = StateNotifierProvider<SuppliersNotifier, List<SupplierModel>>((ref) {
  final repository = ref.watch(suppliersRepositoryProvider);
  return SuppliersNotifier(repository);
});

/// Dropdown options for product forms (reactive).
final supplierOptionsProvider = Provider<List<String>>((ref) {
  return ref.watch(suppliersProvider).map((supplier) => supplier.name).toList();
});

final supplierCountProvider = Provider<int>((ref) {
  return ref.watch(suppliersProvider).length;
});
