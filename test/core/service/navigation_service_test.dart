import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/service/navigation_service.dart';

void main() {
  group('NavigationService', () {
    test('navigatorKey is initialized', () {
      final service = NavigationService();

      expect(service.navigatorKey, isNotNull);
      expect(service.navigatorKey, isA<GlobalKey<NavigatorState>>());
    });

    test('push returns null when navigator is not initialized', () async {
      final service = NavigationService();
      final route = MaterialPageRoute(builder: (_) => const SizedBox());

      final result = await service.push(route);

      expect(result, isNull);
    });

    test('pushNamed returns null when navigator is not initialized', () async {
      final service = NavigationService();

      final result = await service.pushNamed('/test');

      expect(result, isNull);
    });

    test('pop does not throw when navigator is not initialized', () {
      final service = NavigationService();

      expect(() => service.pop(), returnsNormally);
    });

    test('maybePop returns false when navigator is not initialized', () async {
      final service = NavigationService();

      final result = await service.maybePop();

      expect(result, isFalse);
    });

    test('pushReplacement returns null when navigator is not initialized', () async {
      final service = NavigationService();
      final route = MaterialPageRoute(builder: (_) => const SizedBox());

      final result = await service.pushReplacement(route);

      expect(result, isNull);
    });

    test('pushReplacementNamed returns null when navigator is not initialized', () async {
      final service = NavigationService();

      final result = await service.pushReplacementNamed('/test');

      expect(result, isNull);
    });

    test('popUntil does not throw when navigator is not initialized', () {
      final service = NavigationService();

      expect(() => service.popUntil((route) => false), returnsNormally);
    });

    test('popUntilFirst does not throw when navigator is not initialized', () {
      final service = NavigationService();

      expect(() => service.popUntilFirst(), returnsNormally);
    });

    testWidgets('pushNamed works when navigator is initialized', (tester) async {
      final service = NavigationService();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: service.navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => const Scaffold(body: Text('Home')),
            '/test': (context) => const Scaffold(body: Text('Test')),
          },
        ),
      );

      service.pushNamed('/test');
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('pop works when navigator is initialized', (tester) async {
      final service = NavigationService();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: service.navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (context) => const Scaffold(body: Text('Home')),
            '/test': (context) => const Scaffold(body: Text('Test')),
          },
        ),
      );

      service.pushNamed('/test');
      await tester.pumpAndSettle();
      expect(find.text('Test'), findsOneWidget);

      service.pop();
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
