class RecentUser {
  final String id;
  final String name;
  final String email;
  final DateTime joinDate;
  final bool? isAdmin;
  final bool? isVerified;
  final bool? isBlocked;

  RecentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.joinDate,
    this.isAdmin,
    this.isVerified,
    this.isBlocked,
  });
}
