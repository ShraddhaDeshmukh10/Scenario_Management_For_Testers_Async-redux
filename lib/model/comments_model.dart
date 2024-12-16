import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String docId;
  final String text;
  final String createdBy;
  final DateTime createdAt;
  final String? attachment;

  Comment({
    required this.docId,
    required this.text,
    required this.createdBy,
    required this.createdAt,
    this.attachment,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      docId: doc.id,
      text: data['text'] ?? '',
      createdBy: data['createdBy'] ?? 'unknown_user',
      createdAt: (data['timestamp'] as Timestamp).toDate(),
      attachment: data['attachment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdBy': createdBy,
      'timestamp': FieldValue.serverTimestamp(),
      'attachment': attachment,
    };
  }
}
