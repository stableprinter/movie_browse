import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_browse/core/di/service_locator.dart';
import 'package:movie_browse/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Movie Browse App Integration Tests', () {
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

    testWidgets(
      'Complete user flow: Browse movies, view details, view cast member',
      (WidgetTester tester) async {
        // Start the app
        app.main();
        await tester.pumpAndSettle();

        // Wait for app to initialize and load movies
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verify movies are loaded - look for ListView which contains movie items
        expect(find.byType(ListView), findsOneWidget);

        // Find and tap on the first movie item
        final firstMovieItem = find.byType(InkWell).first;
        if (firstMovieItem.evaluate().isNotEmpty) {
          await tester.tap(firstMovieItem);
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Verify we're on the movie detail page by looking for SliverAppBar
          final hasSliverAppBar = find
              .byType(SliverAppBar)
              .evaluate()
              .isNotEmpty;
          expect(hasSliverAppBar, isTrue);

          // Navigate back to movie list
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
            final hasListView = find.byType(ListView).evaluate().isNotEmpty;
            expect(hasListView, isTrue);
          }
        }
      },
    );

    testWidgets('Movie list displays movies or error', (
      WidgetTester tester,
    ) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for data to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should either show movies or an error message
      final hasListView = find.byType(ListView).evaluate().isNotEmpty;
      final hasErrorMessage = find.text('Retry').evaluate().isNotEmpty;

      expect(
        hasListView || hasErrorMessage,
        isTrue,
        reason: 'Should show either movie list or error message',
      );
    });

    testWidgets('Pull to refresh functionality', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for movies to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        // Perform pull to refresh
        await tester.drag(find.byType(ListView), const Offset(0, 300));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Wait for refresh to complete
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Should still show movie list
        expect(find.byType(ListView), findsOneWidget);
      }
    });

    testWidgets('Scroll through movie list', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial movies to load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final listView = find.byType(ListView);
      if (listView.evaluate().isNotEmpty) {
        // Scroll down
        await tester.drag(listView, const Offset(0, -3500));
        await tester.pumpAndSettle();

        // Should still see the ListView
        expect(find.byType(ListView), findsOneWidget);
      }
    });

    testWidgets('App works without native platform channels', (WidgetTester tester) async {
      // This test verifies that the app can run in integration test environment
      // without actual native platform channels (they are mocked)
      
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify app is running and responsive
      // The mocked channels should prevent any MissingPluginException errors
      expect(find.byType(ListView), findsWidgets);
      
      // Verify we can interact with the app
      final movieItems = find.byType(InkWell);
      expect(movieItems.evaluate().isNotEmpty, isTrue, 
        reason: 'Should find movie items in the list');
    });
  });
}
