import 'package:flutter_bloc/flutter_bloc.dart';
// IMPORT CRUCIAL: Sin esto, los archivos 'part' no sabrán qué es ProfileEntity
import 'package:spotly/features/profile/domain/entities/profile_entity.dart';
import 'package:spotly/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:spotly/features/profile/domain/usecases/update_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(ProfileInitial()) {
    on<OnFetchProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await getProfileUseCase.execute(event.userId);
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError("Error al cargar perfil: ${e.toString()}"));
      }
    });

    on<OnUpdateProfile>((event, emit) async {
      final currentState = state;
      if (currentState is ProfileLoaded) {
        final currentProfile = currentState.profile;
        emit(ProfileLoading());

        try {
          final updatedProfile = ProfileEntity(
            id: currentProfile.id,
            email: currentProfile.email,
            nombres: event.nombres,
            apellidos: event.apellidos,
            username: event.nombreUsuario,
            bio: event.biografia,
            photoUrl: currentProfile.photoUrl,
            genero: event.genero,
            fechaNacimiento: event.fechaNacimiento,
            pais: event.pais,
            ciudad: event.ciudad,
          );

          await updateProfileUseCase.execute(updatedProfile);
          emit(ProfileUpdateSuccess());
          add(OnFetchProfile(currentProfile.id));
        } catch (e) {
          emit(ProfileError("Error al actualizar: ${e.toString()}"));
          emit(ProfileLoaded(currentProfile));
        }
      }
    });
  }
}
