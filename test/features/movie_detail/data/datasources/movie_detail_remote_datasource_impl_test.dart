import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/config/app_config.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/core/service/api_client.dart';
import 'package:movie_browse/features/movie_detail/data/datasources/movie_detail_remote_datasource_impl.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/movie_detail.dart';

class _FakeApiClient implements ApiClient {
  _FakeApiClient({
    this.shouldSucceed = true,
    this.throwNetworkException = false,
    this.throwGenericException = false,
    this.returnNullData = false,
    this.creditsSucceed = true,
  });

  final bool shouldSucceed;
  final bool throwNetworkException;
  final bool throwGenericException;
  final bool returnNullData;
  final bool creditsSucceed;

  int callCount = 0;

  @override
  String get baseUrl => 'https://api.test.com';

  @override
  String? get userId => 'test-user';

  @override
  Future<NetworkResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    callCount++;

    if (throwNetworkException) {
      throw const NetworkException(message: 'Network error');
    }
    if (throwGenericException) {
      throw Exception('Generic error');
    }

    // First call is for movie details
    if (callCount == 1) {
      if (!shouldSucceed) {
        return NetworkResponse<T>(
          data: null,
          statusCode: 500,
        );
      }

      if (returnNullData) {
        return NetworkResponse<T>(
          data: null,
          statusCode: 200,
        );
      }

      final responseData = {
        'id': 1,
        'title': 'Test Movie',
        'poster_path': '/poster.jpg',
        'release_date': '2024-01-01',
        'vote_average': 8.5,
        'overview': 'Test overview',
      } as T;

      return NetworkResponse<T>(
        data: responseData,
        statusCode: 200,
      );
    }

    // Second call is for credits
    if (!creditsSucceed) {
      return NetworkResponse<T>(
        data: null,
        statusCode: 500,
      );
    }

    final creditsData = {
      'cast': [
        {
          'id': 1,
          'name': 'Actor 1',
          'character': 'Character 1',
          'profile_path': '/actor1.jpg',
        },
        {
          'id': 2,
          'name': 'Actor 2',
          'character': 'Character 2',
          'profile_path': '/actor2.jpg',
        },
      ],
    } as T;

    return NetworkResponse<T>(
      data: creditsData,
      statusCode: 200,
    );
  }

  @override
  Future<NetworkResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    if (throwNetworkException) {
      throw const NetworkException(message: 'Network error');
    }
    if (throwGenericException) {
      throw Exception('Generic error');
    }

    if (!shouldSucceed) {
      return NetworkResponse<T>(
        data: null,
        statusCode: 500,
      );
    }

    return NetworkResponse<T>(
      data: null,
      statusCode: 200,
    );
  }

  @override
  Future<NetworkResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<NetworkResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<NetworkResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  group('MovieDetailRemoteDatasourceImpl', () {
    setUp(() {
      AppConfig.set(userId: '123');
    });

    test('getMovieDetail returns movie detail on success', () async {
      final datasource = MovieDetailRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: true),
      );

      final result = await datasource.getMovieDetail(1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (detail) {
          expect(detail, isA<MovieDetail>());
          expect(detail.movie.id, 1);
          expect(detail.movie.title, 'Test Movie');
          expect(detail.cast.length, 2);
          expect(detail.cast.first.name, 'Actor 1');
        },
      );
    });

    test('getMovieDetail returns detail without cast when credits fail', () async {
      final datasource = MovieDetailRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: true, creditsSucceed: false),
      );

      final result = await datasource.getMovieDetail(1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (detail) {
          expect(detail.movie.id, 1);
          expect(detail.cast.length, 0);
        },
      );
    });

    test('getMovieDetail returns ServerFailure on API failure', () async {
      final datasource = MovieDetailRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: false),
      );

      final result = await datasource.getMovieDetail(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to load movie details');
        },
        (_) => fail('Expected failure'),
      );
    });

    test('getMovieDetail returns ServerFailure on null data', () async {
      final datasource = MovieDetailRemoteDatasourceImpl(
        apiClient: _FakeApiClient(returnNullData: true),
      );

      final result = await datasource.getMovieDetail(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Invalid response');
        },
        (_) => fail('Expected failure'),
      );
    });

    test('getMovieDetail returns NetworkFailure on network error', () async {
      final datasource = MovieDetailRemoteDatasourceImpl(
        apiClient: _FakeApiClient(throwNetworkException: true),
      );

      final result = await datasource.getMovieDetail(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
        },
        (_) => fail('Expected failure'),
      );
    });

    test('toggleFavorite returns success on API success', () async {
      final datasource = MovieDetailRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: true),
      );

      final result = await datasource.toggleFavorite(1, true);

      expect(result.isRight(), isTrue);
    });

    test('toggleFavorite returns ServerFailure on API failure', () async {
      final datasource = MovieDetailRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: false),
      );

      final result = await datasource.toggleFavorite(1, true);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to update favorite');
        },
        (_) => fail('Expected failure'),
      );
    });

    test('toggleFavorite returns NetworkFailure on network error', () async {
      final datasource = MovieDetailRemoteDatasourceImpl(
        apiClient: _FakeApiClient(throwNetworkException: true),
      );

      final result = await datasource.toggleFavorite(1, true);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
        },
        (_) => fail('Expected failure'),
      );
    });
  });
}
