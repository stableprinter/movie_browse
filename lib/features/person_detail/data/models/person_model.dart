import '../../domain/entities/person.dart';

class PersonModel extends Person {
  const PersonModel({
    required super.id,
    required super.name,
    super.profilePath,
    super.biography,
    super.birthday,
    super.placeOfBirth,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
    );
  }
}
