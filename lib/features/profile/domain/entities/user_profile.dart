import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
    this.avatarPath = '',
  });

  final String name;
  final String email;
  final String phone;
  final String bio;
  final String avatarPath;

  bool get hasAvatar => avatarPath.isNotEmpty;

  UserProfile copyWith({
    String? name, String? email, String? phone,
    String? bio, String? avatarPath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  static const empty = UserProfile(
    name: 'محمد أحمد',
    email: 'mohamed.ahmed@email.com',
  );

  @override
  List<Object?> get props => [name, email, phone, bio, avatarPath];
}
