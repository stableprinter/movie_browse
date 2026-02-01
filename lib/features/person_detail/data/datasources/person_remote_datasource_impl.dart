import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

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
      final response = await _api.dio.get(
        ApiConstants.personDetailEndpoint(personId),
      );

      if (response.statusCode != 200) {
        return Left(ServerFailure('Failed to load person details'));
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        return Left(ServerFailure('Invalid response'));
      }

      return Right(PersonModel.fromJson(data));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Left(NetworkFailure(e.message));
      }
      final data = e.response?.data;
      final message = data is Map ? data['status_message'] as String? : null;
      return Left(ServerFailure(message ?? e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
