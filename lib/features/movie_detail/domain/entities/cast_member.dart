import 'package:equatable/equatable.dart';

class CastMember extends Equatable {
  const CastMember({
    required this.id,
    required this.name,
    this.profilePath,
    this.character,
    this.order,
  });

  final int id;
  final String name;
  final String? profilePath;
  final String? character;
  final int? order;

  @override
  List<Object?> get props => [id, name, profilePath, character, order];
}
