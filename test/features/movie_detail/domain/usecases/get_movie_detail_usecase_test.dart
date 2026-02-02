import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/movie_detail.dart';
import 'package:movie_browse/features/movie_detail/domain/repositories/movie_detail_repository.dart';
import 'package:movie_browse/features/movie_detail/domain/usecases/get_movie_detail_usecase.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';

class _FakeMovieDetailRepository implements MovieDetailRepository {
  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int movieId) async {
    return right(
      MovieDetail(
        movie: Movie(id: movieId, title: 'Movie $movieId'),
      ),
    );
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(int mediaId, bool favorite) {
    throw UnimplementedError();
  }
}

void main() {
  group('GetMovieDetailUseCase', () {
    test('forwards call to repository', () async {
      final useCase = GetMovieDetailUseCase(_FakeMovieDetailRepository());

      final result = await useCase(5);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (detail) {
          expect(detail.movie.id, 5);
        },
      );
    });
  });
}

