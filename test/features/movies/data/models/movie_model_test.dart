import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/features/movies/data/models/movie_model.dart';

void main() {
  group('MovieModel', () {
    test('fromJson parses correctly and toJson mirrors values', () {
      const json = {
        'id': 1,
        'title': 'Test Movie',
        'poster_path': '/poster.png',
        'overview': 'Overview',
        'release_date': '2024-01-02',
        'vote_average': 7.5,
        'vote_count': 100,
      };

      final model = MovieModel.fromJson(json);

      expect(model.id, 1);
      expect(model.title, 'Test Movie');
      expect(model.posterPath, '/poster.png');
      expect(model.overview, 'Overview');
      expect(model.releaseDate, '2024-01-02');
      expect(model.voteAverage, 7.5);
      expect(model.voteCount, 100);

      expect(model.toJson(), json);
    });
  });
}

