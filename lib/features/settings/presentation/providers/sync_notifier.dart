import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/sync_status_model.dart';
import '../../data/settings_repository.dart';

class SyncNotifier extends StateNotifier<AsyncValue<SyncStatusModel>> {
  SyncNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadStatus();
  }

  final SettingsRepository _repository;

  Future<void> loadStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchSyncStatus);
  }

  Future<void> syncNow() async {
    final current = state.value;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(isSyncing: true));
    }

    state = await AsyncValue.guard(_repository.runSync);
  }
}
