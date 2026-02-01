import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/service/api_client.dart';
import '../../domain/entities/person.dart';
import '../models/person_model.dart';
import 'person_remote_datasource.dart';

class PersonRemoteDatasourceImpl implements PersonRemoteDatasource {
  PersonRemoteDatasourceImpl({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  @override
  Future<Either<Failure, Person>> getPersonDetail(int personId) async {
    try {
      final response = await _api.get<dynamic>(
        ApiConstants.personDetailEndpoint(personId),
      );

      if (!response.isSuccess) {
        return Left(ServerFailure('Failed to load person details'));
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return Left(ServerFailure('Invalid response'));
      }

      return Right(PersonModel.fromJson(data));
    } on NetworkException catch (e) {
      if (e.statusCode == null) {
        return Left(NetworkFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
