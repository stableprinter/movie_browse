import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/repositories/movie_detail_repository.dart';
import '../datasources/movie_detail_remote_datasource.dart';
import '../datasources/movie_detail_remote_datasource_impl.dart';

class MovieDetailRepositoryImpl implements MovieDetailRepository {
  MovieDetailRepositoryImpl(
      {MovieDetailRemoteDatasource? remoteDatasource})
      : _remoteDatasource =
            remoteDatasource ?? MovieDetailRemoteDatasourceImpl();

  final MovieDetailRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int movieId) =>
      _remoteDatasource.getMovieDetail(movieId);

  @override
  Future<Either<Failure, void>> toggleFavorite(int mediaId, bool favorite) =>
      _remoteDatasource.toggleFavorite(mediaId, favorite);
}
