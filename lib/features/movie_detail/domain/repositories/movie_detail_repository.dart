import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/movie_detail.dart';

abstract class MovieDetailRepository {
  Future<Either<Failure, MovieDetail>> getMovieDetail(int movieId);
  Future<Either<Failure, void>> toggleFavorite(int mediaId, bool favorite);
}
