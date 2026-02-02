import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('fromBrowseArgs sets all fields correctly', () {
      AppConfig.fromBrowseArgs([
        'token',
        'user-id',
        'https://example.com',
        'MovieBrowse',
        'https://images.example.com',
      ]);

      expect(AppConfig.apiToken, 'token');
      expect(AppConfig.userId, 'user-id');
      expect(AppConfig.baseUrl, 'https://example.com');
      expect(AppConfig.appName, 'MovieBrowse');
      expect(AppConfig.imageBaseUrl, 'https://images.example.com');
    });

    test('fromBrowseArgs handles missing args gracefully', () {
      AppConfig.fromBrowseArgs([
        'token-only',
        'user-only',
      ]);

      expect(AppConfig.apiToken, 'token-only');
      expect(AppConfig.userId, 'user-only');
      expect(AppConfig.baseUrl, isNull);
      expect(AppConfig.appName, isNull);
      expect(AppConfig.imageBaseUrl, isNull);
    });
  });
}

