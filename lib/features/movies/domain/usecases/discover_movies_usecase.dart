import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/movie.dart';
import '../repositories/movies_repository.dart';

class DiscoverMoviesUseCase {
  DiscoverMoviesUseCase(this._repository);

  final MoviesRepository _repository;

  Future<Either<Failure, List<Movie>>> call({
    int page = 1,
    String language = 'en-US',
  }) =>
      _repository.discoverMovies(page: page, language: language);
}
