import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scenario_management_tool_for_testers/helper/tag_helper.dart';
import 'package:scenario_management_tool_for_testers/model/change_history.dart';
import 'package:scenario_management_tool_for_testers/widgets/card_decoration.dart';

class EditHistoryPage extends StatelessWidget {
  final String scenarioId;
  final Color roleColor;
  final String designation;
  final List<ChangeHistory> changes;

  const EditHistoryPage({
    super.key,
    required this.scenarioId,
    required this.roleColor,
    required this.designation,
    required this.changes,
  });

  @override
  Widget build(BuildContext context) {
    print("Changes passed to the UI: ${changes.length}");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: roleColor,
        title: const Text('Edit History'),
      ),
      body: changes.isEmpty
          ? const Center(child: Text('No changes found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: changes.length,
              itemBuilder: (context, index) {
                final change = changes[index];
                final testCaseId = change.testCaseId ??
                    "Unknown"; // This will now be the Bug ID

                // final testCaseId =
                //     change.testCaseId ?? "Unknown"; // Ensure ID is present
                final tags = change.tags;
                final editedBy = change.editedBy;
                final timestamp = DateFormat("dd-MM-yyyy hh:mm a")
                    .format(change.timestamp.toDate());

                final cardColor =
                    tags != null ? Helper.getTagColor(tags) : Colors.white;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
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
            ),
    );
  }
}
