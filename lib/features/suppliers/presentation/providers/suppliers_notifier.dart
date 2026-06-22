import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/supplier_model.dart';
import '../../data/suppliers_repository.dart';

class SuppliersNotifier extends StateNotifier<List<SupplierModel>> {
  SuppliersNotifier(this._repository) : super([]) {
    loadSuppliers();
  }

  final SuppliersRepository _repository;

  Future<void> loadSuppliers() async {
    try {
      final list = await _repository.fetchSuppliers();
      // Seed default suppliers if database is empty
      if (list.isEmpty) {
        for (final seed in _seedSuppliers) {
          await _repository.saveSupplier(seed);
        }
        state = await _repository.fetchSuppliers();
      } else {
        state = list;
      }
    } catch (_) {}
  }

  static const _seedSuppliers = [
    SupplierModel(
      id: 'S001',
      name: 'TechSource',
      phone: '+1 222 334 455',
      email: 'hello@techsource.com',
      address: 'San Francisco, CA',
      status: 'Active',
    ),
    SupplierModel(
      id: 'S002',
      name: 'PrintHub',
      phone: '+1 222 887 120',
      email: 'sales@printhub.com',
      address: 'Austin, TX',
      status: 'Active',
    ),
    SupplierModel(
      id: 'S003',
      name: 'StackLine',
      phone: '+1 222 990 441',
      email: 'ops@stackline.com',
      address: 'Seattle, WA',
      status: 'Active',
    ),
  ];

  Future<void> addSupplier({
    required String name,
    required String phone,
    required String email,
    required String address,
    required String status,
  }) async {
    final supplier = SupplierModel(
      id: 'S${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
      status: status,
    );
    try {
      await _repository.saveSupplier(supplier);
      await loadSuppliers();
    } catch (e) {
      state = [...state, supplier];
    }
  }

  Future<void> updateSupplier({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String address,
    required String status,
  }) async {
    final existing = state.firstWhere((s) => s.id == id);
    final supplier = existing.copyWith(
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
      status: status,
    );
    try {
      await _repository.saveSupplier(supplier);
      await loadSuppliers();
    } catch (e) {
      state = [
        for (final s in state)
          if (s.id == id) supplier else s,
      ];
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _repository.deleteSupplier(id);
      await loadSuppliers();
    } catch (e) {
      state = state.where((supplier) => supplier.id != id).toList();
    }
  }
}
