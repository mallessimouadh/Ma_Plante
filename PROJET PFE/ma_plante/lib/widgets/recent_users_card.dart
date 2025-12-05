  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:intl/intl.dart';
  import '../models/recent_user.dart';

class RecentUsersCard extends StatelessWidget {
  final List<RecentUser> users;
  final VoidCallback? onViewAll;

  const RecentUsersCard({Key? key, required this.users, this.onViewAll})
      : super(key: key);

  Future<void> _blockUser(String email, bool isBlocked) async {
    await FirebaseFirestore.instance.collection('users').doc(email).update({
      'isBlocked': !isBlocked,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recently Joined Users',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(onPressed: onViewAll, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 16),
            if (users.isEmpty)
              const Center(child: Text('No recent users found'))
            else
              ...users.map((user) => _buildUserItem(context, user)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, RecentUser user) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            dateFormat.format(user.joinDate),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              user.isBlocked == true ? Icons.lock : Icons.lock_open,
              color: user.isBlocked == true ? Colors.red : Colors.green,
            ),
            onPressed: () =>
                _blockUser(user.email, user.isBlocked ?? false).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${user.name} has been ${user.isBlocked == true ? 'unblocked' : 'blocked'}',
                  ),
                ),
              );
            }).catchError((e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating user status: $e'),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
