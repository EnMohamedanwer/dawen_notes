import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/use_case.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile implements UseCase<UserProfile, NoParams> {
  GetProfile(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) =>
      repository.getProfile();
}

class SaveProfile implements UseCase<UserProfile, UserProfile> {
  SaveProfile(this.repository);
  final ProfileRepository repository;

  @override
  Future<Either<Failure, UserProfile>> call(UserProfile profile) =>
      repository.saveProfile(profile);
}
