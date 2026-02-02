# Flutter Integration Testing Guide

This document provides a comprehensive guide to the integration testing setup for the Movie Browse app.

## Overview

Integration tests verify that the app works correctly as a whole, testing real user flows including UI interactions, navigation, and API calls. Unlike unit tests that test individual components in isolation, integration tests run the entire app and simulate user interactions.

## Project Structure

```
movie_browse/
├── integration_test/
│   ├── app_test.dart                 # Main app flow tests
│   ├── movie_detail_test.dart        # Movie detail page tests
│   ├── person_detail_test.dart       # Person detail page tests
│   └── README.md                     # Quick reference guide
├── test_driver/
│   └── integration_test.dart         # Test driver for device/emulator runs
└── lib/
    └── core/
        └── di/
            └── service_locator.dart  # Updated with resetServiceLocator()
```

## What Was Added

### 1. Dependencies

Added to `pubspec.yaml`:
```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

### 2. Service Locator Reset Function

Added `resetServiceLocator()` to `lib/core/di/service_locator.dart`:
```dart
/// Reset the service locator (useful for testing)
Future<void> resetServiceLocator() async {
  await getIt.reset();
}
```

This function is crucial for integration tests as it clears all registered services between test runs, preventing "Type already registered" errors.

### 3. Integration Test Files

#### a. `integration_test/app_test.dart`
Tests the main app functionality:
- Complete user flow from browse to detail and back
- Movie list displays correctly or shows error
- Pull to refresh functionality
- Scrolling through movie list

#### b. `integration_test/movie_detail_test.dart`
Tests movie detail page:
- Navigate to movie detail and view information
- Toggle favorite button
- View cast members
- Navigate back from detail page
- Error handling and retry functionality

#### c. `integration_test/person_detail_test.dart`
Tests person detail page:
- Navigate from movie detail to person detail
- View person details and biography
- Navigate back from person page
- Error handling
- Display profile photo or placeholder

### 4. Test Driver

Created `test_driver/integration_test.dart` for running tests with detailed reporting and performance metrics.

## Running Integration Tests

### Basic Commands

```bash
# Install dependencies
flutter pub get

# Run all integration tests
flutter test integration_test

# Run a specific test file
flutter test integration_test/app_test.dart
flutter test integration_test/movie_detail_test.dart
flutter test integration_test/person_detail_test.dart

# Run on a specific device
flutter test integration_test --device-id=<device_id>

# List available devices
flutter devices
```

### Advanced Commands

```bash
# Run with test driver for detailed performance reports
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart

# Run in profile mode
flutter test integration_test --profile

# Run with verbose output
flutter test integration_test --verbose
```

## Test Architecture

### Test Structure

Each integration test follows this pattern:

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Test Group Name', () {
    setUp(() async {
      // Reset service locator before each test
      await resetServiceLocator();
    });

    testWidgets('Test description', (WidgetTester tester) async {
      // 1. Start the app
      app.main();
      await tester.pumpAndSettle();

      // 2. Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 3. Perform actions and verify results
      expect(find.byType(Widget), findsWidgets);
      
      // 4. Interact with UI
      await tester.tap(find.byType(Button));
      await tester.pumpAndSettle();
      
      // 5. Verify new state
      expect(find.text('Expected Text'), findsOneWidget);
    });
  });
}
```

### Key Testing Patterns

#### 1. Pump and Settle
```dart
// Wait for all animations and async operations
await tester.pumpAndSettle();

// Wait with a timeout
await tester.pumpAndSettle(const Duration(seconds: 5));
```

#### 2. Finding Widgets
```dart
// By type
find.byType(ListView)

// By text
find.text('Button Label')

// By icon
find.byIcon(Icons.favorite)

// By key (requires adding keys to widgets)
find.byKey(Key('unique_key'))
```

#### 3. Interacting with Widgets
```dart
// Tap
await tester.tap(find.byType(Button));

// Drag (for scrolling or pull-to-refresh)
await tester.drag(find.byType(ListView), const Offset(0, -500));

// Enter text
await tester.enterText(find.byType(TextField), 'test');
```

#### 4. Assertions
```dart
// Widget exists
expect(find.byType(Widget), findsOneWidget);
expect(find.byType(Widget), findsWidgets);
expect(find.byType(Widget), findsNothing);

// Custom conditions
expect(condition, isTrue);
expect(condition, isFalse);
```

## Common Issues and Solutions

### 1. "Type Already Registered" Error

