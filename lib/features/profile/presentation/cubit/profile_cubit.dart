import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../../../../core/utils/use_case.dart';

// ── States ────────────────────────────────────────────────────────────────────
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);
  final UserProfile profile;
  @override
  List<Object?> get props => [profile];
}

class ProfileSaved extends ProfileState {
  const ProfileSaved(this.profile);
  final UserProfile profile;
  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.getProfile,
    required this.saveProfile,
  }) : super(const ProfileInitial());

  final GetProfile getProfile;
  final SaveProfile saveProfile;

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    final result = await getProfile(NoParams());
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (p) => emit(ProfileLoaded(p)),
    );
  }

  Future<void> save(UserProfile profile) async {
    emit(const ProfileLoading());
    final result = await saveProfile(profile);
    result.fold(
      (f) => emit(ProfileError(f.message)),
      (p) => emit(ProfileSaved(p)),
    );
  }
}
