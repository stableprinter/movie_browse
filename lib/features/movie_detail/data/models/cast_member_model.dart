import '../../domain/entities/cast_member.dart';

class CastMemberModel extends CastMember {
  const CastMemberModel({
    required super.id,
    required super.name,
    super.profilePath,
    super.character,
    super.order,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) {
    return CastMemberModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
      character: json['character'] as String?,
      order: json['order'] as int?,
    );
  }
}
