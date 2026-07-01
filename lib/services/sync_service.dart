import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/database/database_helper.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/supplier_model.dart';
import '../models/sales_model.dart';
import '../models/purchase_model.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  String? _userId;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final List<StreamSubscription> _firestoreSubscriptions = [];

  void setUserId(String? uid) {
    if (_userId == uid) return;
    stopRealtimeSync();
    _userId = uid;
  }

  CollectionReference<Map<String, dynamic>> _userCollection(String collection) {
    final uid = _userId;
    if (uid == null || uid.isEmpty) {
      throw StateError('Cannot sync without an authenticated user.');
    }
    return _firestore.collection('users').doc(uid).collection(collection);
  }

  void initialize() {
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

    isOnline().then((online) {
      if (online && _userId != null) {
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
    if (_isSyncing || _userId == null) return;
    _isSyncing = true;

    try {
      if (!await isOnline()) {
        debugPrint('[SyncService] Offline. Skipping sync.');
        return;
      }

      _dbHelper.setCurrentUserId(_userId);
      final items = await _dbHelper.getQueueItems();
      if (items.isEmpty) {
        debugPrint('[SyncService] Queue is empty.');
        return;
      }

      debugPrint('[SyncService] Syncing ${items.length} items from offline queue...');
      for (final item in items) {
        final docRef = _userCollection(item.collection).doc(item.recordId);

        try {
          if (item.action == 'DELETE') {
            await docRef.delete();
          } else {
            await docRef.set(item.data, SetOptions(merge: true));
          }
          if (item.id != null) {
            await _dbHelper.deleteQueueItem(item.id!);
          }
        } catch (error) {
          debugPrint('[SyncService] Failed to sync queue item ${item.id}: $error');
          break;
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
    if (_userId == null) return;
    if (_firestoreSubscriptions.isNotEmpty) return;

    debugPrint('[SyncService] Starting realtime Firestore streams for user $_userId...');
    _dbHelper.setCurrentUserId(_userId);

    _firestoreSubscriptions.add(
      _userCollection('products').snapshots().listen((snapshot) async {
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

    _firestoreSubscriptions.add(
      _userCollection('categories').snapshots().listen((snapshot) async {
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

    _firestoreSubscriptions.add(
      _userCollection('suppliers').snapshots().listen((snapshot) async {
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

    _firestoreSubscriptions.add(
      _userCollection('sales').snapshots().listen((snapshot) async {
        for (final doc in snapshot.docs) {
          try {
            final sale = SalesModel.fromMap(doc.data()..['id'] = doc.id);
            await _dbHelper.upsertSale(sale);
          } catch (e) {
            debugPrint('[SyncService] Error syncing sale doc: $e');
          }
        }
      }),
    );

    _firestoreSubscriptions.add(
      _userCollection('purchases').snapshots().listen((snapshot) async {
        for (final doc in snapshot.docs) {
          try {
            final purchase = PurchaseModel.fromMap(doc.data()..['id'] = doc.id);
            await _dbHelper.upsertPurchase(purchase);
          } catch (e) {
            debugPrint('[SyncService] Error syncing purchase doc: $e');
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
    if (_userId == null) return;
    try {
      _dbHelper.setCurrentUserId(_userId);
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