**Problem:** GetIt throws error when running multiple tests.

**Solution:** Use `resetServiceLocator()` in `setUp()`:
```dart
setUp(() async {
  await resetServiceLocator();
});
```

### 2. Test Timeout

**Problem:** Test takes too long and times out.

**Solution:** 
- Increase timeout in `pumpAndSettle()`
- Check network connectivity
- Verify API is responding

### 3. Widget Not Found

**Problem:** `expect(find.byType(Widget), findsOneWidget)` fails.

**Solution:**
- Add more `pumpAndSettle()` calls to wait for async operations
- Check if widget is conditionally rendered
- Use `if (widget.evaluate().isNotEmpty)` for optional widgets

### 4. Flaky Tests

**Problem:** Tests pass sometimes but fail other times.

**Solution:**
- Add appropriate waits for async operations
- Use `pumpAndSettle()` after interactions
- Check for race conditions
- Make tests independent of each other

### 5. MissingPluginException

**Problem:** Platform channels throw exceptions in tests.

**Solution:** This is expected for method/event channels in test mode. The app should handle these gracefully, or you can mock the channels.

## Best Practices

### 1. Test Independence
- Each test should be completely independent
- Use `setUp()` to reset state before each test
- Don't rely on test execution order

### 2. Realistic User Flows
- Test actual user journeys, not implementation details
- Focus on what users do, not how the code works
- Test happy paths and error scenarios

### 3. Maintainability
- Use descriptive test names
- Group related tests
- Keep tests simple and focused
- Add comments for complex interactions

### 4. Performance
- Don't make tests unnecessarily slow
- Use appropriate timeouts
- Run tests in parallel when possible (for CI/CD)

### 5. Coverage
- Test critical user flows
- Test error handling
- Test edge cases (empty states, network errors, etc.)
- Don't aim for 100% coverage in integration tests

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  integration-test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Start iOS Simulator
        run: |
          xcrun simctl boot "iPhone 14"
      
      - name: Run integration tests
        run: flutter test integration_test
```

### Firebase Test Lab Example

```bash
# Build app bundle
flutter build apk --debug

# Run on Firebase Test Lab
gcloud firebase test android run \
  --type instrumentation \
  --app build/app/outputs/apk/debug/app-debug.apk \
  --test build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk
```

## Debugging Integration Tests

### 1. Visual Debugging
```dart
// Take screenshot during test
await tester.takeScreenshot('screenshot_name');

// Print widget tree
debugPrintWidgetTree(tester);
```

### 2. Verbose Logging
```bash
# Run with verbose output
flutter test integration_test --verbose

# Enable detailed logging
flutter test integration_test -v
```

### 3. Run Single Test
```bash
# Run only one test by name
flutter test integration_test/app_test.dart \
  --plain-name 'Complete user flow'
```

## Performance Testing

Integration tests can also measure performance:

```dart
testWidgets('Performance test', (WidgetTester tester) async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  // Record performance
  await binding.traceAction(() async {
    app.main();
    await tester.pumpAndSettle();
    
    // Perform actions to measure
  });
  
  // Get performance summary
  final summary = binding.reportData;
  print('Performance: $summary');
});
```

## Next Steps

1. **Expand Test Coverage**: Add more tests for edge cases and error scenarios
2. **Add Screenshot Tests**: Use `flutter_test` screenshots for visual regression testing
3. **Set Up CI/CD**: Automate integration test runs on every commit
4. **Performance Monitoring**: Track app performance metrics over time
5. **Mock APIs**: Consider mocking APIs for more reliable tests
6. **Add Keys**: Add test keys to widgets for easier finding in tests

## Resources

- [Flutter Integration Testing Documentation](https://docs.flutter.dev/testing/integration-tests)
- [Integration Test Package](https://pub.dev/packages/integration_test)
- [Flutter Testing Best Practices](https://docs.flutter.dev/testing/best-practices)
- [WidgetTester API](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html)

## Troubleshooting Checklist

- [ ] Dependencies installed (`flutter pub get`)
- [ ] Service locator reset in `setUp()`
- [ ] Appropriate timeouts for API calls
- [ ] Device/emulator running and connected
- [ ] Network connectivity available
- [ ] API credentials valid
- [ ] Tests are independent
- [ ] Proper waits after interactions (`pumpAndSettle()`)

## Support

For issues or questions about integration testing:
1. Check this guide first
2. Review the test code comments
3. Check Flutter documentation
4. Review test execution logs for specific errors
