import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/cast_member.dart';

class CastListItem extends StatelessWidget {
  const CastListItem({
    super.key,
    required this.castMember,
    required this.onTap,
  });

  final CastMember castMember;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final photoUrl = castMember.profilePath != null
        ? '${ApiConstants.imageBaseUrl}${castMember.profilePath}'
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: photoUrl != null
                  ? Image.network(
                      photoUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
            const SizedBox(height: 8),
            Text(
              castMember.name,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (castMember.character != null &&
                castMember.character!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                castMember.character!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: 40,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
