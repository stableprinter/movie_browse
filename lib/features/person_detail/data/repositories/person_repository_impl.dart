import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/person.dart';
import '../../domain/repositories/person_repository.dart';
import '../datasources/person_remote_datasource.dart';
import '../datasources/person_remote_datasource_impl.dart';

class PersonRepositoryImpl implements PersonRepository {
  PersonRepositoryImpl({PersonRemoteDatasource? remoteDatasource})
      : _remoteDatasource = remoteDatasource ?? PersonRemoteDatasourceImpl();

  final PersonRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, Person>> getPersonDetail(int personId) =>
      _remoteDatasource.getPersonDetail(personId);
}
