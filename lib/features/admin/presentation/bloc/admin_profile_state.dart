part of 'admin_profile_bloc.dart';

abstract class AdminProfileState {}

class AdminProfileInitial extends AdminProfileState {}

class AdminProfileLoading extends AdminProfileState {}

class AdminProfileLoaded extends AdminProfileState {

  final Map<String, dynamic> profile;

  AdminProfileLoaded(this.profile);
}

class AdminProfileError extends AdminProfileState {

  final String message;

  final Map<String, dynamic>? profile;

  AdminProfileError(
    this.message,
    [this.profile]
  );
}