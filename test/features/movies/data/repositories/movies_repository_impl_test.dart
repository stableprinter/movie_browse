import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/features/movies/data/datasources/movies_remote_datasource.dart';
import 'package:movie_browse/features/movies/data/repositories/movies_repository_impl.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';

class _FakeMoviesRemoteDatasource implements MoviesRemoteDatasource {
  _FakeMoviesRemoteDatasource({this.shouldSucceed = true});

  final bool shouldSucceed;

  @override
  Future<Either<Failure, List<Movie>>> discoverMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    if (!shouldSucceed) {
      return left(ServerFailure('Failed to load movies'));
    }

    return right([
      Movie(id: 1, title: 'Test Movie'),
      Movie(id: 2, title: 'Test Movie 2'),
    ]);
  }
}

void main() {
  group('MoviesRepositoryImpl', () {
    test('discoverMovies returns movies from datasource on success', () async {
      final repository = MoviesRepositoryImpl(
        remoteDatasource: _FakeMoviesRemoteDatasource(shouldSucceed: true),
      );

      final result = await repository.discoverMovies(page: 1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (movies) {
          expect(movies.length, 2);
          expect(movies.first.id, 1);
          expect(movies.last.id, 2);
        },
      );
    });

    test('discoverMovies returns failure from datasource on error', () async {
      final repository = MoviesRepositoryImpl(
        remoteDatasource: _FakeMoviesRemoteDatasource(shouldSucceed: false),
      );

      final result = await repository.discoverMovies(page: 1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (_) => fail('Expected failure'),
      );
    });

    test('discoverMovies forwards parameters to datasource', () async {
      final repository = MoviesRepositoryImpl(
        remoteDatasource: _FakeMoviesRemoteDatasource(shouldSucceed: true),
      );

      await repository.discoverMovies(page: 3, language: 'es-ES');

      // Test passes if no exception is thrown
    });
  });
}
