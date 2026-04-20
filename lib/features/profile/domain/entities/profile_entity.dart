class ProfileEntity {
  final String id;
  final String email;
  final String nombres;
  final String apellidos;
  final String username;
  final String? bio;
  final String? photoUrl;

  ProfileEntity({
    required this.id,
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.username,
    this.bio,
    this.photoUrl,
  });
}
