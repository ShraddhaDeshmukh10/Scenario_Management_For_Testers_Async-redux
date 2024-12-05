import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scenario_management_tool_for_testers/Services/dataservice.dart';

class TestCaseCommentsPage extends StatefulWidget {
  final String scenarioId;
  final String testCaseId;
  final Color roleColor;
  final String designation;

  const TestCaseCommentsPage({
    super.key,
    required this.scenarioId,
    required this.testCaseId,
    required this.roleColor,
    required this.designation,
  });

  @override
  State<TestCaseCommentsPage> createState() => _TestCaseCommentsPageState();
}

class _TestCaseCommentsPageState extends State<TestCaseCommentsPage> {
  final TextEditingController comment1Controller = TextEditingController();
  String? imageUrl;
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshComments(); // Load comments on page load
  }

  Future<void> _refreshComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('scenarios')
          .doc(widget.scenarioId)
          .collection('testCases')
          .doc(widget.testCaseId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get();

      final fetchedComments = snapshot.docs.map((doc) {
        return {'docId': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();

      setState(() {
        comments = fetchedComments;
      });
    } catch (e) {
      print("Error fetching comments: $e");
      Fluttertoast.showToast(
        msg: "Failed to refresh comments.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addComment(String commentText) async {
    if (commentText.isNotEmpty) {
      try {
        final commentData = {
          'text': commentText,
          'createdBy':
              FirebaseAuth.instance.currentUser?.email ?? 'unknown_user',
          'timestamp': FieldValue.serverTimestamp(),
          'attachment': imageUrl ?? '',
        };

        await FirebaseFirestore.instance
            .collection('scenarios')
            .doc(widget.scenarioId)
            .collection('testCases')
            .doc(widget.testCaseId)
            .collection('comments')
            .add(commentData);

        Fluttertoast.showToast(
          msg: "Comment added successfully!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        comment1Controller.clear();
        imageUrl = null;

        // Refresh the comments
        _refreshComments();
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error adding comment",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Comment cannot be empty!",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.roleColor,
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: comment1Controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Add Comment......",
                      suffixIcon: IconButton(
                        tooltip: "Add Attachment",
                        onPressed: () {
                          _pickImage(context, (url) => imageUrl = url);
                        },
                        icon: const Icon(Icons.attachment),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: "Send..",
                onPressed: () async {
                  final commentText = comment1Controller.text.trim();
                  await _addComment(commentText);
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : comments.isEmpty
                    ? const Center(child: Text('No comments yet.'))
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          final imageUrl = comment['attachment'] as String?;
                          final timestamp = comment['timestamp'] as Timestamp?;
                          final formattedDate = timestamp != null
                              ? DateFormat("dd-MM-yyyy hh:mm a")
                                  .format(timestamp.toDate())
                              : 'N/A';
                          final createdBy =
                              comment['createdBy'] ?? 'unknown_user';
                          final currentUserEmail =
                              FirebaseAuth.instance.currentUser?.email;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: createdBy == currentUserEmail
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (createdBy != currentUserEmail) ...[
                                  _buildAvatar(imageUrl, context),
                                  const SizedBox(width: 8),
                                ],
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: createdBy == currentUserEmail
                                          ? Colors.blue.shade100
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['text'] ?? 'N/A',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "By: $createdBy",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (createdBy == currentUserEmail) ...[
                                  const SizedBox(width: 8),
                                  _buildAvatar(imageUrl, context),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, BuildContext context) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          _showImageDialog(context, imageUrl);
        },
        child: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          radius: 20,
        ),
      );
    } else {
      return const CircleAvatar(
        child: Icon(Icons.person),
        radius: 20,
      );
    }
  }

  void _pickImage(
      BuildContext context, Function(String) onImageUploaded) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File file = File(result.files.single.path!);
      String? uploadedUrl = await _uploadImage(file);
      if (uploadedUrl != null) {
        Fluttertoast.showToast(
          msg: "Image uploaded successfully!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        _showImageDialog(context, uploadedUrl);
        onImageUploaded(uploadedUrl);
      } else {
        Fluttertoast.showToast(
          msg: "Failed to upload image.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<String?> _uploadImage(File file) async {
    try {
      Uint8List fileBytes = await file.readAsBytes();
      String fileName = file.uri.pathSegments.last;

      final dataService = GetIt.instance<DataService>();
      final http.Response response =
          await dataService.uploadFile(fileBytes, fileName);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String relativeImageUrl = responseData['data'];
        return "https://dev.orderbookings.com$relativeImageUrl";
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
