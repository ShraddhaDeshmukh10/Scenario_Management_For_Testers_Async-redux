import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
          .limit(10)
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
    Color _getTagColor(List<dynamic>? tags) {
      // Ensure there is at least one tag
      if (tags != null && tags.isNotEmpty) {
        // Cast the first tag to String if it's dynamic
        final tag =
            tags[0] as String; // Ensure that the tag is treated as a String

        switch (tag) {
          case "Passed":
            return Colors.green; // Green for "Passed"
          case "Failed":
            return Colors.red; // Red for "Failed"
          case "In Review":
            return Color.fromARGB(255, 189, 173, 22); // Yellow for "In Review"
          case "Completed":
            return Colors.orange; // Orange for "Completed"
          default:
            return Colors.black; // Default color for unknown tags
        }
      }
      return Colors.black; // Default color when no tags are present
    }

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

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (testCaseId != null)
                        _buildInfoRow(
                          icon: Icons.assignment,
                          label: "Test Case ID",
                          value: testCaseId,
                          valueStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      if (tags != null)
                        _buildInfoRow(
                          icon: Icons.label,
                          label: "Tags",
                          value: tags.join(', '),
                          valueStyle: TextStyle(color: _getTagColor(tags)),
                        ),
                      _buildInfoRow(
                        icon: Icons.edit,
                        label: "Edited By",
                        value: editedBy,
                        valueStyle: const TextStyle(
                            fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                      if (timestamp != null)
                        _buildInfoRow(
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ??
                TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
