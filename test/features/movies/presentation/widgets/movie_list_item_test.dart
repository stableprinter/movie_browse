import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/config/app_config.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';
import 'package:movie_browse/features/movies/presentation/widgets/movie_list_item.dart';

void main() {
  setUp(() {
    AppConfig.set(imageBaseUrl: 'https://image.test.com');
  });

  group('MovieListItem', () {
    testWidgets('displays movie title', (tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie Title',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movie: movie,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Movie Title'), findsOneWidget);
    });

    testWidgets('displays movie year when available', (tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        releaseDate: '2024-05-15',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movie: movie,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('2024'), findsOneWidget);
    });

    testWidgets('displays vote average when available', (tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        voteAverage: 8.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movie: movie,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('8.5'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('displays favorite icon when isFavorite is true', (tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        voteAverage: 7.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movie: movie,
              onTap: () {},
              isFavorite: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('does not display favorite icon when isFavorite is false', (tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        voteAverage: 7.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movie: movie,
              onTap: () {},
              isFavorite: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('displays placeholder when poster path is null', (tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        posterPath: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movie: movie,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.movie_outlined), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movie: movie,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('does not display vote average when it is 0', (tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        voteAverage: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movie: movie,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('does not display vote average when it is null', (tester) async {
      final movie = Movie(
        id: 1,
        title: 'Test Movie',
        voteAverage: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MovieListItem(
              movie: movie,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNothing);
    });
  });
}
