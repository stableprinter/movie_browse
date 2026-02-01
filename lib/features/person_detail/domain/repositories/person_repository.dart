import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/person.dart';

abstract class PersonRepository {
  Future<Either<Failure, Person>> getPersonDetail(int personId);
}
