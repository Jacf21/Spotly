import 'package:flutter_bloc/flutter_bloc.dart';
// Asegúrate de que esta sea la ruta correcta a tu entidad User
import '../../../auth/domain/entities/user.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    // 1. CARGAR PERFIL
    on<OnFetchProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final user = await getProfileUseCase.execute(event.userId);
        emit(ProfileLoaded(user));
      } catch (e) {
        emit(ProfileError("No se pudo cargar el perfil: ${e.toString()}"));
      }
    });

    // 2. ACTUALIZAR PERFIL
    on<OnUpdateProfile>((event, emit) async {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        final currentUser = currentState.user;

        emit(ProfileLoading());

        try {
          final updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            nombres: event.nombres,
            apellidos: event.apellidos,
            nombreUsuario: event.nombreUsuario,
            rol: currentUser.rol,
          );

          // CORRECCIÓN AQUÍ: Usamos el nombre correcto de la variable
          await updateProfileUseCase.execute(updatedUser);

          emit(ProfileUpdateSuccess());

          // Recargamos los datos para ver los cambios reflejados
          add(OnFetchProfile(currentUser.id));
        } catch (e) {
          emit(ProfileError("Error al actualizar: ${e.toString()}"));
          emit(ProfileLoaded(
              currentUser)); // Devolvemos el estado anterior si falla
        }
      }
    });
  }
}
