import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_browse/core/config/app_config.dart';

import 'core/constants/app_routes.dart';
import 'core/di/service_locator.dart';
import 'core/service/navigation_service.dart';
import 'features/movie_detail/movie_detail_route_args.dart';
import 'features/movie_detail/presentation/pages/movie_detail_page.dart';
import 'features/movies/presentation/pages/discover_movies_page.dart';
import 'features/person_detail/presentation/pages/person_detail_page.dart';

/// Parses a route name of the form `/movie:true:123`
/// Returns a tuple of (isFavorite, movieId) if matched, otherwise null.
({bool isFavorite, int movieId})? _movieDetailParamsFromPath(String? name) {
  if (name == null) return null;
  // Pattern: /movie:{isFavorite}:{movieId}
  final regex = RegExp(r'^/movie:(true|false):(\d+)$');
  final match = regex.firstMatch(name);
  if (match == null) return null;
  final isFavorite = match.group(1) == 'true';
  final movieId = int.tryParse(match.group(2)!);
  if (movieId == null) return null;
  return (isFavorite: isFavorite, movieId: movieId);
}

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  // Handle path-based /movie/{id} (e.g. deep links)
  final movieDetailParams = _movieDetailParamsFromPath(settings.name);
  if (movieDetailParams?.movieId != null &&
      movieDetailParams?.isFavorite != null) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => MovieDetailPage(
        movieId: movieDetailParams!.movieId,
        initialIsFavorite: movieDetailParams.isFavorite,
      ),
    );
  }

  switch (settings.name) {
    case AppRoutes.browse:
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const Scaffold(body: DiscoverMoviesPage()),
      );
    case AppRoutes.movie:
      final args = settings.arguments as MovieDetailRouteArgs;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => MovieDetailPage(
          movieId: args.movieId,
          initialIsFavorite: args.isFavorite,
        ),
      );
    case AppRoutes.person:
      final personId = settings.arguments as int;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => PersonDetailPage(personId: personId),
      );
    default:
      return null;
  }
}

Route<dynamic> _onUnknownRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(child: Text('No route defined for ${settings.name}')),
    ),
  );
}

class MovieBrowseApp extends StatelessWidget {
  const MovieBrowseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<NavigationService>.value(
      value: getIt<NavigationService>(),
      child: MaterialApp(
        navigatorKey: getIt<NavigationService>().navigatorKey,
        title: AppConfig.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: AppConfig.brandFont
        ),
        initialRoute: AppRoutes.browse,
        onGenerateRoute: _onGenerateRoute,
        onUnknownRoute: _onUnknownRoute,
      ),
    );
  }
}
