import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';
import 'package:movie_browse/features/movies/domain/repositories/movies_repository.dart';
import 'package:movie_browse/features/movies/domain/usecases/discover_movies_usecase.dart';

class _FakeMoviesRepository implements MoviesRepository {
  _FakeMoviesRepository({this.shouldSucceed = true});

  final bool shouldSucceed;

  @override
  Future<Either<Failure, List<Movie>>> discoverMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    if (!shouldSucceed) {
      return left(ServerFailure('Failed'));
    }

    return right([
      Movie(id: page, title: 'Movie $page'),
    ]);
  }
}

void main() {
  group('DiscoverMoviesUseCase', () {
    test('forwards call to repository', () async {
      final useCase = DiscoverMoviesUseCase(_FakeMoviesRepository());

      final result = await useCase(page: 1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (movies) {
          expect(movies.length, 1);
          expect(movies.first.id, 1);
        },
      );
    });

    test('forwards parameters to repository', () async {
      final useCase = DiscoverMoviesUseCase(_FakeMoviesRepository());

      final result = await useCase(page: 5, language: 'de-DE');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (movies) {
          expect(movies.first.id, 5);
        },
      );
    });

    test('returns failure from repository', () async {
      final useCase = DiscoverMoviesUseCase(
        _FakeMoviesRepository(shouldSucceed: false),
      );

      final result = await useCase(page: 1);

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
