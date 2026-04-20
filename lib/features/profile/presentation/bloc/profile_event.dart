part of 'profile_bloc.dart';

abstract class ProfileEvent {}

// Evento para cargar los datos desde Supabase
class OnFetchProfile extends ProfileEvent {
  final String userId;
  OnFetchProfile(this.userId);
}

// Evento para cuando el usuario le da a "Guardar"
class OnUpdateProfile extends ProfileEvent {
  final String nombres;
  final String apellidos;
  final String nombreUsuario;

  OnUpdateProfile(
      {required this.nombres,
      required this.apellidos,
      required this.nombreUsuario});
}
