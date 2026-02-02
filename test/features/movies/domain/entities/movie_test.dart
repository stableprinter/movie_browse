import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';

void main() {
  group('Movie', () {
    test('year returns first 4 characters of releaseDate', () {
      const movie = Movie(
        id: 1,
        title: 'Test Movie',
        releaseDate: '2024-01-02',
      );

      expect(movie.year, '2024');
    });

    test('year returns empty string when releaseDate is null or empty', () {
      const movieNull = Movie(
        id: 1,
        title: 'Test Movie',
      );
      const movieEmpty = Movie(
        id: 1,
        title: 'Test Movie',
        releaseDate: '',
      );

      expect(movieNull.year, '');
      expect(movieEmpty.year, '');
    });

    test('supports value equality', () {
      const movie1 = Movie(id: 1, title: 'Test Movie');
      const movie2 = Movie(id: 1, title: 'Test Movie');

      expect(movie1, equals(movie2));
    });
  });
}

