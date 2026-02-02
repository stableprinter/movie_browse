import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/core/service/api_client.dart';
import 'package:movie_browse/features/person_detail/data/datasources/person_remote_datasource_impl.dart';
import 'package:movie_browse/features/person_detail/domain/entities/person.dart';

class _FakeApiClient implements ApiClient {
  _FakeApiClient({
    this.shouldSucceed = true,
    this.throwNetworkException = false,
    this.throwGenericException = false,
    this.returnNullData = false,
  });

  final bool shouldSucceed;
  final bool throwNetworkException;
  final bool throwGenericException;
  final bool returnNullData;

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

    if (returnNullData) {
      return NetworkResponse<T>(
        data: null,
        statusCode: 200,
      );
    }

    final responseData = {
      'id': 1,
      'name': 'Test Person',
      'profile_path': '/profile.jpg',
      'biography': 'Test biography',
      'birthday': '1980-01-01',
      'place_of_birth': 'Test City',
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
  group('PersonRemoteDatasourceImpl', () {
    test('getPersonDetail returns person on success', () async {
      final datasource = PersonRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: true),
      );

      final result = await datasource.getPersonDetail(1);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (person) {
          expect(person, isA<Person>());
          expect(person.id, 1);
          expect(person.name, 'Test Person');
        },
      );
    });

    test('getPersonDetail returns ServerFailure on API failure', () async {
      final datasource = PersonRemoteDatasourceImpl(
        apiClient: _FakeApiClient(shouldSucceed: false),
      );

      final result = await datasource.getPersonDetail(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Failed to load person details');
        },
        (_) => fail('Expected failure'),
      );
    });

    test('getPersonDetail returns ServerFailure on null data', () async {
      final datasource = PersonRemoteDatasourceImpl(
        apiClient: _FakeApiClient(returnNullData: true),
      );

      final result = await datasource.getPersonDetail(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Invalid response');
        },
        (_) => fail('Expected failure'),
      );
    });

    test('getPersonDetail returns NetworkFailure on network error', () async {
      final datasource = PersonRemoteDatasourceImpl(
        apiClient: _FakeApiClient(throwNetworkException: true),
      );

      final result = await datasource.getPersonDetail(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
        },
        (_) => fail('Expected failure'),
      );
    });

    test('getPersonDetail returns ServerFailure on generic exception', () async {
      final datasource = PersonRemoteDatasourceImpl(
        apiClient: _FakeApiClient(throwGenericException: true),
      );

      final result = await datasource.getPersonDetail(1);

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
        },
        (_) => fail('Expected failure'),
      );
    });
  });
}
