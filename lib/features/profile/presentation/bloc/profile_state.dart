part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {} // Para mostrar el cargando

class ProfileLoaded extends ProfileState {
  // Cuando los datos ya llegaron
  final dynamic user;
  ProfileLoaded(this.user);
}

class ProfileError extends ProfileState {
  // Si algo sale mal (ej: sin internet)
  final String message;
  ProfileError(this.message);
}

class ProfileUpdateSuccess
    extends ProfileState {} // Para avisar que se guardó bien
