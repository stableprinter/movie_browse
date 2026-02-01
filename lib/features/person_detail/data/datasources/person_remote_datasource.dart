import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/person.dart';

abstract class PersonRemoteDatasource {
  Future<Either<Failure, Person>> getPersonDetail(int personId);
}
