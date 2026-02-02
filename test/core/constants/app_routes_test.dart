import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/constants/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('moviePath builds correct route', () {
      expect(AppRoutes.moviePath(123), '/movie/123');
    });
  });
}

