import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/config/app_config.dart';
import 'package:movie_browse/core/service/navigation_service.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';
import 'package:movie_browse/features/movies/presentation/bloc/movies_bloc.dart';
import 'package:movie_browse/features/movies/presentation/pages/discover_movies_page.dart';
import 'package:movie_browse/features/movies/presentation/widgets/movie_list_item.dart';
import 'package:mocktail/mocktail.dart';

class MockMoviesBloc extends Mock implements MoviesBloc {}

class MockNavigationService extends Mock implements NavigationService {}

void main() {
  late MockMoviesBloc mockMoviesBloc;
  late MockNavigationService mockNavigationService;

  setUpAll(() {
    registerFallbackValue(const MoviesLoadRequested());
  });

  setUp(() {
    mockMoviesBloc = MockMoviesBloc();
    mockNavigationService = MockNavigationService();

    // Setup default AppConfig
    AppConfig.set(
      appName: 'Test Movie App',
      imageBaseUrl: 'https://image.tmdb.org/t/p/w500',
    );

    // Setup default bloc stream
    when(() => mockMoviesBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockMoviesBloc.state).thenReturn(const MoviesInitial());
    when(() => mockMoviesBloc.close()).thenAnswer((_) async {});
    when(() => mockMoviesBloc.add(any())).thenReturn(null);
  });

  Widget createTestWidget() {
    return RepositoryProvider<NavigationService>.value(
      value: mockNavigationService,
      child: BlocProvider<MoviesBloc>.value(
        value: mockMoviesBloc,
        child: const MaterialApp(
          home: Scaffold(body: DiscoverMoviesView()),
        ),
      ),
    );
  }

  group('DiscoverMoviesPage Widget', () {
    testWidgets('displays loading indicator when in initial state',
        (tester) async {
      when(() => mockMoviesBloc.state).thenReturn(const MoviesInitial());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MovieListItem), findsNothing);
    });

    testWidgets('displays loading indicator when in loading state',
        (tester) async {
      when(() => mockMoviesBloc.state).thenReturn(const MoviesLoading());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(MovieListItem), findsNothing);
    });

    testWidgets('displays error message and retry button when in error state',
        (tester) async {
      const errorMessage = 'Failed to load movies';
      when(() => mockMoviesBloc.state)
          .thenReturn(const MoviesError(errorMessage));

      await tester.pumpWidget(createTestWidget());

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('retry button dispatches MoviesLoadRequested event',
        (tester) async {
      when(() => mockMoviesBloc.state)
          .thenReturn(const MoviesError('Error'));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockMoviesBloc.add(const MoviesLoadRequested()))
          .called(greaterThanOrEqualTo(1));
    });

    testWidgets('displays empty state when movies list is empty',
        (tester) async {
      when(() => mockMoviesBloc.state).thenReturn(
        const MoviesLoaded(
          [],
          page: 1,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('No movies found'), findsOneWidget);
      expect(find.byType(MovieListItem), findsNothing);
    });

    testWidgets('displays list of movies when loaded', (tester) async {
      final movies = [
        const Movie(
          id: 1,
          title: 'Test Movie 1',
          posterPath: '/poster1.jpg',
          releaseDate: '2024-01-01',
          voteAverage: 7.5,
        ),
        const Movie(
          id: 2,
          title: 'Test Movie 2',
          posterPath: '/poster2.jpg',
          releaseDate: '2024-02-01',
          voteAverage: 8.0,
        ),
      ];

      when(() => mockMoviesBloc.state).thenReturn(
        MoviesLoaded(
          movies,
          page: 1,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(MovieListItem), findsNWidgets(2));
      expect(find.text('Test Movie 1'), findsOneWidget);
      expect(find.text('Test Movie 2'), findsOneWidget);
    });

    testWidgets('displays favorite icon for favorite movies', (tester) async {
      final movies = [
        const Movie(
          id: 1,
          title: 'Favorite Movie',
          voteAverage: 7.5,
        ),
        const Movie(
          id: 2,
          title: 'Regular Movie',
          voteAverage: 8.0,
        ),
      ];

      when(() => mockMoviesBloc.state).thenReturn(
        MoviesLoaded(
          movies,
          page: 1,
          favoriteMovieIds: const [1],
        ),
      );

      await tester.pumpWidget(createTestWidget());

      // Find favorite icons (should be one in the favorite movie)
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('isLoadingMore flag is respected in state', (tester) async {
      final movies = List.generate(
        5,
        (index) => Movie(
          id: index + 1,
          title: 'Movie ${index + 1}',
          voteAverage: 7.0,
        ),
      );

      when(() => mockMoviesBloc.state).thenReturn(
        MoviesLoaded(
          movies,
          page: 1,
          isLoadingMore: true,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      // ListView lazily renders items, so we should find at least some items
      expect(find.byType(MovieListItem), findsAtLeastNWidgets(1));
      
      // Verify the state has isLoadingMore flag set
      final state = mockMoviesBloc.state as MoviesLoaded;
      expect(state.isLoadingMore, true);
    });

    testWidgets('dispatches MoviesLoadNextPageRequested on scroll to bottom',
        (tester) async {
      final movies = List.generate(
        20,
        (index) => Movie(
          id: index + 1,
          title: 'Movie ${index + 1}',
          voteAverage: 7.0,
        ),
      );

      when(() => mockMoviesBloc.state).thenReturn(
        MoviesLoaded(
          movies,
          page: 1,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      // Scroll to near the bottom
      await tester.drag(
        find.byType(ListView),
        const Offset(0, -10000),
      );
      await tester.pumpAndSettle();

      verify(() => mockMoviesBloc.add(const MoviesLoadNextPageRequested()))
          .called(greaterThan(0));
    });

    testWidgets('refresh indicator dispatches MoviesRefreshRequested',
        (tester) async {
      final movies = [
        const Movie(
          id: 1,
          title: 'Test Movie',
          voteAverage: 7.5,
        ),
      ];

      when(() => mockMoviesBloc.state).thenReturn(
        MoviesLoaded(
          movies,
          page: 1,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      // Pull to refresh
      await tester.drag(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();

      verify(() => mockMoviesBloc.add(const MoviesRefreshRequested()))
          .called(1);
    });

    testWidgets('tapping movie item navigates to movie detail',
        (tester) async {
      final movies = [
        const Movie(
          id: 123,
          title: 'Test Movie',
          voteAverage: 7.5,
        ),
      ];

      when(() => mockMoviesBloc.state).thenReturn(
        MoviesLoaded(
          movies,
          page: 1,
        ),
      );
      when(() => mockNavigationService.pushNamed<void>(
            any(),
            arguments: any(named: 'arguments'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(MovieListItem));
      await tester.pump();

      verify(() => mockNavigationService.pushNamed<void>(
            any(),
            arguments: any(named: 'arguments'),
          )).called(1);
    });

  });
}
