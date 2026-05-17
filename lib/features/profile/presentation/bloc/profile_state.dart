part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  ProfileLoaded(this.profile);
}

class ProfileAvatarUpdating extends ProfileState {}
class ProfileAvatarUpdated extends ProfileState {
  final String newUrl;
  ProfileAvatarUpdated(this.newUrl);
}

class ProfileUpdateSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
