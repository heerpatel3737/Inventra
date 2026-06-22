class SyncStatusModel {
  final DateTime? lastSuccessfulSync;
  final int pendingRecords;
  final int conflictCount;
  final bool isSyncing;

  const SyncStatusModel({
    this.lastSuccessfulSync,
    this.pendingRecords = 0,
    this.conflictCount = 0,
    this.isSyncing = false,
  });

  SyncStatusModel copyWith({
    DateTime? lastSuccessfulSync,
    int? pendingRecords,
    int? conflictCount,
    bool? isSyncing,
  }) {
    return SyncStatusModel(
      lastSuccessfulSync: lastSuccessfulSync ?? this.lastSuccessfulSync,
      pendingRecords: pendingRecords ?? this.pendingRecords,
      conflictCount: conflictCount ?? this.conflictCount,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': 1,
      'lastSuccessfulSync': lastSuccessfulSync?.toIso8601String(),
      'pendingRecords': pendingRecords,
      'conflictCount': conflictCount,
    };
  }

  factory SyncStatusModel.fromMap(Map<String, dynamic> map) {
    final rawSyncDate = map['lastSuccessfulSync'] as String?;
    return SyncStatusModel(
      lastSuccessfulSync: rawSyncDate == null ? null : DateTime.parse(rawSyncDate),
      pendingRecords: map['pendingRecords'] as int? ?? 0,
      conflictCount: map['conflictCount'] as int? ?? 0,
    );
  }
}
