import 'package:equatable/equatable.dart';

class Person extends Equatable {
  const Person({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.birthday,
    this.placeOfBirth,
  });

  final int id;
  final String name;
  final String? profilePath;
  final String? biography;
  final String? birthday;
  final String? placeOfBirth;

  @override
  List<Object?> get props => [id, name, profilePath, biography, birthday, placeOfBirth];
}
