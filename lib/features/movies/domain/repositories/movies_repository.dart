import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/movie.dart';

abstract class MoviesRepository {
  Future<Either<Failure, List<Movie>>> discoverMovies({
    int page = 1,
    String language = 'en-US',
  });
}
