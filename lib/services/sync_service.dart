import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/database/database_helper.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/supplier_model.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final List<StreamSubscription> _firestoreSubscriptions = [];

  void initialize() {
    // Listen for network changes to auto-sync on reconnect
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        debugPrint('[SyncService] Network restored. Syncing queue...');
        syncQueue();
        startRealtimeSync();
      } else {
        debugPrint('[SyncService] Network disconnected. Stopping realtime sync listeners.');
        stopRealtimeSync();
      }
    });

    // Initial check
    isOnline().then((online) {
      if (online) {
        syncQueue();
        startRealtimeSync();
      }
    });
  }

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return false;
    }
    return true;
  }

  Future<void> syncQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      if (!await isOnline()) {
        debugPrint('[SyncService] Offline. Skipping sync.');
        return;
      }

      final items = await _dbHelper.getQueueItems();
      if (items.isEmpty) {
        debugPrint('[SyncService] Queue is empty.');
        return;
      }

      debugPrint('[SyncService] Syncing ${items.length} items from offline queue...');
      for (final item in items) {
        final collectionRef = _firestore.collection(item.collection);
        final docRef = collectionRef.doc(item.recordId);

        try {
          if (item.action == 'DELETE') {
            await docRef.delete();
          } else {
            await docRef.set(item.data, SetOptions(merge: true));
          }
          // Delete from local queue after success
          if (item.id != null) {
            await _dbHelper.deleteQueueItem(item.id!);
          }
        } catch (error) {
          debugPrint('[SyncService] Failed to sync queue item ${item.id}: $error');
          break; // Stop to preserve sequence of changes
        }
      }
    } catch (e) {
      debugPrint('[SyncService] Error during queue sync: $e');
    } finally {
      _isSyncing = false;
      await _updateSyncStatus();
    }
  }

  void startRealtimeSync() {
    if (_firestoreSubscriptions.isNotEmpty) return;

    debugPrint('[SyncService] Starting realtime Firestore streams...');

    // 1. Sync Products
    _firestoreSubscriptions.add(
      _firestore.collection('products').snapshots().listen((snapshot) async {
        for (final doc in snapshot.docs) {
          try {
            final product = ProductModel.fromMap(doc.data()..['id'] = int.tryParse(doc.id));
            final localProducts = await _dbHelper.getProducts();
            if (!localProducts.any((p) => p.id == product.id)) {
              await _dbHelper.insertProduct(product);
            } else {
              await _dbHelper.updateProduct(product);
            }
          } catch (e) {
            debugPrint('[SyncService] Error syncing product doc: $e');
          }
        }
      }),
    );

    // 2. Sync Categories
    _firestoreSubscriptions.add(
      _firestore.collection('categories').snapshots().listen((snapshot) async {
        for (final doc in snapshot.docs) {
          try {
            final category = CategoryModel.fromMap(doc.data()..['id'] = doc.id);
            await _dbHelper.upsertCategory(category);
          } catch (e) {
            debugPrint('[SyncService] Error syncing category doc: $e');
          }
        }
      }),
    );

    // 3. Sync Suppliers
    _firestoreSubscriptions.add(
      _firestore.collection('suppliers').snapshots().listen((snapshot) async {
        for (final doc in snapshot.docs) {
          try {
            final supplier = SupplierModel.fromMap(doc.data()..['id'] = doc.id);
            await _dbHelper.upsertSupplier(supplier);
          } catch (e) {
            debugPrint('[SyncService] Error syncing supplier doc: $e');
          }
        }
      }),
    );
  }

  void stopRealtimeSync() {
    for (final sub in _firestoreSubscriptions) {
      sub.cancel();
    }
    _firestoreSubscriptions.clear();
  }

  Future<void> _updateSyncStatus() async {
    try {
      final queue = await _dbHelper.getQueueItems();
      final currentStatus = await _dbHelper.getSyncStatus();
      await _dbHelper.upsertSyncStatus(currentStatus.copyWith(
        lastSuccessfulSync: queue.isEmpty ? DateTime.now() : currentStatus.lastSuccessfulSync,
        pendingRecords: queue.length,
      ));
    } catch (_) {}
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    stopRealtimeSync();
  }
}
