class Comment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime timestamp;
  final List<String> likes;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.timestamp,
    required this.likes,
  });

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? content,
    DateTime? timestamp,
    List<String>? likes,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      likes: likes ?? this.likes,
    );
  }
}
