import 'package:dartz/dartz.dart';

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
      final response = await _api.get<dynamic>(
        ApiConstants.discoverMovieEndpoint(),
        queryParameters: {
          'sort_by': 'popularity.desc',
          'page': page,
          'language': language,
        },
      );

      if (!response.isSuccess) {
        return Left(ServerFailure('Failed to load movies'));
      }

      final data = response.data as Map<String, dynamic>?;
      final results = data?['results'] as List<dynamic>? ?? [];

      final movies = results
          .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(movies);
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
