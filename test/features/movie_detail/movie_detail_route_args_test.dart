import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/features/movie_detail/movie_detail_route_args.dart';

void main() {
  group('MovieDetailRouteArgs', () {
    test('creates instance with required movieId', () {
      const args = MovieDetailRouteArgs(movieId: 123);

      expect(args.movieId, 123);
      expect(args.isFavorite, false);
    });

    test('creates instance with movieId and isFavorite', () {
      const args = MovieDetailRouteArgs(movieId: 456, isFavorite: true);

      expect(args.movieId, 456);
      expect(args.isFavorite, true);
    });

    test('isFavorite defaults to false', () {
      const args = MovieDetailRouteArgs(movieId: 1);

      expect(args.isFavorite, false);
    });

    test('can set isFavorite to false explicitly', () {
      const args = MovieDetailRouteArgs(movieId: 1, isFavorite: false);

      expect(args.isFavorite, false);
    });
  });
}
