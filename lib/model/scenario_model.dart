import 'package:cloud_firestore/cloud_firestore.dart';

class Scenario {
  final String docId;
  final String projectName;
  final String shortDescription;
  final String name;
  final String assignedToEmail;
  final String createdByEmail;
  final String projectId;
  final DateTime createdAt;

  Scenario({
    required this.docId,
    required this.projectName,
    required this.shortDescription,
    required this.name,
    required this.assignedToEmail,
    required this.createdByEmail,
    required this.projectId,
    required this.createdAt,
  });

  // Factory method to create a Scenario object from Firestore data
  factory Scenario.fromFirestore(String id, Map<String, dynamic> data) {
    return Scenario(
      docId: id,
      projectName: data['projectName'] ?? '',
      shortDescription: data['shortDescription'] ?? '',
      name: data['name'] ?? 'Unnamed Scenario',
      assignedToEmail: data['assignedToEmail'] ?? '',
      createdByEmail: data['createdByEmail'] ?? '',
      projectId: data['projectId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Convert Scenario object to Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'projectName': projectName,
      'shortDescription': shortDescription,
      'name': name,
      'assignedToEmail': assignedToEmail,
      'createdByEmail': createdByEmail,
      'projectId': projectId,
      'createdAt': Timestamp.fromDate(
          createdAt), // Ensure DateTime is converted to Timestamp
    };
  }

  // Convert Scenario object to a general-purpose map for UI
  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'projectName': projectName,
      'shortDescription': shortDescription,
      'name': name,
      'assignedToEmail': assignedToEmail,
      'createdByEmail': createdByEmail,
      'projectId': projectId,
      'createdAt': createdAt, // Keep as DateTime
    };
  }
}
