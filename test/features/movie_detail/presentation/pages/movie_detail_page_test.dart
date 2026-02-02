import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/config/app_config.dart';
import 'package:movie_browse/core/service/navigation_service.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/cast_member.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/movie_detail.dart';
import 'package:movie_browse/features/movie_detail/presentation/bloc/movie_detail_bloc.dart';
import 'package:movie_browse/features/movie_detail/presentation/pages/movie_detail_page.dart';
import 'package:movie_browse/features/movie_detail/presentation/widgets/cast_list_item.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';
import 'package:mocktail/mocktail.dart';

class MockMovieDetailBloc extends Mock implements MovieDetailBloc {}

class MockNavigationService extends Mock implements NavigationService {}

void main() {
  late MockMovieDetailBloc mockMovieDetailBloc;
  late MockNavigationService mockNavigationService;

  setUpAll(() {
    registerFallbackValue(const MovieDetailLoadRequested());
  });

  setUp(() {
    mockMovieDetailBloc = MockMovieDetailBloc();
    mockNavigationService = MockNavigationService();

    // Setup default AppConfig
    AppConfig.set(
      appName: 'Test Movie App',
      imageBaseUrl: 'https://image.tmdb.org/t/p/w500',
    );

    // Setup default bloc stream
    when(() => mockMovieDetailBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockMovieDetailBloc.state).thenReturn(const MovieDetailInitial());
    when(() => mockMovieDetailBloc.close()).thenAnswer((_) async {});
    when(() => mockMovieDetailBloc.add(any())).thenReturn(null);
  });

  Widget createTestWidget({int movieId = 123}) {
    return RepositoryProvider<NavigationService>.value(
      value: mockNavigationService,
      child: BlocProvider<MovieDetailBloc>.value(
        value: mockMovieDetailBloc,
        child: MaterialApp(
          home: Scaffold(body: MovieDetailView(movieId: movieId)),
        ),
      ),
    );
  }

  group('MovieDetailPage Widget', () {
    testWidgets('displays empty widget when in initial state',
        (tester) async {
      when(() => mockMovieDetailBloc.state).thenReturn(const MovieDetailInitial());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays loading indicator when in loading state',
        (tester) async {
      when(() => mockMovieDetailBloc.state).thenReturn(const MovieDetailLoading());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message and retry button when in error state',
        (tester) async {
      const errorMessage = 'Failed to load movie details';
      when(() => mockMovieDetailBloc.state)
          .thenReturn(const MovieDetailError(errorMessage));

      await tester.pumpWidget(createTestWidget());

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('retry button dispatches MovieDetailLoadRequested event',
        (tester) async {
      when(() => mockMovieDetailBloc.state)
          .thenReturn(const MovieDetailError('Error'));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockMovieDetailBloc.add(const MovieDetailLoadRequested()))
          .called(greaterThanOrEqualTo(1));
    });

    testWidgets('displays movie detail when loaded', (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        posterPath: '/poster.jpg',
        releaseDate: '2024-01-01',
        voteAverage: 7.5,
        overview: 'Test overview',
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(detail: movieDetail),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Movie'), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);
      expect(find.text('7.5 / 10'), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Test overview'), findsOneWidget);
    });

    testWidgets('displays cast list when cast is available', (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 7.5,
      );

      const cast = [
        CastMember(
          id: 1,
          name: 'Actor One',
          profilePath: '/actor1.jpg',
          character: 'Character One',
        ),
        CastMember(
          id: 2,
          name: 'Actor Two',
          profilePath: '/actor2.jpg',
          character: 'Character Two',
        ),
      ];

      const movieDetail = MovieDetail(
        movie: movie,
        cast: cast,
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(detail: movieDetail),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Cast'), findsOneWidget);
      expect(find.byType(CastListItem), findsNWidgets(2));
    });

    testWidgets('does not display cast section when cast is empty',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 7.5,
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(detail: movieDetail),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Cast'), findsNothing);
      expect(find.byType(CastListItem), findsNothing);
    });

    testWidgets('displays favorite icon when movie is favorite',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 7.5,
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(
          detail: movieDetail,
          isFavorite: true,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('displays favorite border icon when movie is not favorite',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 7.5,
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(
          detail: movieDetail,
          isFavorite: false,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('favorite button dispatches MovieDetailFavoriteToggled event',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 7.5,
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(
          detail: movieDetail,
          isFavorite: false,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      verify(() => mockMovieDetailBloc.add(const MovieDetailFavoriteToggled()))
          .called(1);
    });

    testWidgets(
        'favorite button is disabled when favorite is loading',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 7.5,
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(
          detail: movieDetail,
          isFavorite: false,
          isFavoriteLoading: true,
        ),
      );

      await tester.pumpWidget(createTestWidget());

      // Should show a progress indicator instead of favorite icon
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('tapping cast member navigates to person detail',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 7.5,
      );

      const cast = [
        CastMember(
          id: 456,
          name: 'Test Actor',
          character: 'Test Character',
        ),
      ];

      const movieDetail = MovieDetail(
        movie: movie,
        cast: cast,
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(detail: movieDetail),
      );
      when(() => mockNavigationService.pushNamed<void>(
            any(),
            arguments: any(named: 'arguments'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(CastListItem));
      await tester.pump();

      verify(() => mockNavigationService.pushNamed<void>(
            any(),
            arguments: any(named: 'arguments'),
          )).called(1);
    });

    testWidgets('displays movie without poster when posterPath is null',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        posterPath: null,
        voteAverage: 7.5,
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(detail: movieDetail),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Movie'), findsOneWidget);
      // Container with grey background should be present
      final containerFinder = find.descendant(
        of: find.byType(FlexibleSpaceBar),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsAtLeastNWidgets(1));
    });

    testWidgets('does not display overview section when overview is null',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 7.5,
        overview: null,
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(detail: movieDetail),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Overview'), findsNothing);
    });

    testWidgets('does not display overview section when overview is empty',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 7.5,
        overview: '',
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(detail: movieDetail),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Overview'), findsNothing);
    });

    testWidgets('does not display rating when voteAverage is null',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: null,
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(detail: movieDetail),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('does not display rating when voteAverage is 0',
        (tester) async {
      const movie = Movie(
        id: 123,
        title: 'Test Movie',
        voteAverage: 0.0,
      );

      const movieDetail = MovieDetail(
        movie: movie,
        cast: [],
      );

      when(() => mockMovieDetailBloc.state).thenReturn(
        const MovieDetailLoaded(detail: movieDetail),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.star), findsNothing);
    });
  });
}
