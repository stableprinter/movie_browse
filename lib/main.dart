import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';

@pragma('vm:entry-point')

void mainBrowse(List<String> args) async {
  AppConfig.fromBrowseArgs(args);
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const MovieBrowseApp());
}

void main() async {
  await setupServiceLocator();

  AppConfig.set(
    apiToken: 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI2OGYxNTcxMzMxODkwMDUwYzhhNGQ0NTE0NDM1OTYxNiIsIm5iZiI6MTc2OTgyOTAyMS4wODYwMDAyLCJzdWIiOiI2OTdkNzI5ZGI4YmJhMTgxMDIxNWUyMGEiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.garhbAHms5Jl-D5aqGJ2F-ZQsiqr7TEUP6H-gyKGORU',
    userId: '21712006',
    baseUrl: 'https://api.themoviedb.org/3',
    appName: 'MovieBrowse (Mock)',
    imageBaseUrl: 'https://image.tmdb.org/t/p/w500',
    /// for debugging purposes, you can change the font to any other font you want
    /// dont forget to change the font in the pubspec.yaml file and add in assets folder
    brandFont: 'BrandFont',
  );

  WidgetsFlutterBinding.ensureInitialized();
  // Optionally populate AppConfig with mock/default values in mock mode
  runApp(const MovieBrowseApp());
}
