import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/features/movie_detail/data/datasources/movie_detail_remote_datasource.dart';
import 'package:movie_browse/features/movie_detail/data/repositories/movie_detail_repository_impl.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/movie_detail.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';

class _FakeMovieDetailRemoteDatasource implements MovieDetailRemoteDatasource {
  _FakeMovieDetailRemoteDatasource({
    this.shouldSucceed = true,
    this.toggleShouldSucceed = true,
  });

  final bool shouldSucceed;
  final bool toggleShouldSucceed;

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int movieId) async {
    if (!shouldSucceed) {
      return left(ServerFailure('Failed to load movie details'));
    }

    return right(
      MovieDetail(
        movie: Movie(id: movieId, title: 'Movie $movieId'),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(int mediaId, bool favorite) async {
    if (!toggleShouldSucceed) {
      return left(ServerFailure('Failed to update favorite'));
    }

    return right(null);
  }
}

void main() {
  group('MovieDetailRepositoryImpl', () {
    test('getMovieDetail returns detail from datasource on success', () async {
      final repository = MovieDetailRepositoryImpl(
        remoteDatasource: _FakeMovieDetailRemoteDatasource(shouldSucceed: true),
      );

      final result = await repository.getMovieDetail(99);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (detail) {
          expect(detail.movie.id, 99);
          expect(detail.movie.title, 'Movie 99');
        },
      );
    });

    test('getMovieDetail returns failure from datasource on error', () async {
      final repository = MovieDetailRepositoryImpl(
        remoteDatasource: _FakeMovieDetailRemoteDatasource(shouldSucceed: false),
      );

      final result = await repository.getMovieDetail(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (_) => fail('Expected failure'),
      );
    });

    test('toggleFavorite returns success from datasource', () async {
      final repository = MovieDetailRepositoryImpl(
        remoteDatasource: _FakeMovieDetailRemoteDatasource(toggleShouldSucceed: true),
      );

      final result = await repository.toggleFavorite(1, true);

      expect(result.isRight(), isTrue);
    });

    test('toggleFavorite returns failure from datasource on error', () async {
      final repository = MovieDetailRepositoryImpl(
        remoteDatasource: _FakeMovieDetailRemoteDatasource(toggleShouldSucceed: false),
      );

      final result = await repository.toggleFavorite(1, true);

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
