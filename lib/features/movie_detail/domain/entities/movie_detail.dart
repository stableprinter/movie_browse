import 'package:equatable/equatable.dart';

import '../../../movies/domain/entities/movie.dart';
import 'cast_member.dart';

class MovieDetail extends Equatable {
  const MovieDetail({
    required this.movie,
    this.cast = const [],
  });

  final Movie movie;
  final List<CastMember> cast;

  @override
  List<Object?> get props => [movie, cast];
}
