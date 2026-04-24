import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../models/user_profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> saveProfile(UserProfileModel model);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  Box<UserProfileModel> get _box =>
      Hive.box<UserProfileModel>(HiveBoxNames.userProfile);

  static const _key = 'profile';

  @override
  Future<UserProfileModel> getProfile() async {
    final model = _box.get(_key);
    if (model == null) {
      final def = UserProfileModel.defaultProfile();
      await _box.put(_key, def);
      return def;
    }
    return model;
  }

  @override
  Future<UserProfileModel> saveProfile(UserProfileModel model) async {
    await _box.put(_key, model);
    return model;
  }
}
