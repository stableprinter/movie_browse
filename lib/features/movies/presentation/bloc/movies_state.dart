part of 'movies_bloc.dart';

sealed class MoviesState extends Equatable {
  const MoviesState();

  @override
  List<Object?> get props => [];
}

final class MoviesInitial extends MoviesState {
  const MoviesInitial();
}

final class MoviesLoading extends MoviesState {
  const MoviesLoading();
}

final class MoviesLoaded extends MoviesState {
  const MoviesLoaded(
    this.movies, {
    this.page = 1,
    this.isLoadingMore = false,
    this.error,
    this.favoriteMovieIds = const [],
  }) : super();

  final List<Movie> movies;
  final int page;
  final bool isLoadingMore;
  final String? error;
  /// IDs of movies marked as favorite (from native EventChannel / broadcastFavList).
  final List<int> favoriteMovieIds;

  MoviesLoaded copyWith({
    List<Movie>? movies,
    int? page,
    bool? isLoadingMore,
    String? error,
    List<int>? favoriteMovieIds,
  }) {
    return MoviesLoaded(
      movies ?? this.movies,
      page: page ?? this.page,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      favoriteMovieIds: favoriteMovieIds ?? this.favoriteMovieIds,
    );
  }

  @override
  List<Object?> get props => [movies, page, isLoadingMore, error, favoriteMovieIds];
}

final class MoviesError extends MoviesState {
  const MoviesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
