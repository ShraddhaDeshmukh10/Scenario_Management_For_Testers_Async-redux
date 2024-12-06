import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeHistory {
  final String docId;
  final String? testCaseId;
  final List<String>? tags;
  final String editedBy;
  final Timestamp timestamp;

  ChangeHistory({
    required this.docId,
    this.testCaseId,
    this.tags,
    required this.editedBy,
    required this.timestamp,
  });

  factory ChangeHistory.fromMap(String docId, Map<String, dynamic> data) {
    return ChangeHistory(
      docId: docId,
      testCaseId: data['testCaseId'] as String?,
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      editedBy: data['editedBy'] as String? ?? '',
      timestamp: data['timestamp'] as Timestamp,
    );
  }
}
