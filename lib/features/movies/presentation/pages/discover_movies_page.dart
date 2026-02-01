import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/service/navigation_service.dart';
import '../../../movie_detail/movie_detail_route_args.dart';
import '../../injection.dart';
import '../bloc/movies_bloc.dart';
import '../widgets/movie_list_item.dart';

class DiscoverMoviesPage extends StatelessWidget {
  const DiscoverMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MoviesBloc>(
      create: (_) {
        final bloc = context.read<MoviesBlocFactory>()();
        bloc.add(const MoviesLoadRequested());
        return bloc;
      },
      child: const _DiscoverMoviesView(),
    );
  }
}

class _DiscoverMoviesView extends StatelessWidget {
  const _DiscoverMoviesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
      ),
      body: BlocConsumer<MoviesBloc, MoviesState>(
        listener: (context, state) {},
        buildWhen: (previous, current) => true,
        builder: (context, state) {
          if (state is MoviesInitial || state is MoviesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MoviesError) {
            return Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<MoviesBloc>().add(const MoviesLoadRequested()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (state is MoviesLoaded) {
            if (state.movies.isEmpty) {
              return Center(
                child: Text(
                  'No movies found',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MoviesBloc>().add(const MoviesRefreshRequested());
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200 &&
                      !state.isLoadingMore) {
                    context
                        .read<MoviesBloc>()
                        .add(const MoviesLoadNextPageRequested());
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: state.movies.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.movies.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final movie = state.movies[index];
                    final isFav = state.favoriteMovieIds.contains(movie.id);
                    return MovieListItem(
                      movie: movie,
                      onTap: () => _openMovieDetail(context, movie.id, isFav),
                      isFavorite: isFav,
                    );
                  },
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openMovieDetail(BuildContext context, int movieId, bool isFav) {
    context.read<NavigationService>().pushNamed<void>(
          AppRoutes.movie,
          arguments: MovieDetailRouteArgs(movieId: movieId, isFavorite: isFav),
        );
  }
}
