import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../models/recent_user.dart';
import '../models/disease_detection.dart';

class DashboardProvider with ChangeNotifier {
  late DashboardStats _stats;
  List<RecentUser> _recentUsers = [];
  List<DiseaseDetection> _recentDetections = [];

  DashboardStats get stats => _stats;
  List<RecentUser> get recentUsers => _recentUsers;
  List<DiseaseDetection> get recentDetections => _recentDetections;

  DashboardProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    
    await Future.delayed(const Duration(seconds: 1));

    _stats = DashboardStats(
      totalUsers: 1458,
      activeUsers: 987,
      totalScans: 5621,
      diseasesDetected: 893,
      reclamationsOpen: 12,
      reclamationsResolved: 158,
    );

    _recentUsers = [
      RecentUser(
        id: '1',
        name: 'Sarah Johnson',
        email: 'sarah@example.com',
        joinDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      RecentUser(
        id: '2',
        name: 'Michael Chen',
        email: 'mike@example.com',
        joinDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      RecentUser(
        id: '3',
        name: 'Amina Patel',
        email: 'amina@example.com',
        joinDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      RecentUser(
        id: '4',
        name: 'Carlos Rodriguez',
        email: 'carlos@example.com',
        joinDate: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];

    _recentDetections = [
      DiseaseDetection(
        id: '1',
        userId: '3',
        userName: 'Amina Patel',
        plantName: 'Tomato',
        diseaseName: 'Early Blight',
        confidence: 0.92,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      DiseaseDetection(
        id: '2',
        userId: '1',
        userName: 'Sarah Johnson',
        plantName: 'Apple',
        diseaseName: 'Cedar Apple Rust',
        confidence: 0.88,
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      DiseaseDetection(
        id: '3',
        userId: '4',
        userName: 'Carlos Rodriguez',
        plantName: 'Rice',
        diseaseName: 'Brown Spot',
        confidence: 0.95,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    notifyListeners();
  }

  Future<void> refreshData() async {
    await _loadInitialData();
  }
}
