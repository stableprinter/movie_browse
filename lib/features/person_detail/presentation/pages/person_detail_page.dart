import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_browse/core/config/app_config.dart';

import '../../../../core/di/service_locator.dart';
import '../bloc/person_detail_bloc.dart';

class PersonDetailPage extends StatelessWidget {
  const PersonDetailPage({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PersonDetailBloc>(
      create: (_) =>
          createPersonDetailBloc(personId)
            ..add(const PersonDetailLoadRequested()),
      child: PersonDetailView(personId: personId),
    );
  }
}

class PersonDetailView extends StatelessWidget {
  const PersonDetailView({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Person')),
      body: BlocBuilder<PersonDetailBloc, PersonDetailState>(
        builder: (context, state) {
          if (state is PersonDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PersonDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.read<PersonDetailBloc>().add(
                        const PersonDetailLoadRequested(),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PersonDetailLoaded) {
            final person = state.person;
            final photoUrl = person.profilePath != null
                ? '${AppConfig.imageBaseUrl}${person.profilePath}'
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: photoUrl != null
                          ? Image.network(
                              photoUrl,
                              width: 200,
                              height: 280,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(context),
                            )
                          : _buildPlaceholder(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    person.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (person.birthday != null &&
                      person.birthday!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Born: ${person.birthday}${person.placeOfBirth != null && person.placeOfBirth!.isNotEmpty ? ' in ${person.placeOfBirth}' : ''}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  if (person.biography != null &&
                      person.biography!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Biography',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(person.biography!),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 200,
      height: 280,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: 80,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
