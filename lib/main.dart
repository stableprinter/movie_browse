import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';

@pragma('vm:entry-point')

void mainBrowse(List<String> args) async {
  AppConfig.fromBrowseArgs(args);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovieBrowseApp());
}

void main() async {
  AppConfig.set(
    apiToken: 'mock-token',
    userId: 'mock-user',
    baseUrl: 'https://mockapi.example.com',
    appName: 'MovieBrowse (Mock)',
    imageBaseUrl: 'https://mockimages.example.com/',
  );

  WidgetsFlutterBinding.ensureInitialized();
  // Optionally populate AppConfig with mock/default values in mock mode
  runApp(const MovieBrowseApp());
}
