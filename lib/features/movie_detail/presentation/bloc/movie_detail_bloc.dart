import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/service/method_channel_service.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/usecases/get_movie_detail_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

part 'movie_detail_event.dart';
part 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  MovieDetailBloc(
    this._getMovieDetailUseCase,
    this._toggleFavoriteUseCase,
    this._methodChannelService,
    this._movieId, {
    this.initialIsFavorite = false,
  }) : super(const MovieDetailInitial()) {
    on<MovieDetailLoadRequested>(_onLoadRequested);
    on<MovieDetailFavoriteToggled>(_onFavoriteToggled);
  }

  final GetMovieDetailUseCase _getMovieDetailUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final MethodChannelService _methodChannelService;
  final int _movieId;
  final bool initialIsFavorite;

  Future<void> _onLoadRequested(
    MovieDetailLoadRequested event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(const MovieDetailLoading());
    final result = await _getMovieDetailUseCase(_movieId);
    result.fold(
      (failure) => emit(MovieDetailError(
          failure.message ?? 'Failed to load movie details')),
      (detail) => emit(MovieDetailLoaded(
        detail: detail,
        isFavorite: initialIsFavorite,
      )),
    );
  }

  Future<void> _onFavoriteToggled(
    MovieDetailFavoriteToggled event,
    Emitter<MovieDetailState> emit,
  ) async {
    final state = this.state;
    if (state is! MovieDetailLoaded || state.isFavoriteLoading) return;

    emit(state.copyWith(isFavoriteLoading: true));

    final result = await _toggleFavoriteUseCase(
      _movieId,
      !state.isFavorite,
    );

    result.fold(
      (_) => emit(state.copyWith(isFavoriteLoading: false)),
      (_) {
        emit(state.copyWith(
          isFavorite: !state.isFavorite,
          isFavoriteLoading: false,
        ));
        _methodChannelService.notifyToggleFavorite(_movieId);
      },
    );
  }
}
