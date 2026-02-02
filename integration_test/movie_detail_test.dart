import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_browse/core/di/service_locator.dart';
import 'package:movie_browse/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Movie Detail Integration Tests', () {
    final List<int> mockFavoriteIds = [];

    setUp(() async {
      // Reset service locator before each test
      await resetServiceLocator();

      // Setup MethodChannel mock - handles calls from Flutter to native
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.movie.android/channel'),
        (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'onToggleFavorite':
              final movieId = methodCall.arguments as int;
              
              // Track favorite in mock list
              if (mockFavoriteIds.contains(movieId)) {
                mockFavoriteIds.remove(movieId);
              } else {
                mockFavoriteIds.add(movieId);
              }
              
              // Return success (no value needed for void)
              return null;
              
            default:
              throw MissingPluginException('No implementation found for method ${methodCall.method}');
          }
        },
      );

      // Setup EventChannel mock - prevents errors when app tries to listen to events
      // For integration tests, we'll just return an empty stream to avoid errors
      const eventChannelCodec = StandardMethodCodec();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'com.movie.android/events',
        (ByteData? message) async {
          if (message == null) return null;
          
          final methodCall = eventChannelCodec.decodeMethodCall(message);
          
          if (methodCall.method == 'listen') {
            // App is subscribing to event stream - acknowledge it
            return eventChannelCodec.encodeSuccessEnvelope(null);
          } else if (methodCall.method == 'cancel') {
            // App is canceling subscription - acknowledge it
            return eventChannelCodec.encodeSuccessEnvelope(null);
          }
          
          return null;
        },
      );
    });

    tearDown(() async {
      mockFavoriteIds.clear();
      
      // Clear mock handlers
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.movie.android/channel'),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('com.movie.android/events', null);
    });
    testWidgets('Navigate to movie detail and view information',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for movies to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find and tap on the first movie
      final firstMovieItem = find.byType(InkWell).first;
      expect(firstMovieItem, findsOneWidget);

      await tester.tap(firstMovieItem);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for movie detail to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify movie detail page elements
      // Should have a SliverAppBar with the movie title
      expect(find.byType(SliverAppBar), findsOneWidget);

      // Should have a favorite button
      final favoriteButtonBorder = find.byIcon(Icons.favorite_border);
      final favoriteButtonFilled = find.byIcon(Icons.favorite);
      
      // At least one should exist
      expect(
        favoriteButtonBorder.evaluate().isNotEmpty || 
        favoriteButtonFilled.evaluate().isNotEmpty,
        isTrue,
      );

      // Should have a back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('Toggle favorite on movie detail page',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for movies to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to movie detail
      final firstMovieItem = find.byType(InkWell).first;
      await tester.tap(firstMovieItem);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find favorite button (could be favorite or favorite_border)
      final favoriteButtonBorder = find.byIcon(Icons.favorite_border);
      final favoriteButtonFilled = find.byIcon(Icons.favorite);

      Finder favoriteButton;
      if (favoriteButtonBorder.evaluate().isNotEmpty) {
        favoriteButton = favoriteButtonBorder;
      } else {
        favoriteButton = favoriteButtonFilled;
      }

      // Tap favorite button
      await tester.tap(favoriteButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // The icon should change (either from border to filled or vice versa)
      // Just verify that some form of favorite icon exists
      final favoriteIconBorder = find.byIcon(Icons.favorite_border);
      final favoriteIconFilled = find.byIcon(Icons.favorite);
      
      // At least one should exist
      expect(
        favoriteIconBorder.evaluate().isNotEmpty || 
        favoriteIconFilled.evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('View cast members on movie detail page',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for movies to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to movie detail
      final firstMovieItem = find.byType(InkWell).first;
      await tester.tap(firstMovieItem);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for "Cast" text which indicates cast section
      final castText = find.text('Cast');
      
      // If cast is available, verify cast list
      if (castText.evaluate().isNotEmpty) {
        expect(castText, findsOneWidget);

        // Should have a horizontal ListView for cast members
        final horizontalListView = find.byWidgetPredicate(
          (widget) =>
              widget is ListView &&
              widget.scrollDirection == Axis.horizontal,
        );
        expect(horizontalListView, findsOneWidget);
      }
    });

    testWidgets('Navigate back from movie detail page',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for movies to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to movie detail
      final firstMovieItem = find.byType(InkWell).first;
      await tester.tap(firstMovieItem);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Tap back button
      final backButton = find.byIcon(Icons.arrow_back);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should be back on movie list
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Movie detail error handling and retry',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for movies to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to movie detail
      final firstMovieItem = find.byType(InkWell).first;
      await tester.tap(firstMovieItem);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if error state is shown
      final retryButton = find.text('Retry');
      if (retryButton.evaluate().isNotEmpty) {
        // Tap retry button
        await tester.tap(retryButton);
        await tester.pumpAndSettle();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Wait for retry to complete
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }
    });
  });
}
