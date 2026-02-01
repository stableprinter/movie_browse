import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/service/api_client.dart';
import '../../domain/entities/movie.dart';
import '../models/movie_model.dart';
import 'movies_remote_datasource.dart';

class MoviesRemoteDatasourceImpl implements MoviesRemoteDatasource {
  MoviesRemoteDatasourceImpl({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  @override
  Future<Either<Failure, List<Movie>>> discoverMovies({
    int page = 1,
    String language = 'en-US',
  }) async {
    try {
      final response = await _api.dio.get(
        ApiConstants.discoverMovieEndpoint(),
        queryParameters: {
          'sort_by': 'popularity.desc',
          'page': page,
          'language': language,
        },
      );

      if (response.statusCode != 200) {
        return Left(ServerFailure('Failed to load movies'));
      }

      final data = response.data as Map<String, dynamic>?;
      final results = data?['results'] as List<dynamic>? ?? [];

      final movies = results
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(movies);
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
