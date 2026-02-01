import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_routes.dart';
import 'core/service/event_channel_service.dart';
import 'core/service/method_channel_service.dart';
import 'core/service/navigation_service.dart';
import 'features/movie_detail/injection.dart';
import 'features/movie_detail/movie_detail_route_args.dart';
import 'features/movies/injection.dart';
import 'features/movies/presentation/pages/discover_movies_page.dart';
import 'features/person_detail/injection.dart';

final _navigationService = NavigationService();
final _eventChannelService = EventChannelService();
final _methodChannelService = MethodChannelService();

/// Parses a route name of the form `/movie:true:123`
/// Returns a tuple of (isFavorite, movieId) if matched, otherwise null.
({bool isFavorite, int movieId})? _movieDetailParamsFromPath(String? name) {
  if (name == null) return null;
  // Pattern: /movie:true:123 or /movie:false:456
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
      builder: (_) => createMovieDetailPage(
        movieDetailParams!.movieId,
        _methodChannelService,
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
        builder: (_) => createMovieDetailPage(
          args.movieId,
          _methodChannelService,
          initialIsFavorite: args.isFavorite,
        ),
      );
    case AppRoutes.person:
      final personId = settings.arguments as int;
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => createPersonDetailPage(personId),
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NavigationService>.value(value: _navigationService),
        RepositoryProvider<EventChannelService>.value(
          value: _eventChannelService,
        ),
        RepositoryProvider<MoviesBlocFactory>.value(
          value: () => createMoviesBloc(_eventChannelService),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigationService.navigatorKey,
        title: 'Movie Browse',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.browse,
        onGenerateRoute: _onGenerateRoute,
        onUnknownRoute: _onUnknownRoute,
      ),
    );
  }
}
