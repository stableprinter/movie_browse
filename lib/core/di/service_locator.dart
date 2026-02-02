import 'package:get_it/get_it.dart';
import 'package:movie_browse/features/movie_detail/data/datasources/movie_detail_remote_datasource.dart';
import 'package:movie_browse/features/movies/data/datasources/movies_remote_datasource.dart';
import 'package:movie_browse/features/person_detail/data/datasources/person_remote_datasource.dart';

import '../../features/movie_detail/data/datasources/movie_detail_remote_datasource_impl.dart';
import '../../features/movie_detail/data/repositories/movie_detail_repository_impl.dart';
import '../../features/movie_detail/domain/repositories/movie_detail_repository.dart';
import '../../features/movie_detail/domain/usecases/get_movie_detail_usecase.dart';
import '../../features/movie_detail/domain/usecases/toggle_favorite_usecase.dart';
import '../../features/movie_detail/presentation/bloc/movie_detail_bloc.dart';
import '../../features/movies/data/datasources/movies_remote_datasource_impl.dart';
import '../../features/movies/data/repositories/movies_repository_impl.dart';
import '../../features/movies/domain/repositories/movies_repository.dart';
import '../../features/movies/domain/usecases/discover_movies_usecase.dart';
import '../../features/movies/presentation/bloc/movies_bloc.dart';
import '../../features/person_detail/data/datasources/person_remote_datasource_impl.dart';
import '../../features/person_detail/data/repositories/person_repository_impl.dart';
import '../../features/person_detail/domain/repositories/person_repository.dart';
import '../../features/person_detail/domain/usecases/get_person_detail_usecase.dart';
import '../../features/person_detail/presentation/bloc/person_detail_bloc.dart';
import '../service/event_channel_service.dart';
import '../service/method_channel_service.dart';
import '../service/navigation_service.dart';

final getIt = GetIt.instance;

/// Factory function to create MoviesBloc
MoviesBloc createMoviesBloc() {
  return MoviesBloc(
    getIt<DiscoverMoviesUseCase>(),
    getIt<EventChannelService>(),
  );
}

/// Factory function to create MovieDetailBloc
MovieDetailBloc createMovieDetailBloc(
  int movieId, {
  bool initialIsFavorite = false,
}) {
  return MovieDetailBloc(
    getIt<GetMovieDetailUseCase>(),
    getIt<ToggleFavoriteUseCase>(),
    getIt<MethodChannelService>(),
    movieId,
    initialIsFavorite: initialIsFavorite,
  );
}

/// Factory function to create PersonDetailBloc
PersonDetailBloc createPersonDetailBloc(int personId) {
  return PersonDetailBloc(
    getIt<GetPersonDetailUseCase>(),
    personId,
  );
}

/// Reset the service locator (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}

/// Initialize all dependencies using the service locator pattern
Future<void> setupServiceLocator() async {
  // Core Services (Singletons)
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());
  getIt.registerLazySingleton<EventChannelService>(() => EventChannelService());
  getIt.registerLazySingleton<MethodChannelService>(
    () => MethodChannelService(),
  );

  // Movies Feature
  getIt.registerLazySingleton<MoviesRemoteDatasource>(
    () => MoviesRemoteDatasourceImpl(),
  );
  getIt.registerLazySingleton<MoviesRepository>(
    () => MoviesRepositoryImpl(remoteDatasource: getIt()),
  );
  getIt.registerLazySingleton<DiscoverMoviesUseCase>(
    () => DiscoverMoviesUseCase(getIt()),
  );

  // Movie Detail Feature
  getIt.registerLazySingleton<MovieDetailRemoteDatasource>(
    () => MovieDetailRemoteDatasourceImpl(),
  );
  getIt.registerLazySingleton<MovieDetailRepository>(
    () => MovieDetailRepositoryImpl(remoteDatasource: getIt()),
  );
  getIt.registerLazySingleton<GetMovieDetailUseCase>(
    () => GetMovieDetailUseCase(getIt()),
  );
  getIt.registerLazySingleton<ToggleFavoriteUseCase>(
    () => ToggleFavoriteUseCase(getIt()),
  );

  // Person Detail Feature
  getIt.registerLazySingleton<PersonRemoteDatasource>(
    () => PersonRemoteDatasourceImpl(),
  );
  getIt.registerLazySingleton<PersonRepository>(
    () => PersonRepositoryImpl(remoteDatasource: getIt()),
  );
  getIt.registerLazySingleton<GetPersonDetailUseCase>(
    () => GetPersonDetailUseCase(getIt()),
  );
}
