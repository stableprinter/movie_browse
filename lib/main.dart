import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';

@pragma('vm:entry-point')
/// Super-App Documentation:
/// First array of arguments is the API token
/// Second array of arguments is the user ID
void mainBrowse(List<String> args) async {
  final apiToken = args.isNotEmpty ? args.first : null;
  final userId = args.length > 1 ? args[1] : null;
  AppConfig.set(apiToken: apiToken, userId: userId);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovieBrowseApp());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MovieBrowseApp());
}
