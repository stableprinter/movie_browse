/// TMDB API configuration.
///
/// Get your API key from https://www.themoviedb.org/settings/api
/// For Bearer auth, use the "API Read Access Token" (v4) from the same page.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Fallback when no token is provided (e.g. main() without args).
  /// Replace with your TMDB API Read Access Token (v4) from https://www.themoviedb.org/settings/api
  static const String mockToken = '';

  // Endpoints
  static const String discoverMovie = '/discover/movie';
  static const String movieDetail = '/movie';
  static const String movieCredits = '/credits';
  static const String personDetail = '/person';

  static String discoverMovieEndpoint() => discoverMovie;
  static String movieDetailEndpoint(int id) => '$movieDetail/$id';
  static String movieCreditsEndpoint(int id) => '$movieDetail/$id$movieCredits';
  static String personDetailEndpoint(int id) => '$personDetail/$id';
  static String accountFavoriteEndpoint(int accountId) =>
      '/account/$accountId/favorite';
}
