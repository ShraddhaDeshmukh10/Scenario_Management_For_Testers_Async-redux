import 'package:scenario_management_tool_for_testers/model/comments_model.dart';

class CommentViewModel {
  final List<Comment> comments;
  final Function(String) addComment;
  final Function fetchComments;

  CommentViewModel({
    required this.comments,
    required this.addComment,
    required this.fetchComments,
  });
}
