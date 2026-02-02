import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('movieDetailEndpoint builds correct path', () {
      expect(ApiConstants.movieDetailEndpoint(42), '/movie/42');
    });

    test('movieCreditsEndpoint builds correct path', () {
      expect(ApiConstants.movieCreditsEndpoint(42), '/movie/42/credits');
    });

    test('personDetailEndpoint builds correct path', () {
      expect(ApiConstants.personDetailEndpoint(7), '/person/7');
    });

    test('accountFavoriteEndpoint builds correct path', () {
      expect(
        ApiConstants.accountFavoriteEndpoint(10),
        '/account/10/favorite',
      );
    });
  });
}

