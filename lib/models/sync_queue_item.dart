import 'dart:convert';

class SyncQueueItem {
  final int? id;
  final String collection;
  final String action; // 'CREATE', 'UPDATE', 'DELETE'
  final String recordId;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const SyncQueueItem({
    this.id,
    required this.collection,
    required this.action,
    required this.recordId,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'collection': collection,
      'action': action,
      'recordId': recordId,
      'data': jsonEncode(data),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id'] as int?,
      collection: map['collection'] as String,
      action: map['action'] as String,
      recordId: map['recordId'] as String,
      data: Map<String, dynamic>.from(jsonDecode(map['data'] as String)),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
