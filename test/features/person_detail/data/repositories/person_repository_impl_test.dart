import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/features/person_detail/data/datasources/person_remote_datasource.dart';
import 'package:movie_browse/features/person_detail/data/repositories/person_repository_impl.dart';
import 'package:movie_browse/features/person_detail/domain/entities/person.dart';

class _FakePersonRemoteDatasource implements PersonRemoteDatasource {
  _FakePersonRemoteDatasource({this.shouldSucceed = true});

  final bool shouldSucceed;

  @override
  Future<Either<Failure, Person>> getPersonDetail(int personId) async {
    if (!shouldSucceed) {
      return left(ServerFailure('Failed to load person details'));
    }

    return right(Person(id: personId, name: 'Person $personId'));
  }
}

void main() {
  group('PersonRepositoryImpl', () {
    test('getPersonDetail returns person from datasource on success', () async {
      final repository = PersonRepositoryImpl(
        remoteDatasource: _FakePersonRemoteDatasource(shouldSucceed: true),
      );

      final result = await repository.getPersonDetail(42);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (person) {
          expect(person.id, 42);
          expect(person.name, 'Person 42');
        },
      );
    });

    test('getPersonDetail returns failure from datasource on error', () async {
      final repository = PersonRepositoryImpl(
        remoteDatasource: _FakePersonRemoteDatasource(shouldSucceed: false),
      );

      final result = await repository.getPersonDetail(1);

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
