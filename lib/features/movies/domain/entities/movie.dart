import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  const Movie({
    required this.id,
    required this.title,
    this.posterPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
    this.voteCount,
  });

  final int id;
  final String title;
  final String? posterPath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;
  final int? voteCount;

  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    if (releaseDate!.length >= 4) return releaseDate!.substring(0, 4);
    return releaseDate!;
  }

  @override
  List<Object?> get props => [id, title, posterPath, overview, releaseDate, voteAverage, voteCount];
}
