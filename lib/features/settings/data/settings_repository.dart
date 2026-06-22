import '../../../data/database/database_helper.dart';
import '../../../models/role_model.dart';
import '../../../models/sync_status_model.dart';
import '../../../models/user_profile_model.dart';

class SettingsRepository {
  SettingsRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<UserProfileModel> fetchProfile() {
    return _databaseHelper.getProfile();
  }

  Future<void> updateProfile(UserProfileModel profile) {
    return _databaseHelper.upsertProfile(profile);
  }

  Future<List<RoleModel>> fetchRoles() {
    return _databaseHelper.getRoles();
  }

  Future<void> updateRole(RoleModel role) {
    return _databaseHelper.upsertRole(role);
  }

  Future<SyncStatusModel> fetchSyncStatus() {
    return _databaseHelper.getSyncStatus();
  }

  Future<SyncStatusModel> runSync() async {
    final status = SyncStatusModel(
      lastSuccessfulSync: DateTime.now(),
      pendingRecords: 0,
      conflictCount: 0,
    );
    await _databaseHelper.upsertSyncStatus(status);
    return status;
  }
}
