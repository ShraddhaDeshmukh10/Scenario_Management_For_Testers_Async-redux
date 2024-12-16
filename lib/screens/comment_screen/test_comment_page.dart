import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:scenario_management_tool_for_testers/Services/data_service.dart';
import 'package:scenario_management_tool_for_testers/model/comments_model.dart';

class TestCaseCommentsDisplay extends StatefulWidget {
  final List<Comment> comments;
  final Function(String, String?) addComment;
  final Color roleColor;
  final String designation;

  const TestCaseCommentsDisplay({
    Key? key,
    required this.comments,
    required this.addComment,
    required this.roleColor,
    required this.designation,
    required String scenarioId,
  }) : super(key: key);

  @override
  State<TestCaseCommentsDisplay> createState() =>
      _TestCaseCommentsDisplayState();
}

class _TestCaseCommentsDisplayState extends State<TestCaseCommentsDisplay> {
  final TextEditingController comment1Controller = TextEditingController();
  String? imageUrl;

  void _handleAddComment() {
    final commentText = comment1Controller.text.trim();
    if (commentText.isEmpty) {
      Fluttertoast.showToast(
        msg: "Comment cannot be empty!",
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
    } else {
      widget.addComment(commentText, imageUrl);
      comment1Controller.clear();
      if (imageUrl != null) {}
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
                      border: const OutlineInputBorder(),
                      labelText: "Add Comment......",
                      suffixIcon: IconButton(
                        tooltip: "Add Attachment",
                        onPressed: () {
                          _pickImage(context, (url) {
                            setState(() {
                              imageUrl =
                                  url; // Correctly updates the imageUrl state
                            });
                          });
                        },
                        icon: const Icon(Icons.attachment),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: "Send",
                onPressed: _handleAddComment,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
          Expanded(
            child: widget.comments.isEmpty
                ? const Center(child: Text('No comments yet.'))
                : ListView.builder(
                    itemCount: widget.comments.length,
                    itemBuilder: (context, index) {
                      final comment = widget.comments[index];
                      final formattedDate = DateFormat("dd-MM-yyyy hh:mm a")
                          .format(comment.createdAt);
                      final imageUrl = comment.attachment;
                      final createdBy = comment.createdBy;
                      final currentUser =
                          FirebaseAuth.instance.currentUser?.email;

                      // Determine if the comment is from the current user
                      bool isCurrentUser = createdBy == currentUser;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: isCurrentUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            // Comment Container with background color and alignment based on the user
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.lightBlue
                                          .shade100 // Current user's comment color
                                      : Colors.grey
                                          .shade200, // Other users' comment color
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: isCurrentUser
                                      ? CrossAxisAlignment
                                          .end // Align text to the right for current user
                                      : CrossAxisAlignment
                                          .start, // Align text to the left for others
                                  children: [
                                    Text(
                                      comment.text,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                    Text(
                                      "By: $createdBy",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildAvatar(imageUrl,
                                context), // Display avatar for every comment
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

void _pickImage(BuildContext context, Function(String) onImageUploaded) async {
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
