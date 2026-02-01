import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    super.posterPath,
    super.overview,
    super.releaseDate,
    super.voteAverage,
    super.voteCount,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      overview: json['overview'] as String?,
      releaseDate: json['release_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: json['vote_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'poster_path': posterPath,
        'overview': overview,
        'release_date': releaseDate,
        'vote_average': voteAverage,
        'vote_count': voteCount,
      };
}
