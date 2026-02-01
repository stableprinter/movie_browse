import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/movie_detail.dart';
import '../repositories/movie_detail_repository.dart';

class GetMovieDetailUseCase {
  GetMovieDetailUseCase(this._repository);

  final MovieDetailRepository _repository;

  Future<Either<Failure, MovieDetail>> call(int movieId) =>
      _repository.getMovieDetail(movieId);
}
