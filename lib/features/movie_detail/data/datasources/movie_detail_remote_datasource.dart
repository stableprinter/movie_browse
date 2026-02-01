import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/movie_detail.dart';

abstract class MovieDetailRemoteDatasource {
  Future<Either<Failure, MovieDetail>> getMovieDetail(int movieId);
  Future<Either<Failure, void>> toggleFavorite(int mediaId, bool favorite);
}
