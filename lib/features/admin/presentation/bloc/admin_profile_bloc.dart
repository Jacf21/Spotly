import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/admin_profile_repository_impl.dart';

part 'admin_profile_event.dart';
part 'admin_profile_state.dart';

class AdminProfileBloc
    extends Bloc<AdminProfileEvent, AdminProfileState> {

  final AdminProfileRepository repository;

  AdminProfileBloc(this.repository)
      : super(AdminProfileInitial()) {

    on<OnFetchAdminProfile>(_onFetchProfile);
    on<OnUpdateAdminProfile>(_onUpdateProfile);
    on<OnChangeAdminPassword>(_onChangePassword);
  }

  Future<void> _onFetchProfile(
    OnFetchAdminProfile event,
    Emitter<AdminProfileState> emit,
  ) async {

    emit(AdminProfileLoading());

    try {

      final profile = await repository.getProfile(event.userId);

      emit(AdminProfileLoaded(profile));

    } catch (e) {

      emit(
        AdminProfileError(
          'Error cargando perfil',
        ),
      );
    }
  }

  Future<void> _onUpdateProfile(
    OnUpdateAdminProfile event,
    Emitter<AdminProfileState> emit,
  ) async {

    final currentState = state;

    if (currentState is AdminProfileLoaded) {

      try {

        await repository.updateProfile(
          userId: currentState.profile['id_usuario'],
          nombres: event.nombres,
          apellidos: event.apellidos,
          username: event.username,
        );

        final updatedProfile =
            await repository.getProfile(
          currentState.profile['id_usuario'],
        );

        emit(
          AdminProfileLoaded(updatedProfile),
        );

      } catch (e) {

        emit(
          AdminProfileError(
            'Error actualizando perfil',
            currentState.profile,
          ),
        );
      }
    }
  }

  Future<void> _onChangePassword(
    OnChangeAdminPassword event,
    Emitter<AdminProfileState> emit,
  ) async {

    final currentState = state;

    if (currentState is AdminProfileLoaded) {

      try {

        await repository.changePassword(
          event.password,
        );

        emit(
          AdminProfileLoaded(
            currentState.profile,
          ),
        );

      } catch (e) {

        emit(
          AdminProfileError(
            _mapPasswordError(e.toString()),
            currentState.profile,
          ),
        );
      }
    }
  }

  String _mapPasswordError(String error) {

    if (error.contains('same_password')) {
      return 'La nueva contraseña debe ser distinta a la actual.';
    }

    return 'No se pudo actualizar la contraseña.';
  }
}