/// Holds API token and user ID provided at startup (e.g. from mainBrowse).
class AppConfig {
  AppConfig._();

  static String? _apiToken;
  static String? _userId;

  static void set({String? apiToken, String? userId}) {
    _apiToken = apiToken;
    _userId = userId;
  }

  static String? get apiToken => _apiToken;
  static String? get userId => _userId;
}
