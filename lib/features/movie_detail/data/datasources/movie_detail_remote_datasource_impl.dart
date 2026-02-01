import 'package:dartz/dartz.dart';

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
      final detailResponse = await _api.get<dynamic>(
        ApiConstants.movieDetailEndpoint(movieId),
      );
      final creditsResponse = await _api.get<dynamic>(
        ApiConstants.movieCreditsEndpoint(movieId),
      );

      if (!detailResponse.isSuccess) {
        return Left(ServerFailure('Failed to load movie details'));
      }

      final detailData = detailResponse.data as Map<String, dynamic>?;
      if (detailData == null) {
        return Left(ServerFailure('Invalid response'));
      }

      final movie = MovieModel.fromJson(detailData);

      List<CastMember> cast = [];
      if (creditsResponse.isSuccess) {
        final creditsData = creditsResponse.data as Map<String, dynamic>?;
        final castList = creditsData?['cast'] as List<dynamic>? ?? [];
        cast = castList
            .take(20)
            .map((e) => CastMemberModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return Right(MovieDetail(movie: movie, cast: cast));
    } on NetworkException catch (e) {
      if (e.statusCode == null) {
        return Left(NetworkFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(int mediaId, bool favorite) async {
    try {
      final accountId = int.tryParse(AppConfig.userId ?? '0') ?? 0;
      final response = await _api.post<dynamic>(
        ApiConstants.accountFavoriteEndpoint(accountId),
        data: {
          'media_type': 'movie',
          'media_id': mediaId,
          'favorite': favorite,
        },
      );

      if (response.isSuccess) {
        return const Right(null);
      }
      return Left(ServerFailure('Failed to update favorite'));
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
