import 'comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;
  final List<String> savedBy;
  final String? imageUrl;
  final String? plantType;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.savedBy,
    this.imageUrl,
    this.plantType,
  });

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    DateTime? timestamp,
    List<String>? likes,
    List<Comment>? comments,
    List<String>? savedBy,
    String? imageUrl,
    String? plantType,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      savedBy: savedBy ?? this.savedBy,
      imageUrl: imageUrl ?? this.imageUrl,
      plantType: plantType ?? this.plantType,
    );
  }
}