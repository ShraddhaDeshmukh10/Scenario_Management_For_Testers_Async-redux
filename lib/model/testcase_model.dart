import 'package:cloud_firestore/cloud_firestore.dart';

class TestCase {
  final String docId;
  final String name;
  final String bugId;
  final List<String> tags;
  final String comments;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TestCase({
    required this.docId,
    required this.name,
    required this.bugId,
    required this.tags,
    required this.comments,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory TestCase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestCase(
      docId: doc.id,
      name: data['name'] ?? '',
      bugId: data['bugId'] ?? '',
      tags: (data['tags'] is List)
          ? List<String>.from(data['tags'])
          : [data['tags']],
      comments: data['comments'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'name': name,
      'bugId': bugId,
      'tags': tags,
      'comments': comments,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
