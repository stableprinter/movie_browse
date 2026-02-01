import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';
import '../datasources/movies_remote_datasource.dart';
import '../datasources/movies_remote_datasource_impl.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  MoviesRepositoryImpl({MoviesRemoteDatasource? remoteDatasource})
      : _remoteDatasource = remoteDatasource ?? MoviesRemoteDatasourceImpl();

  final MoviesRemoteDatasource _remoteDatasource;

  @override
  Future<Either<Failure, List<Movie>>> discoverMovies({
    int page = 1,
    String language = 'en-US',
  }) =>
      _remoteDatasource.discoverMovies(page: page, language: language);
}
