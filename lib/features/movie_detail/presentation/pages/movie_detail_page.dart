import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_browse/core/config/app_config.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/service/navigation_service.dart';
import '../bloc/movie_detail_bloc.dart';
import '../widgets/cast_list_item.dart';

class MovieDetailPage extends StatelessWidget {
  const MovieDetailPage({
    super.key,
    required this.movieId,
    this.initialIsFavorite = false,
  });

  final int movieId;
  final bool initialIsFavorite;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MovieDetailBloc>(
      create: (_) =>
          createMovieDetailBloc(movieId, initialIsFavorite: initialIsFavorite)
            ..add(const MovieDetailLoadRequested()),
      child: MovieDetailView(movieId: movieId),
    );
  }
}

class MovieDetailView extends StatelessWidget {
  const MovieDetailView({super.key, required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MovieDetailBloc, MovieDetailState>(
        builder: (context, state) {
          if (state is MovieDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MovieDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<MovieDetailBloc>().add(
                        const MovieDetailLoadRequested(),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MovieDetailLoaded) {
            final detail = state.detail;
            final movie = detail.movie;
            final posterUrl = movie.posterPath != null
                ? '${AppConfig.imageBaseUrl}${movie.posterPath}'
                : null;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  actions: [
                    IconButton(
                      icon: state.isFavoriteLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              state.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: state.isFavorite ? Colors.red : null,
                            ),
                      onPressed: state.isFavoriteLoading
                          ? null
                          : () => context
                              .read<MovieDetailBloc>()
                              .add(const MovieDetailFavoriteToggled()),
                    ),
                  ],
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      // This page can be directly rendered by the engine (e.g. deep
                      // link). When it's the first page, pop back to the native page.
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        SystemNavigator.pop();
                      }
                    },
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(movie.title),
                    background: posterUrl != null
                        ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey.shade800),
                          )
                        : Container(color: Colors.grey.shade800),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (movie.releaseDate != null &&
                            movie.releaseDate!.isNotEmpty)
                          Text(
                            movie.year,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        if (movie.voteAverage != null &&
                            movie.voteAverage! > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${movie.voteAverage!.toStringAsFixed(1)} / 10',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                        if (movie.overview != null &&
                            movie.overview!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Overview',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(movie.overview!),
                        ],
                        if (detail.cast.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Cast',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ),
                if (detail.cast.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: detail.cast.length,
                        itemBuilder: (context, index) {
                          final member = detail.cast[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: CastListItem(
                              castMember: member,
                              onTap: () =>
                                  _openPersonDetail(context, member.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openPersonDetail(BuildContext context, int personId) {
    context.read<NavigationService>().pushNamed<void>(
      AppRoutes.person,
      arguments: personId,
    );
  }
}
