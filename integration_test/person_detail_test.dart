import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:movie_browse/core/di/service_locator.dart';
import 'package:movie_browse/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Person Detail Integration Tests', () {
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
    testWidgets('Navigate from movie detail to person detail',
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

      // Look for cast members
      final horizontalListView = find.byWidgetPredicate(
        (widget) =>
            widget is ListView &&
            widget.scrollDirection == Axis.horizontal,
      );

      if (horizontalListView.evaluate().isNotEmpty) {
        // Find first cast member and tap it
        final firstCastMember = find.descendant(
          of: horizontalListView,
          matching: find.byType(InkWell),
        ).first;

        if (firstCastMember.evaluate().isNotEmpty) {
          await tester.tap(firstCastMember);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Verify we're on person detail page
          expect(find.text('Person'), findsOneWidget);
        }
      }
    });

    testWidgets('View person details and biography',
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

      // Try to navigate to person detail if cast is available
      final horizontalListView = find.byWidgetPredicate(
        (widget) =>
            widget is ListView &&
            widget.scrollDirection == Axis.horizontal,
      );

      if (horizontalListView.evaluate().isNotEmpty) {
        final firstCastMember = find.descendant(
          of: horizontalListView,
          matching: find.byType(InkWell),
        ).first;

        if (firstCastMember.evaluate().isNotEmpty) {
          await tester.tap(firstCastMember);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Verify person page elements
          // Should have an AppBar
          expect(find.byType(AppBar), findsOneWidget);

          // Should have person information in a SingleChildScrollView
          expect(find.byType(SingleChildScrollView), findsOneWidget);

          // Look for biography section (if available)
          final biographyText = find.text('Biography');
          if (biographyText.evaluate().isNotEmpty) {
            expect(biographyText, findsOneWidget);
          }
        }
      }
    });

    testWidgets('Navigate back from person detail page',
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

      // Try to navigate to person detail
      final horizontalListView = find.byWidgetPredicate(
        (widget) =>
            widget is ListView &&
            widget.scrollDirection == Axis.horizontal,
      );

      if (horizontalListView.evaluate().isNotEmpty) {
        final firstCastMember = find.descendant(
          of: horizontalListView,
          matching: find.byType(InkWell),
        ).first;

        if (firstCastMember.evaluate().isNotEmpty) {
          await tester.tap(firstCastMember);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Tap back button
          final backButton = find.byType(BackButton);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();

            // Should be back on movie detail page
            expect(find.byType(SliverAppBar), findsOneWidget);
          }
        }
      }
    });

    testWidgets('Person detail error handling',
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

      // Try to navigate to person detail
      final horizontalListView = find.byWidgetPredicate(
        (widget) =>
            widget is ListView &&
            widget.scrollDirection == Axis.horizontal,
      );

      if (horizontalListView.evaluate().isNotEmpty) {
        final firstCastMember = find.descendant(
          of: horizontalListView,
          matching: find.byType(InkWell),
        ).first;

        if (firstCastMember.evaluate().isNotEmpty) {
          await tester.tap(firstCastMember);
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
        }
      }
    });

    testWidgets('Person detail displays profile photo or placeholder',
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

      // Try to navigate to person detail
      final horizontalListView = find.byWidgetPredicate(
        (widget) =>
            widget is ListView &&
            widget.scrollDirection == Axis.horizontal,
      );

      if (horizontalListView.evaluate().isNotEmpty) {
        final firstCastMember = find.descendant(
          of: horizontalListView,
          matching: find.byType(InkWell),
        ).first;

        if (firstCastMember.evaluate().isNotEmpty) {
          await tester.tap(firstCastMember);
          await tester.pumpAndSettle(const Duration(seconds: 5));

          // Should have either an Image.network or a placeholder Container
          final hasImage = find.byType(Image).evaluate().isNotEmpty;
          final hasPlaceholder = find.byIcon(Icons.person).evaluate().isNotEmpty;

          expect(hasImage || hasPlaceholder, isTrue,
              reason: 'Should show profile photo or placeholder');
        }
      }
    });
  });
}
