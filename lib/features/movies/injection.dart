import '../../core/service/event_channel_service.dart';
import 'data/datasources/movies_remote_datasource_impl.dart';
import 'data/repositories/movies_repository_impl.dart';
import 'domain/usecases/discover_movies_usecase.dart';
import 'presentation/bloc/movies_bloc.dart';

MoviesBloc createMoviesBloc(EventChannelService eventChannelService) {
  final remoteDatasource = MoviesRemoteDatasourceImpl();
  final repository = MoviesRepositoryImpl(remoteDatasource: remoteDatasource);
  final discoverMoviesUseCase = DiscoverMoviesUseCase(repository);
  return MoviesBloc(discoverMoviesUseCase, eventChannelService);
}

typedef MoviesBlocFactory = MoviesBloc Function();
