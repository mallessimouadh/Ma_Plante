import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../providers/post_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCommentEmpty = true;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(() {
      setState(() {
        _isCommentEmpty = _commentController.text.trim().isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final currentUserId = postProvider.currentUser?.id ?? '';
    final updatedPost = postProvider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );
    final isLiked = updatedPost.likes.contains(currentUserId);
    final isSaved = updatedPost.savedBy.contains(currentUserId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Post Detail",
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF2E7D32),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved ? const Color(0xFF2E7D32) : Colors.grey,
            ),
            onPressed: () {
              if (isSaved) {
                postProvider.unsavePost(updatedPost.id, currentUserId);
              } else {
                postProvider.savePost(updatedPost.id, currentUserId);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green[100],
                                child: Text(
                                  updatedPost.userName.isNotEmpty ? updatedPost.userName[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    updatedPost.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(updatedPost.timestamp),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            updatedPost.content,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (updatedPost.imageUrl != null && updatedPost.imageUrl!.isNotEmpty)
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 300),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Image.network(
                              updatedPost.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (updatedPost.plantType != null && updatedPost.plantType!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Chip(
                              backgroundColor: Colors.green[50],
                              label: Text(
                                updatedPost.plantType!,
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontSize: 12,
                                ),
                              ),
                              avatar: Icon(
                                Icons.local_florist,
                                size: 16,
                                color: Colors.green[800],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  if (isLiked) {
                                    postProvider.unlikePost(updatedPost.id, currentUserId);
                                  } else {
                                    postProvider.likePost(updatedPost.id, currentUserId);
                                  }
                                },
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : Colors.grey[600],
                                  size: 20,
                                ),
                                label: Text(
                                  updatedPost.likes.length.toString(),
                                  style: TextStyle(
                                    color: isLiked ? Colors.red : Colors.grey[600],
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                label: Text(
                                  updatedPost.comments.length.toString(),
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      "Comments (${updatedPost.comments.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  updatedPost.comments.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              "No comments yet. Be the first to comment!",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: updatedPost.comments.length,
                          itemBuilder: (context, index) {
                            final comment = updatedPost.comments[index];
                            return _buildCommentItem(comment, currentUserId, postProvider);
                          },
                        ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isCommentEmpty ? Colors.grey[300] : const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                      onPressed: _isCommentEmpty
                          ? null
                          : () {
                              final commentText = _commentController.text.trim();
                              if (commentText.isNotEmpty) {
                                final newComment = Comment(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  userId: currentUserId,
                                  userName: postProvider.currentUser?.name ?? 'User',
                                  content: commentText,
                                  timestamp: DateTime.now(),
                                  likes: [],
                                );
                                postProvider.addComment(updatedPost.id, newComment);
                                _commentController.clear();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, String currentUserId, PostProvider provider) {
    final isCommentLiked = comment.likes.contains(currentUserId);
    final isAuthor = comment.userId == currentUserId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green[50],
                  child: Text(
                    comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(comment.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (isAuthor)
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    onPressed: () {
                      _showCommentOptions(context, widget.post.id, comment.id, provider);
                    },
                  ),
              ],
            ),
            Row(
              children: [
                const SizedBox(width: 40),
                TextButton.icon(
                  onPressed: () {
                    if (isCommentLiked) {
                      provider.unlikeComment(widget.post.id, comment.id, currentUserId);
                    } else {
                      provider.likeComment(widget.post.id, comment.id, currentUserId);
                    }
                  },
                  icon: Icon(
                    isCommentLiked ? Icons.favorite : Icons.favorite_border,
                    color: isCommentLiked ? Colors.red : Colors.grey[600],
                    size: 16,
                  ),
                  label: Text(
                    comment.likes.length.toString(),
                    style: TextStyle(
                      color: isCommentLiked ? Colors.red : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _commentController.text = "@${comment.userName} ";
                    _commentController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _commentController.text.length),
                    );
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  child: Text(
                    "Reply",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showCommentOptions(BuildContext context, String postId, String commentId, PostProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete comment'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteComment(context, postId, commentId, provider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit comment'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteComment(BuildContext context, String postId, String commentId, PostProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteComment(postId, commentId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comment deleted')),
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}