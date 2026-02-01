import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/service/method_channel_service.dart';
import 'data/datasources/movie_detail_remote_datasource_impl.dart';
import 'data/repositories/movie_detail_repository_impl.dart';
import 'domain/usecases/get_movie_detail_usecase.dart';
import 'domain/usecases/toggle_favorite_usecase.dart';
import 'presentation/bloc/movie_detail_bloc.dart';
import 'presentation/pages/movie_detail_page.dart';

typedef MovieDetailBlocFactory = MovieDetailBloc Function(
  int movieId, {
  bool initialIsFavorite,
});

MovieDetailBloc createMovieDetailBloc(
  int movieId,
  MethodChannelService methodChannelService, {
  bool initialIsFavorite = false,
}) {
  final remoteDatasource = MovieDetailRemoteDatasourceImpl();
  final repository =
      MovieDetailRepositoryImpl(remoteDatasource: remoteDatasource);
  final getMovieDetailUseCase = GetMovieDetailUseCase(repository);
  final toggleFavoriteUseCase = ToggleFavoriteUseCase(repository);
  return MovieDetailBloc(
    getMovieDetailUseCase,
    toggleFavoriteUseCase,
    methodChannelService,
    movieId,
    initialIsFavorite: initialIsFavorite,
  );
}

Widget createMovieDetailPage(
  int movieId,
  MethodChannelService methodChannelService, {
  bool initialIsFavorite = false,
}) {
  return RepositoryProvider<MovieDetailBlocFactory>.value(
    value: (mid, {bool initialIsFavorite = false}) =>
        createMovieDetailBloc(mid, methodChannelService, initialIsFavorite: initialIsFavorite),
    child: MovieDetailPage(movieId: movieId, initialIsFavorite: initialIsFavorite),
  );
}
