import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/features/person_detail/domain/entities/person.dart';
import 'package:movie_browse/features/person_detail/domain/repositories/person_repository.dart';
import 'package:movie_browse/features/person_detail/domain/usecases/get_person_detail_usecase.dart';

class _FakePersonRepository implements PersonRepository {
  @override
  Future<Either<Failure, Person>> getPersonDetail(int personId) async {
    return right(
      Person(id: personId, name: 'Person $personId'),
    );
  }
}

void main() {
  group('GetPersonDetailUseCase', () {
    test('forwards call to repository', () async {
      final useCase = GetPersonDetailUseCase(_FakePersonRepository());

      final result = await useCase(7);

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (person) {
          expect(person.id, 7);
        },
      );
    });
  });
}

