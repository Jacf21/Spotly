part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class OnFetchProfile extends ProfileEvent {
  final String userId;
  OnFetchProfile(this.userId);
}

class OnUpdateProfile extends ProfileEvent {
  final String nombres;
  final String apellidos;
  final String nombreUsuario;
  final String? biografia;
  final String? genero;
  final String? fechaNacimiento;
  final String? pais;
  final String? ciudad;

  OnUpdateProfile({
    required this.nombres,
    required this.apellidos,
    required this.nombreUsuario,
    this.biografia,
    this.genero,
    this.fechaNacimiento,
    this.pais,
    this.ciudad,
  });
}
