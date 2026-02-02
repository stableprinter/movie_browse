import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/cast_member.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/movie_detail.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';

void main() {
  group('MovieDetail', () {
    test('supports value equality', () {
      const movie = Movie(id: 1, title: 'Test Movie');
      const cast = [
        CastMember(id: 1, name: 'Actor 1'),
      ];

      const detail1 = MovieDetail(movie: movie, cast: cast);
      const detail2 = MovieDetail(movie: movie, cast: cast);

      expect(detail1, equals(detail2));
    });

    test('defaults cast to empty list', () {
      const movie = Movie(id: 1, title: 'Test Movie');
      const detail = MovieDetail(movie: movie);

      expect(detail.cast, isEmpty);
    });
  });
}

