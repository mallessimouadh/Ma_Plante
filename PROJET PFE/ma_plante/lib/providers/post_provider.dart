import 'package:flutter/material.dart';
import '../models/post.dart';
import '../models/comment.dart';
import '../models/user.dart';

class PostProvider extends ChangeNotifier {
  List<Post> _posts = [];
  bool _isLoading = false;


  User? _currentUser = User(
    id: 'user123',
    name: 'Plant Lover',
    email: 'plant.lover@example.com',
  );

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  
  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      
      await Future.delayed(const Duration(seconds: 1));

      
      _posts = [
        Post(
          id: 'post1',
          userId: 'user456',
          userName: 'Green Thumb',
          content:
              'My monstera has new leaves! So excited to see it growing well.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          likes: ['user123', 'user789'],
          comments: [
            Comment(
              id: 'comment1',
              userId: 'user789',
              userName: 'Plant Enthusiast',
              content: 'Beautiful! How often do you water it?',
              timestamp: DateTime.now().subtract(const Duration(hours: 1)),
              likes: ['user123'],
            ),
          ],
          savedBy: ['user123'],
          imageUrl: 'https://example.com/plant1.jpg',
          plantType: 'Monstera',
        ),
        Post(
          id: 'post2',
          userId: 'user123',
          userName: 'Plant Lover',
          content:
              'Can someone help identify what\'s wrong with my aloe vera? The leaves are turning brown.',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          likes: [],
          comments: [],
          savedBy: [],
          imageUrl: 'https://example.com/plant2.jpg',
          plantType: 'Aloe Vera',
        ),
        Post(
          id: 'post3',
          userId: 'user789',
          userName: 'Plant Enthusiast',
          content:
              'Just repotted my snake plant! Any tips for helping it adjust to the new pot?',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          likes: ['user456'],
          comments: [
            Comment(
              id: 'comment2',
              userId: 'user456',
              userName: 'Green Thumb',
              content:
                  'Don\'t water it for a week, snake plants are sensitive to overwatering after being repotted.',
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              likes: ['user123', 'user789'],
            ),
            Comment(
              id: 'comment3',
              userId: 'user123',
              userName: 'Plant Lover',
              content: 'Make sure it gets plenty of indirect light!',
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              likes: [],
            ),
          ],
          savedBy: [],
          imageUrl: 'https://example.com/plant3.jpg',
          plantType: 'Snake Plant',
        ),
      ];
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<void> createPost(Post post) async {
    try {
     
      _posts.insert(0, post);
      notifyListeners();
    } catch (e) {
      print('Error creating post: $e');
      throw e;
    }
  }

  
  Future<void> deletePost(String postId) async {
    try {
      _posts.removeWhere((post) => post.id == postId);
      notifyListeners();
    } catch (e) {
      print('Error deleting post: $e');
      throw e;
    }
  }

  
  Future<void> likePost(String postId, String userId) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final likes = List<String>.from(post.likes);

        if (!likes.contains(userId)) {
          likes.add(userId);

          _posts[index] = post.copyWith(likes: likes);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error liking post: $e');
      throw e;
    }
  }

  
  Future<void> unlikePost(String postId, String userId) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final likes = List<String>.from(post.likes);

        likes.remove(userId);

        _posts[index] = post.copyWith(likes: likes);
        notifyListeners();
      }
    } catch (e) {
      print('Error unliking post: $e');
      throw e;
    }
  }

  
  Future<void> savePost(String postId, String userId) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final savedBy = List<String>.from(post.savedBy);

        if (!savedBy.contains(userId)) {
          savedBy.add(userId);

          _posts[index] = post.copyWith(savedBy: savedBy);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error saving post: $e');
      throw e;
    }
  }

  
  Future<void> unsavePost(String postId, String userId) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final savedBy = List<String>.from(post.savedBy);

        savedBy.remove(userId);

        _posts[index] = post.copyWith(savedBy: savedBy);
        notifyListeners();
      }
    } catch (e) {
      print('Error unsaving post: $e');
      throw e;
    }
  }

  
  Future<void> addComment(String postId, Comment comment) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final comments = List<Comment>.from(post.comments);

        comments.add(comment);

        _posts[index] = post.copyWith(comments: comments);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding comment: $e');
      throw e;
    }
  }

  
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final index = _posts.indexWhere((post) => post.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final comments = List<Comment>.from(post.comments);

        comments.removeWhere((comment) => comment.id == commentId);

        _posts[index] = post.copyWith(comments: comments);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting comment: $e');
      throw e;
    }
  }

  
  Future<void> likeComment(
    String postId,
    String commentId,
    String userId,
  ) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final comments = List<Comment>.from(post.comments);

        final commentIndex = comments.indexWhere(
          (comment) => comment.id == commentId,
        );
        if (commentIndex != -1) {
          final comment = comments[commentIndex];
          final likes = List<String>.from(comment.likes);

          if (!likes.contains(userId)) {
            likes.add(userId);

            comments[commentIndex] = comment.copyWith(likes: likes);
            _posts[postIndex] = post.copyWith(comments: comments);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error liking comment: $e');
      throw e;
    }
  }

  
  Future<void> unlikeComment(
    String postId,
    String commentId,
    String userId,
  ) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final comments = List<Comment>.from(post.comments);

        final commentIndex = comments.indexWhere(
          (comment) => comment.id == commentId,
        );
        if (commentIndex != -1) {
          final comment = comments[commentIndex];
          final likes = List<String>.from(comment.likes);

          likes.remove(userId);

          comments[commentIndex] = comment.copyWith(likes: likes);
          _posts[postIndex] = post.copyWith(comments: comments);
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error unliking comment: $e');
      throw e;
    }
  }
}
