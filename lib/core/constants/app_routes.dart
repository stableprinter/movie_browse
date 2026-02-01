/// Named route constants for [MaterialApp.onGenerateRoute].
abstract final class AppRoutes {
  static const String browse = '/browse';
  static const String movie = '/movie';
  static const String person = '/person';

  /// Path-based movie route for deep links. Use [moviePath] for navigation.
  static String moviePath(int movieId) => '/movie/$movieId';
}
