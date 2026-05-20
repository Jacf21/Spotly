part of 'admin_profile_bloc.dart';

abstract class AdminProfileEvent {}

class OnFetchAdminProfile extends AdminProfileEvent {
  final String userId;

  OnFetchAdminProfile(this.userId);
}

class OnUpdateAdminProfile extends AdminProfileEvent {
  final String nombres;
  final String apellidos;
  final String username;

  OnUpdateAdminProfile({
    required this.nombres,
    required this.apellidos,
    required this.username,
  });
}

class OnChangeAdminPassword extends AdminProfileEvent {
  final String password;

  OnChangeAdminPassword(this.password);
}