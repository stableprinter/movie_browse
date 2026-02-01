import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/person.dart';
import '../repositories/person_repository.dart';

class GetPersonDetailUseCase {
  GetPersonDetailUseCase(this._repository);

  final PersonRepository _repository;

  Future<Either<Failure, Person>> call(int personId) =>
      _repository.getPersonDetail(personId);
}
