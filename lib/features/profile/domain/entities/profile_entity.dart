class ProfileEntity {
  final String id;
  final String email;
  final String nombres;
  final String apellidos;
  final String username;
  final String? bio;
  final String? photoUrl;
  final String? genero;
  final String? fechaNacimiento;
  final String? pais;
  final String? ciudad;

  ProfileEntity({
    required this.id,
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.username,
    this.bio,
    this.photoUrl,
    this.genero,
    this.fechaNacimiento,
    this.pais,
    this.ciudad,
  });
}
