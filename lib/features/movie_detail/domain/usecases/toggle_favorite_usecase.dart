import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/movie_detail_repository.dart';

class ToggleFavoriteUseCase {
  ToggleFavoriteUseCase(this._repository);

  final MovieDetailRepository _repository;

  Future<Either<Failure, void>> call(int mediaId, bool favorite) =>
      _repository.toggleFavorite(mediaId, favorite);
}
