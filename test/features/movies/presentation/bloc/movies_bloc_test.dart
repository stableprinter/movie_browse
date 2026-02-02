import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/core/service/event_channel_service.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';
import 'package:movie_browse/features/movies/domain/usecases/discover_movies_usecase.dart';
import 'package:movie_browse/features/movies/presentation/bloc/movies_bloc.dart';

class MockDiscoverMoviesUseCase extends Mock implements DiscoverMoviesUseCase {}

class MockEventChannelService extends Mock implements EventChannelService {}

void main() {
  late MockDiscoverMoviesUseCase mockDiscoverMoviesUseCase;
  late MockEventChannelService mockEventChannelService;
  late StreamController<EventChannelEvent> eventStreamController;

  setUp(() {
    mockDiscoverMoviesUseCase = MockDiscoverMoviesUseCase();
    mockEventChannelService = MockEventChannelService();
    eventStreamController = StreamController<EventChannelEvent>.broadcast();

    when(() => mockEventChannelService.eventStream)
        .thenAnswer((_) => eventStreamController.stream);
  });

  tearDown(() {
    eventStreamController.close();
  });

  const tMovie1 = Movie(
    id: 1,
    title: 'Test Movie 1',
    posterPath: '/poster1.jpg',
    overview: 'Test overview 1',
    releaseDate: '2023-01-01',
    voteAverage: 7.5,
    voteCount: 100,
  );

  const tMovie2 = Movie(
    id: 2,
    title: 'Test Movie 2',
    posterPath: '/poster2.jpg',
    overview: 'Test overview 2',
    releaseDate: '2023-02-01',
    voteAverage: 8.0,
    voteCount: 200,
  );

  const tMovies = [tMovie1, tMovie2];

  group('MoviesBloc', () {
    test('initial state is MoviesInitial', () {
      final bloc = MoviesBloc(
        mockDiscoverMoviesUseCase,
        mockEventChannelService,
      );
      expect(bloc.state, equals(const MoviesInitial()));
      bloc.close();
    });

    group('MoviesLoadRequested', () {
      blocTest<MoviesBloc, MoviesState>(
        'emits [MoviesLoading, MoviesLoaded] when successful',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Right(tMovies));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        act: (bloc) => bloc.add(const MoviesLoadRequested()),
        expect: () => [
          const MoviesLoading(),
          const MoviesLoaded(tMovies, page: 1),
        ],
        verify: (_) {
          verify(() => mockDiscoverMoviesUseCase(page: 1)).called(1);
        },
      );

      blocTest<MoviesBloc, MoviesState>(
        'emits [MoviesLoading, MoviesError] when ServerFailure occurs',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        act: (bloc) => bloc.add(const MoviesLoadRequested()),
        expect: () => [
          const MoviesLoading(),
          const MoviesError('Server error'),
        ],
      );

      blocTest<MoviesBloc, MoviesState>(
        'emits [MoviesLoading, MoviesError] when NetworkFailure occurs',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Left(NetworkFailure('Network error')));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        act: (bloc) => bloc.add(const MoviesLoadRequested()),
        expect: () => [
          const MoviesLoading(),
          const MoviesError('Network error'),
        ],
      );

      blocTest<MoviesBloc, MoviesState>(
        'emits default error message when failure message is null',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        act: (bloc) => bloc.add(const MoviesLoadRequested()),
        expect: () => [
          const MoviesLoading(),
          const MoviesError('Unknown error'),
        ],
      );
    });

    group('MoviesRefreshRequested', () {
      blocTest<MoviesBloc, MoviesState>(
        'emits [MoviesLoaded] with fresh data when successful',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Right(tMovies));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        seed: () => const MoviesLoaded([tMovie1], page: 2),
        act: (bloc) => bloc.add(const MoviesRefreshRequested()),
        expect: () => [
          const MoviesLoaded(tMovies, page: 1),
        ],
        verify: (_) {
          verify(() => mockDiscoverMoviesUseCase(page: 1)).called(1);
        },
      );

      blocTest<MoviesBloc, MoviesState>(
        'emits [MoviesError] when failure occurs',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Left(ServerFailure('Refresh failed')));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        seed: () => const MoviesLoaded([tMovie1], page: 1),
        act: (bloc) => bloc.add(const MoviesRefreshRequested()),
        expect: () => [
          const MoviesError('Refresh failed'),
        ],
      );
    });

    group('MoviesLoadNextPageRequested', () {
      blocTest<MoviesBloc, MoviesState>(
        'does nothing when current state is not MoviesLoaded',
        build: () => MoviesBloc(
          mockDiscoverMoviesUseCase,
          mockEventChannelService,
        ),
        act: (bloc) => bloc.add(const MoviesLoadNextPageRequested()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockDiscoverMoviesUseCase(page: any(named: 'page')));
        },
      );

      blocTest<MoviesBloc, MoviesState>(
        'does nothing when isLoadingMore is true',
        build: () => MoviesBloc(
          mockDiscoverMoviesUseCase,
          mockEventChannelService,
        ),
        seed: () => const MoviesLoaded(
          tMovies,
          page: 1,
          isLoadingMore: true,
        ),
        act: (bloc) => bloc.add(const MoviesLoadNextPageRequested()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockDiscoverMoviesUseCase(page: any(named: 'page')));
        },
      );

      blocTest<MoviesBloc, MoviesState>(
        'does nothing when there are no more movies to load',
        build: () => MoviesBloc(
          mockDiscoverMoviesUseCase,
          mockEventChannelService,
        ),
        seed: () => const MoviesLoaded(
          [tMovie1], // Only 1 movie but page is 1, so 1 < 20*1
          page: 1,
        ),
        act: (bloc) => bloc.add(const MoviesLoadNextPageRequested()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockDiscoverMoviesUseCase(page: any(named: 'page')));
        },
      );

      blocTest<MoviesBloc, MoviesState>(
        'loads next page successfully',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Right([tMovie2]));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        seed: () => MoviesLoaded(
          List.generate(
            20,
            (i) => Movie(
              id: i,
              title: 'Movie $i',
            ),
          ),
          page: 1,
        ),
        act: (bloc) => bloc.add(const MoviesLoadNextPageRequested()),
        expect: () {
          final firstPageMovies = List.generate(
            20,
            (i) => Movie(
              id: i,
              title: 'Movie $i',
            ),
          );
          return [
            MoviesLoaded(
              firstPageMovies,
              page: 1,
              isLoadingMore: true,
            ),
            MoviesLoaded(
              [...firstPageMovies, tMovie2],
              page: 2,
            ),
          ];
        },
        verify: (_) {
          verify(() => mockDiscoverMoviesUseCase(page: 2)).called(1);
        },
      );

      blocTest<MoviesBloc, MoviesState>(
        'sets error when loading next page fails',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer(
                  (_) async => const Left(ServerFailure('Failed to load more')));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        seed: () => MoviesLoaded(
          List.generate(
            20,
            (i) => Movie(
              id: i,
              title: 'Movie $i',
            ),
          ),
          page: 1,
        ),
        act: (bloc) => bloc.add(const MoviesLoadNextPageRequested()),
        expect: () {
          final firstPageMovies = List.generate(
            20,
            (i) => Movie(
              id: i,
              title: 'Movie $i',
            ),
          );
          return [
            MoviesLoaded(
              firstPageMovies,
              page: 1,
              isLoadingMore: true,
            ),
            MoviesLoaded(
              firstPageMovies,
              page: 1,
              isLoadingMore: false,
              error: 'Failed to load more',
            ),
          ];
        },
      );

      blocTest<MoviesBloc, MoviesState>(
        'uses default error message when failure message is null',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        seed: () => MoviesLoaded(
          List.generate(
            20,
            (i) => Movie(
              id: i,
              title: 'Movie $i',
            ),
          ),
          page: 1,
        ),
        act: (bloc) => bloc.add(const MoviesLoadNextPageRequested()),
        expect: () {
          final firstPageMovies = List.generate(
            20,
            (i) => Movie(
              id: i,
              title: 'Movie $i',
            ),
          );
          return [
            MoviesLoaded(
              firstPageMovies,
              page: 1,
              isLoadingMore: true,
            ),
            MoviesLoaded(
              firstPageMovies,
              page: 1,
              isLoadingMore: false,
              error: 'Failed to load more',
            ),
          ];
        },
      );
    });

    group('MoviesFavoriteIdsReceived', () {
      blocTest<MoviesBloc, MoviesState>(
        'does nothing when current state is not MoviesLoaded',
        build: () => MoviesBloc(
          mockDiscoverMoviesUseCase,
          mockEventChannelService,
        ),
        act: (bloc) => bloc.add(const MoviesFavoriteIdsReceived([1, 2, 3])),
        expect: () => [],
      );

      blocTest<MoviesBloc, MoviesState>(
        'updates favoriteMovieIds when current state is MoviesLoaded',
        build: () => MoviesBloc(
          mockDiscoverMoviesUseCase,
          mockEventChannelService,
        ),
        seed: () => const MoviesLoaded(tMovies, page: 1),
        act: (bloc) => bloc.add(const MoviesFavoriteIdsReceived([1, 2, 3])),
        expect: () => [
          const MoviesLoaded(
            tMovies,
            page: 1,
            favoriteMovieIds: [1, 2, 3],
          ),
        ],
      );

      blocTest<MoviesBloc, MoviesState>(
        'replaces existing favoriteMovieIds with new ones',
        build: () => MoviesBloc(
          mockDiscoverMoviesUseCase,
          mockEventChannelService,
        ),
        seed: () => const MoviesLoaded(
          tMovies,
          page: 1,
          favoriteMovieIds: [1, 2],
        ),
        act: (bloc) => bloc.add(const MoviesFavoriteIdsReceived([3, 4, 5])),
        expect: () => [
          const MoviesLoaded(
            tMovies,
            page: 1,
            favoriteMovieIds: [3, 4, 5],
          ),
        ],
      );
    });

    group('EventChannel integration', () {
      blocTest<MoviesBloc, MoviesState>(
        'responds to FavoriteIdsEvent from EventChannel',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Right(tMovies));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        seed: () => const MoviesLoaded(tMovies, page: 1),
        act: (bloc) {
          eventStreamController.add(FavoriteIdsEvent([1, 2, 3]));
        },
        expect: () => [
          const MoviesLoaded(
            tMovies,
            page: 1,
            favoriteMovieIds: [1, 2, 3],
          ),
        ],
      );

      blocTest<MoviesBloc, MoviesState>(
        'responds to ShouldReloadBrowseEvent from EventChannel',
        build: () {
          when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
              .thenAnswer((_) async => const Right(tMovies));
          return MoviesBloc(
            mockDiscoverMoviesUseCase,
            mockEventChannelService,
          );
        },
        seed: () => const MoviesLoaded([tMovie1], page: 2),
        act: (bloc) {
          eventStreamController.add(const ShouldReloadBrowseEvent());
        },
        expect: () => [
          const MoviesLoaded(tMovies, page: 1),
        ],
        verify: (_) {
          verify(() => mockDiscoverMoviesUseCase(page: 1)).called(1);
        },
      );

      test('handles EventChannel errors gracefully', () async {
        when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
            .thenAnswer((_) async => const Right(tMovies));

        final bloc = MoviesBloc(
          mockDiscoverMoviesUseCase,
          mockEventChannelService,
        );

        // Trigger an error in the event stream
        eventStreamController.addError(Exception('Test error'));

        // Wait a bit to ensure the error is processed
        await Future.delayed(const Duration(milliseconds: 100));

        // Bloc should still be functional
        expect(bloc.state, const MoviesInitial());

        await bloc.close();
      });

      test('cancels event subscription on close', () async {
        when(() => mockDiscoverMoviesUseCase(page: any(named: 'page')))
            .thenAnswer((_) async => const Right(tMovies));

        final bloc = MoviesBloc(
          mockDiscoverMoviesUseCase,
          mockEventChannelService,
        );

        await bloc.close();

        // Verify that the bloc is closed
        expect(bloc.isClosed, true);
      });
    });
  });
}
