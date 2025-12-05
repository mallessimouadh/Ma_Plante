class User {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;

  User({required this.id, required this.name, this.email, this.avatarUrl});
}
