import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/config/app_config.dart';
import 'package:movie_browse/core/service/api_client.dart';

void main() {
  group('ApiClient', () {
    test('uses AppConfig values by default', () {
      AppConfig.set(
        baseUrl: 'https://api.example.com',
        userId: 'user-123',
      );

      final client = ApiClient();

      expect(client.baseUrl, 'https://api.example.com');
      expect(client.userId, 'user-123');
    });

    test('constructor parameters override AppConfig', () {
      AppConfig.set(
        baseUrl: 'https://api.example.com',
        userId: 'user-123',
      );

      final client = ApiClient(
        baseUrl: 'https://override.example.com',
        userId: 'override-user',
      );

      expect(client.baseUrl, 'https://override.example.com');
      expect(client.userId, 'override-user');
    });
  });
}

