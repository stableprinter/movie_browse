/// Holds API token and user ID provided at startup (e.g. from mainBrowse).
class AppConfig {
  AppConfig._();

  static String? _apiToken;
  static String? _userId;
  static String? _baseUrl;
  static String? _appName;
  static String? _imageBaseUrl;
  static String? _brandFont;

  static void set({
    String? apiToken,
    String? userId,
    String? baseUrl,
    String? appName,
    String? imageBaseUrl,
    String? brandFont,
  }) {
    _apiToken = apiToken;
    _userId = userId;
    _baseUrl = baseUrl;
    _appName = appName;
    _imageBaseUrl = imageBaseUrl;
    _brandFont = brandFont;
  }

  /// Applies config from Super-App browse entry-point arguments.
  /// [args]: [apiToken, userId, baseUrl, appName, imageBaseUrl]
  /// /// Super-App Documentation:
  /// First array of arguments is the API token
  /// Second array of arguments is the user ID
  /// Third array of arguments is the base URL
  /// Fourth array of arguments is the AppName
  /// Fifth array of arguments is the image base URL
  static void fromBrowseArgs(List<String> args) {
    set(
      apiToken: args.isNotEmpty ? args[0] : null,
      userId: args.length > 1 ? args[1] : null,
      baseUrl: args.length > 2 ? args[2] : null,
      appName: args.length > 3 ? args[3] : null,
      imageBaseUrl: args.length > 4 ? args[4] : null,
      brandFont: 'BrandFont',
    );
  }

  static String? get apiToken => _apiToken;
  static String? get userId => _userId;
  static String? get baseUrl => _baseUrl;
  static String? get appName => _appName;
  static String? get imageBaseUrl => _imageBaseUrl;
  static String? get brandFont => _brandFont;
}
