import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/service/api_client.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/entities/cast_member.dart';
import '../models/cast_member_model.dart';
import 'movie_detail_remote_datasource.dart';

class MovieDetailRemoteDatasourceImpl implements MovieDetailRemoteDatasource {
  MovieDetailRemoteDatasourceImpl({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int movieId) async {
    try {
      final detailResponse = await _api.dio.get(
        ApiConstants.movieDetailEndpoint(movieId),
      );
      final creditsResponse = await _api.dio.get(
        ApiConstants.movieCreditsEndpoint(movieId),
      );

      if (detailResponse.statusCode != 200) {
        return Left(ServerFailure('Failed to load movie details'));
      }

      final detailData = detailResponse.data as Map<String, dynamic>?;
      if (detailData == null) {
        return Left(ServerFailure('Invalid response'));
      }

      final movie = MovieModel.fromJson(detailData);

      List<CastMember> cast = [];
      if (creditsResponse.statusCode == 200) {
        final creditsData = creditsResponse.data as Map<String, dynamic>?;
        final castList = creditsData?['cast'] as List<dynamic>? ?? [];
        cast = castList
            .take(20)
            .map((e) => CastMemberModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return Right(MovieDetail(movie: movie, cast: cast));
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

  @override
  Future<Either<Failure, void>> toggleFavorite(int mediaId, bool favorite) async {
    try {
      final accountId = int.tryParse(AppConfig.userId ?? '0') ?? 0;
      final response = await _api.dio.post(
        ApiConstants.accountFavoriteEndpoint(accountId),
        data: {
          'media_type': 'movie',
          'media_id': mediaId,
          'favorite': favorite,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(null);
      }
      return Left(ServerFailure('Failed to update favorite'));
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
