import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/recent_user.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({Key? key}) : super(key: key);

  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  late TabController _tabController;
  bool _isAddingUser = false;
  final Map<String, bool> _blockedStatusCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    final email = _emailController.text.trim().toLowerCase();
    final name = _nameController.text.trim();
    if (email.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and name are required')),
      );
      return;
    }

    setState(() {
      _isAddingUser = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: 'temporaryPassword123',
      );

      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'name': name,
        'email': email,
        'timestamp': Timestamp.now(),
        'isAdmin': false,
        'isVerified': false,
        'isBlocked': false,
      });

      _emailController.clear();
      _nameController.clear();
      setState(() {
        _isAddingUser = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('User added successfully'),
        backgroundColor: Color(0xFF4CAF50),
      ));
    } catch (e) {
      setState(() {
        _isAddingUser = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding user: $e')),
      );
    }
  }

  Future<bool> _blockUser(String email, bool currentIsBlocked) async {
    try {
      bool newIsBlocked = !currentIsBlocked;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email.toLowerCase())
          .update({
        'isBlocked': newIsBlocked,
      });

      setState(() {
        _blockedStatusCache.remove(email.toLowerCase());
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User has been ${newIsBlocked ? 'blocked' : 'unblocked'}',
          ),
          backgroundColor: newIsBlocked ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      _tabController.animateTo(newIsBlocked ? 1 : 0);
      return newIsBlocked;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user status: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return currentIsBlocked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'User Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAddingUser = !_isAddingUser;
                    });
                  },
                  icon: Icon(_isAddingUser ? Icons.close : Icons.person_add),
                  label: Text(_isAddingUser ? 'Cancel' : 'Add User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isAddingUser ? Colors.grey : Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isAddingUser)
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New User',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon:
                            const Icon(Icons.email, color: Color(0xFF4CAF50)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon:
                            const Icon(Icons.person, color: Color(0xFF4CAF50)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add User',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Users by Name or Email',
                hintText: 'Start typing to search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4CAF50)),
                suffixIcon: _searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active Users', icon: Icon(Icons.people)),
              Tab(text: 'Blocked Users', icon: Icon(Icons.block)),
            ],
            labelColor: const Color(0xFF2E7D32),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF4CAF50),
            indicatorWeight: 3,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(false),
                _buildUserList(true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(bool showBlocked) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('StreamBuilder Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('No users found in Firestore');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showBlocked ? Icons.no_accounts : Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  showBlocked
                      ? 'No blocked users found'
                      : 'No users found in database',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        List<RecentUser> allUsers = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          DateTime joinDate =
              (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
          String email = data['email']?.toString() ?? 'No email';
          return RecentUser(
            id: doc.id,
            name: data['name']?.toString() ?? 'Unknown',
            email: email,
            joinDate: joinDate,
            isBlocked: _blockedStatusCache[email] ??
                (data['isBlocked'] as bool? ?? false),
          );
        }).toList();

        List<RecentUser> filteredUsers = allUsers.where((user) {
          bool matchesTab = user.isBlocked == showBlocked;
          if (_searchTerm.isEmpty) return matchesTab;

          final name = user.name.toLowerCase();
          final email = user.email.toLowerCase();
          return matchesTab &&
              (name.contains(_searchTerm) || email.contains(_searchTerm));
        }).toList();

        if (filteredUsers.isEmpty) {
          print(
              'Filtered users empty: showBlocked=$showBlocked, searchTerm=$_searchTerm');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  showBlocked ? Icons.no_accounts : Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  showBlocked
                      ? 'No blocked users found'
                      : _searchTerm.isEmpty
                          ? 'No users found'
                          : 'No results found for "$_searchTerm"',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _blockedStatusCache.clear();
            });
          },
          color: const Color(0xFF4CAF50),
          child: ListView.builder(
            itemCount: filteredUsers.length,
            padding: const EdgeInsets.all(8),
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return _UserCard(
                user: user,
                onBlockUser: _blockUser,
              );
            },
          ),
        );
      },
    );
  }
}

class _UserCard extends StatefulWidget {
  final RecentUser user;
  final Future<bool> Function(String, bool) onBlockUser;

  const _UserCard({
    required this.user,
    required this.onBlockUser,
  });

  @override
  __UserCardState createState() => __UserCardState();
}

class __UserCardState extends State<_UserCard> {
  late bool _isBlocked;

  @override
  void initState() {
    super.initState();
    _isBlocked = widget.user.isBlocked ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isBlocked ? Colors.red.shade200 : Colors.green.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Hero(
          tag: 'avatar-${widget.user.email}',
          child: CircleAvatar(
            backgroundColor:
                _isBlocked ? Colors.red.shade300 : const Color(0xFF4CAF50),
            radius: 24,
            child: Text(
              widget.user.name.isNotEmpty
                  ? widget.user.name[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          widget.user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.user.email),
            const SizedBox(height: 4),
            Text(
              'Joined: ${DateFormat.yMMMd().format(widget.user.joinDate)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _isBlocked ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isBlocked ? 'Blocked' : 'Active',
                style: TextStyle(
                  color:
                      _isBlocked ? Colors.red.shade800 : Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                _isBlocked ? Icons.lock : Icons.lock_open,
                color: _isBlocked ? Colors.red : Colors.green,
              ),
              tooltip: _isBlocked ? 'Unblock User' : 'Block User',
              onPressed: () async {
                bool newIsBlocked =
                    await widget.onBlockUser(widget.user.email, _isBlocked);
                setState(() {
                  _isBlocked = newIsBlocked;
                });
              },
            ),
          ],
        ),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _UserDetailsModal(
              user: widget.user,
              onBlockUser: widget.onBlockUser,
              initialIsBlocked: _isBlocked,
            ),
          );
        },
      ),
    );
  }
}

class _UserDetailsModal extends StatefulWidget {
  final RecentUser user;
  final Future<bool> Function(String, bool) onBlockUser;
  final bool initialIsBlocked;

  const _UserDetailsModal({
    required this.user,
    required this.onBlockUser,
    required this.initialIsBlocked,
  });

  @override
  __UserDetailsModalState createState() => __UserDetailsModalState();
}

class __UserDetailsModalState extends State<_UserDetailsModal> {
  late bool _isBlocked;

  @override
  void initState() {
    super.initState();
    _isBlocked = widget.initialIsBlocked;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'avatar-${widget.user.email}',
                child: CircleAvatar(
                  backgroundColor: _isBlocked
                      ? Colors.red.shade300
                      : const Color(0xFF4CAF50),
                  radius: 40,
                  child: Text(
                    widget.user.name.isNotEmpty
                        ? widget.user.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.user.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isBlocked
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isBlocked ? 'Blocked' : 'Active',
                        style: TextStyle(
                          color: _isBlocked
                              ? Colors.red.shade800
                              : Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 40),
          _detailRow(Icons.calendar_today, 'Joined',
              DateFormat.yMMMMd().format(widget.user.joinDate)),
          _detailRow(Icons.verified_user, 'Account Status',
              _isBlocked ? 'Blocked' : 'Active'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                bool newIsBlocked =
                    await widget.onBlockUser(widget.user.email, _isBlocked);
                setState(() {
                  _isBlocked = newIsBlocked;
                });
                Navigator.pop(context);
              },
              icon: Icon(_isBlocked ? Icons.lock_open : Icons.lock),
              label: Text(_isBlocked ? 'Unblock User' : 'Block User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isBlocked ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
