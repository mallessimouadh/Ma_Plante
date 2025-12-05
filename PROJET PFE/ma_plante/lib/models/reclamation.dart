import 'package:cloud_firestore/cloud_firestore.dart';

class Reclamation {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String description;
  final DateTime createdAt;
  final String status;
  final String priority;
  final String? adminResponse;
  final DateTime? resolvedAt;

  Reclamation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    required this.priority,
    this.adminResponse,
    this.resolvedAt,
  });

  factory Reclamation.fromFirestore(Map<String, dynamic> data, String id) {
    return Reclamation(
      id: id,
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? 'Anonymous',
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status']?.toString() ?? 'pending',
      priority: data['priority']?.toString() ?? 'medium',
      adminResponse: data['adminResponse']?.toString(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Reclamation copyWith({
    String? id,
    String? userId,
    String? userName,
    String? title,
    String? description,
    DateTime? createdAt,
    String? status,
    String? priority,
    String? adminResponse,
    DateTime? resolvedAt,
  }) {
    return Reclamation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      adminResponse: adminResponse ?? this.adminResponse,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
