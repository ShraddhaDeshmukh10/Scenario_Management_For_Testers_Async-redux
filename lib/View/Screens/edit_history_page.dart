import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scenario_management_tool_for_testers/helper/tag_helper.dart';
import 'package:scenario_management_tool_for_testers/widgets/card_decoration.dart';

class EditHistoryPage extends StatelessWidget {
  final String scenarioId;
  final Color roleColor;
  final String designation;

  const EditHistoryPage({
    super.key,
    required this.scenarioId,
    required this.roleColor,
    required this.designation,
  });

  Future<List<Map<String, dynamic>>> _fetchChangeHistory() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(scenarioId)
          .collection('changes')
          .orderBy('timestamp', descending: true)
          .limit(11)
          .get();

      final changes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final testCaseId = data['testCaseId']?.toString();
        final tags =
            data['tags'] != null ? List<String>.from(data['tags']) : null;

        return {
          'docId': doc.id,
          ...data,
          'testCaseId': testCaseId?.isEmpty == true ? null : testCaseId,
          'tags': tags?.isEmpty == true ? null : tags,
        };
      }).toList();

      return changes.where((change) {
        return change['testCaseId'] != null || change['tags'] != null;
      }).toList();
    } catch (e) {
      print("Error fetching change history: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: roleColor,
        title: const Text('Edit History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchChangeHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final changes = snapshot.data ?? [];

          if (changes.isEmpty) {
            return const Center(child: Text('No changes found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: changes.length,
            itemBuilder: (context, index) {
              final change = changes[index];
              final testCaseId = change['testCaseId'];
              final tags = change['tags'] as List<String>?;
              final editedBy = change['editedBy'] ?? 'Unknown';
              final timestamp = change['timestamp'] != null
                  ? DateFormat("dd-MM-yyyy hh:mm a")
                      .format((change['timestamp'] as Timestamp).toDate())
                  : null;

              // Determine card color based on tags
              final cardColor =
                  tags != null ? Helper.getTagColor(tags) : Colors.white;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
                elevation: 5.0, // Adds shadow to the card
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                color: Colors.white, // Background color for the card
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: cardColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: cardColor.withOpacity(0.1),
                        blurRadius: 4.0,
                        spreadRadius: 2.0,
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (testCaseId != null)
                        buildInfoRow(
                          icon: Icons.assignment,
                          label: "Test Case ID",
                          value: testCaseId,
                          valueStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      if (tags != null)
                        buildInfoRow(
                          icon: Icons.label,
                          label: "Tags",
                          value: tags.join(', '),
                          valueStyle:
                              TextStyle(color: Helper.getTagColor(tags)),
                        ),
                      buildInfoRow(
                        icon: Icons.edit,
                        label: "Edited By",
                        value: editedBy,
                        valueStyle: const TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      if (timestamp != null)
                        buildInfoRow(
                          icon: Icons.access_time,
                          label: "Timestamp",
                          value: timestamp,
                          valueStyle: const TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
