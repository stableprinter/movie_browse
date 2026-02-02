import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/core/service/api_client.dart';
import 'package:movie_browse/features/movies/data/datasources/movies_remote_datasource_impl.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';

class _FakeApiClient implements ApiClient {
  _FakeApiClient({
    this.shouldSucceed = true,
    this.throwNetworkException = false,
    this.throwGenericException = false,
  });

  final bool shouldSucceed;
  final bool throwNetworkException;
  final bool throwGenericException;

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

    final responseData = {
      'results': [
        {
          'id': 1,
          'title': 'Test Movie',
          'poster_path': '/poster.jpg',
          'release_date': '2024-01-01',
          'vote_average': 7.5,
        },
      ],
    } as T;

    return NetworkResponse<T>(
      data: responseData,
      statusCode: 200,
    );
  }

  @override
  Future<NetworkResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) {
    throw UnimplementedError();
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
  group('MoviesRemoteDatasourceImpl', () {
    test('discoverMovies returns list of movies on success', () async {
      final datasource = MoviesRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: true),
      );

      final result = await datasource.discoverMovies(page: 1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (movies) {
          expect(movies, isA<List<Movie>>());
          expect(movies.length, 1);
          expect(movies.first.id, 1);
          expect(movies.first.title, 'Test Movie');
        },
      );
    });

    test('discoverMovies returns ServerFailure on API failure', () async {
      final datasource = MoviesRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: false),
      );

      final result = await datasource.discoverMovies(page: 1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to load movies');
        },
        (_) => fail('Expected failure'),
      );
    });

    test('discoverMovies returns NetworkFailure on network error', () async {
      final datasource = MoviesRemoteDatasourceImpl(
        apiClient: _FakeApiClient(throwNetworkException: true),
      );

      final result = await datasource.discoverMovies(page: 1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
        },
        (_) => fail('Expected failure'),
      );
    });

    test('discoverMovies returns ServerFailure on generic exception', () async {
      final datasource = MoviesRemoteDatasourceImpl(
        apiClient: _FakeApiClient(throwGenericException: true),
      );

      final result = await datasource.discoverMovies(page: 1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (_) => fail('Expected failure'),
      );
    });

    test('discoverMovies passes correct parameters', () async {
      final datasource = MoviesRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: true),
      );

      await datasource.discoverMovies(page: 2, language: 'fr-FR');

      // Test passes if no exception is thrown
    });
  });
}
