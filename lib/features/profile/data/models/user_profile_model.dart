import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: HiveTypeIds.userProfileModel)
class UserProfileModel extends HiveObject {
  UserProfileModel({
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
    this.avatarPath = '',
  });

  @HiveField(0) String name;
  @HiveField(1) String email;
  @HiveField(2) String phone;
  @HiveField(3) String bio;
  @HiveField(4) String avatarPath;

  UserProfile toEntity() => UserProfile(
        name: name, email: email, phone: phone,
        bio: bio, avatarPath: avatarPath,
      );

  factory UserProfileModel.fromEntity(UserProfile p) => UserProfileModel(
        name: p.name, email: p.email, phone: p.phone,
        bio: p.bio, avatarPath: p.avatarPath,
      );

  factory UserProfileModel.defaultProfile() => UserProfileModel(
        name: 'محمد أحمد',
        email: 'mohamed.ahmed@email.com',
      );
}
