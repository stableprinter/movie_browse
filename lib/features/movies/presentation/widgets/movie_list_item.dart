import 'package:flutter/material.dart';
import 'package:movie_browse/core/config/app_config.dart';

import '../../domain/entities/movie.dart';

class MovieListItem extends StatelessWidget {
  const MovieListItem({
    super.key,
    required this.movie,
    required this.onTap,
    this.isFavorite = false,
  });

  final Movie movie;
  final VoidCallback onTap;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath != null
        ? '${AppConfig.imageBaseUrl}${movie.posterPath}'
        : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: posterUrl != null
                  ? Image.network(
                      posterUrl,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.year.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      movie.year,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  if (movie.voteAverage != null && movie.voteAverage! > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage!.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (isFavorite) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.favorite,
                            size: 16,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 120,
      color: Colors.grey.shade300,
      child: const Icon(Icons.movie_outlined, size: 40),
    );
  }
}
