/// Arguments for navigating to the movie detail route from home.
class MovieDetailRouteArgs {
  const MovieDetailRouteArgs({
    required this.movieId,
    this.isFavorite = false,
  });

  final int movieId;
  final bool isFavorite;
}
