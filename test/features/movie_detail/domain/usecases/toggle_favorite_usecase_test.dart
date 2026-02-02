import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/movie_detail.dart';
import 'package:movie_browse/features/movie_detail/domain/repositories/movie_detail_repository.dart';
import 'package:movie_browse/features/movie_detail/domain/usecases/toggle_favorite_usecase.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';

class _FakeMovieDetailRepository implements MovieDetailRepository {
  _FakeMovieDetailRepository({this.shouldSucceed = true});

  final bool shouldSucceed;

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int movieId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(int mediaId, bool favorite) async {
    if (!shouldSucceed) {
      return left(ServerFailure('Failed'));
    }

    return right(null);
  }
}

void main() {
  group('ToggleFavoriteUseCase', () {
    test('forwards call to repository with correct parameters', () async {
      final useCase = ToggleFavoriteUseCase(_FakeMovieDetailRepository());

      final result = await useCase(123, true);

      expect(result.isRight(), isTrue);
    });

    test('returns failure from repository', () async {
      final useCase = ToggleFavoriteUseCase(
        _FakeMovieDetailRepository(shouldSucceed: false),
      );

      final result = await useCase(123, false);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (_) => fail('Expected failure'),
      );
    });
  });
}
