part of 'movies_bloc.dart';

sealed class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

final class MoviesLoadRequested extends MoviesEvent {
  const MoviesLoadRequested();
}

final class MoviesRefreshRequested extends MoviesEvent {
  const MoviesRefreshRequested();
}

final class MoviesLoadNextPageRequested extends MoviesEvent {
  const MoviesLoadNextPageRequested();
}

/// Fired when native sends favorite movie IDs via EventChannel (broadcastFavList).
final class MoviesFavoriteIdsReceived extends MoviesEvent {
  const MoviesFavoriteIdsReceived(this.favoriteMovieIds);

  final List<int> favoriteMovieIds;

  @override
  List<Object?> get props => [favoriteMovieIds];
}
