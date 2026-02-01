import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/movie.dart';

abstract class MoviesRemoteDatasource {
  Future<Either<Failure, List<Movie>>> discoverMovies({
    int page = 1,
    String language = 'en-US',
  });
}
