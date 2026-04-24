import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._ds);
  final ProfileLocalDataSource _ds;

  @override
  Future<Either<Failure, UserProfile>> getProfile() async {
    try {
      final model = await _ds.getProfile();
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> saveProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      final saved = await _ds.saveProfile(model);
      return Right(saved.toEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
