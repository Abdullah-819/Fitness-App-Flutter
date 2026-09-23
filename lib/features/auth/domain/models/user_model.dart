/// Model representing an authenticated user.
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
  });

  @override
  String toString() => 'UserModel(id: $id, email: $email, name: $name)';
}
