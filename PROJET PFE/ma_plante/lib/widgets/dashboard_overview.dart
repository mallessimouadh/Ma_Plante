import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/recent_user.dart';
import '../widgets/recent_users_card.dart';
import '../providers/dashboard_state_provider.dart';

class DashboardOverview extends StatefulWidget {
  const DashboardOverview({Key? key}) : super(key: key);

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  late Stream<List<RecentUser>> _recentUsersStream;

  @override
  void initState() {
    super.initState();
    _recentUsersStream = _fetchRecentUsers();
  }

  Stream<List<RecentUser>> _fetchRecentUsers() {
    return FirebaseFirestore.instance
        .collection('users')
        .orderBy('timestamp',
            descending:
                true) 
        .limit(5)
        .snapshots()
        .map((snapshot) {
      print('Fetched documents: ${snapshot.docs.length}');
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        DateTime joinDate = (data['timestamp'] as Timestamp?)?.toDate() ??
            DateTime.now(); 
        print('User data: $data');
        return RecentUser(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          email: data['email'] ?? 'No email',
          joinDate: joinDate,
          isAdmin: data['isAdmin'] ?? false,
          isVerified: data['isVerified'] ?? false,
          isBlocked: data['isBlocked'] ?? false,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vue d\'ensemble',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<RecentUser>>(
              stream: _recentUsersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(child: Text('Error: ${snapshot.error}')),
                    ),
                  );
                }
                final users = snapshot.data ?? [];
                return RecentUsersCard(
                  users: users,
                  onViewAll: () {
                    print('Navigating to UserManagement');
                    Provider.of<DashboardStateProvider>(
                      context,
                      listen: false,
                    ).setSelectedIndex(1);
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            _buildStatCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        int totalUsers = 0;
        int activeUsers = 0;

        if (snapshot.hasData) {
          totalUsers = snapshot.data!.docs.length;
          activeUsers = snapshot.data!.docs
              .where(
                (doc) =>
                    !(doc.data() as Map<String, dynamic>)['isBlocked'] ?? false,
              )
              .length;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildStatCard(
              context,
              'Total Users',
              totalUsers.toString(),
              Icons.people,
            ),
            _buildStatCard(
              context,
              'Active Users',
              activeUsers.toString(),
              Icons.person,
            ),
            _buildStatCard(context, 'Total Scans', '0', Icons.document_scanner),
            _buildStatCard(context, 'Diseases Detected', '0', Icons.sick),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
