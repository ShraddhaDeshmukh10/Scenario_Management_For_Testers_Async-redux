import 'package:cloud_firestore/cloud_firestore.dart';

class TestCase {
  final String docId;
  //final String id;
  final String name;
  final String bugId;
  final List<String> tags; // Updated to List<String>
  final String comments;
  final String description;
  final String createdBy;
  final DateTime createdAt; // Ensure this is DateTime
  final DateTime? updatedAt; // Add updatedAt

  TestCase({
    required this.docId,
    //required this.id,
    required this.name,
    required this.bugId,
    required this.tags,
    required this.comments,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt, // Optional updatedAt
  });

  // Factory method to create a TestCase object from Firestore data
  factory TestCase.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestCase(
      docId: doc.id,
      // id: doc
      //     .id, // This ensures the Firestore document ID is used as the test case ID
      name: data['name'] ?? '',
      bugId: data['bugId'] ?? '',
      tags: (data['tags'] is List)
          ? List<String>.from(data['tags'])
          : [data['tags']], // Fix the tags field
      comments: data['comments'] ?? '',
      description: data['description'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert TestCase object to Firestore-compatible map
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
      'updatedAt': updatedAt, // Add updatedAt if necessary
    };
  }
}
