import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';

void main() {
  group('Failure', () {
    test('ServerFailure equality is based on message', () {
      const failure1 = ServerFailure('error');
      const failure2 = ServerFailure('error');
      const failure3 = ServerFailure('other');

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('ServerFailure toString includes message', () {
      const failure = ServerFailure('boom');

      expect(failure.toString(), contains('ServerFailure'));
      expect(failure.toString(), contains('boom'));
    });

    test('NetworkFailure toString uses default when no message', () {
      const failure = NetworkFailure();

      expect(failure.toString(), contains('NetworkFailure'));
      expect(failure.toString(), contains('Network error'));
    });
  });
}

