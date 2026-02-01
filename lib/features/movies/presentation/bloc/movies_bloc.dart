import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/service/event_channel_service.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/discover_movies_usecase.dart';

part 'movies_event.dart';
part 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  MoviesBloc(this._discoverMoviesUseCase, this._eventChannelService)
      : super(const MoviesInitial()) {
    on<MoviesLoadRequested>(_onLoadRequested);
    on<MoviesRefreshRequested>(_onRefreshRequested);
    on<MoviesLoadNextPageRequested>(_onLoadNextPageRequested);
    on<MoviesFavoriteIdsReceived>(_onFavoriteIdsReceived);
    _eventChannelSubscription = _eventChannelService.eventStream.listen(
      (event) {
        switch (event) {
          case FavoriteIdsEvent(:final ids):
            add(MoviesFavoriteIdsReceived(ids));
          case ShouldReloadBrowseEvent():
            add(const MoviesRefreshRequested());
        }
      },
      onError: (Object e, StackTrace st) {
        // Native may not be attached when running in standalone Flutter.
      },
    );
  }

  final DiscoverMoviesUseCase _discoverMoviesUseCase;
  final EventChannelService _eventChannelService;
  StreamSubscription<EventChannelEvent>? _eventChannelSubscription;
  static const int _pageSize = 20;

  @override
  Future<void> close() {
    _eventChannelSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadRequested(
    MoviesLoadRequested event,
    Emitter<MoviesState> emit,
  ) async {
    emit(const MoviesLoading());
    final result = await _discoverMoviesUseCase(page: 1);
    result.fold(
      (failure) => emit(MoviesError(failure.message ?? 'Unknown error')),
      (movies) => emit(MoviesLoaded(movies, page: 1)),
    );
  }

  Future<void> _onRefreshRequested(
    MoviesRefreshRequested event,
    Emitter<MoviesState> emit,
  ) async {
    final result = await _discoverMoviesUseCase(page: 1);
    result.fold(
      (failure) => emit(MoviesError(failure.message ?? 'Unknown error')),
      (movies) => emit(MoviesLoaded(movies, page: 1)),
    );
  }

  Future<void> _onLoadNextPageRequested(
    MoviesLoadNextPageRequested event,
    Emitter<MoviesState> emit,
  ) async {
    final current = state;
    if (current is! MoviesLoaded || current.isLoadingMore) return;
    if (current.movies.length < _pageSize * current.page) return;

    emit(current.copyWith(isLoadingMore: true));
    final nextPage = current.page + 1;
    final result = await _discoverMoviesUseCase(page: nextPage);
    result.fold(
      (failure) => emit(
        current.copyWith(
          isLoadingMore: false,
          error: failure.message ?? 'Failed to load more',
        ),
      ),
      (newMovies) => emit(
        MoviesLoaded(
          [...current.movies, ...newMovies],
          page: nextPage,
          favoriteMovieIds: current.favoriteMovieIds,
        ),
      ),
    );
  }

  void _onFavoriteIdsReceived(
    MoviesFavoriteIdsReceived event,
    Emitter<MoviesState> emit,
  ) {
    final current = state;
    if (current is MoviesLoaded) {
      emit(current.copyWith(favoriteMovieIds: event.favoriteMovieIds));
    }
  }
}
