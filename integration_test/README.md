# Integration Tests

This directory contains integration tests for the Movie Browse app. Integration tests verify that the app works correctly as a whole, including UI interactions and navigation flows.

## Test Files

- `app_test.dart` - Tests the complete user flow including browsing movies, pull-to-refresh, and scroll-to-load-more
- `movie_detail_test.dart` - Tests movie detail page functionality including viewing details, toggling favorites, and viewing cast
- `person_detail_test.dart` - Tests person detail page functionality including viewing person information and navigation

## Running Integration Tests

### Prerequisites

1. Ensure you have Flutter installed and configured
2. Run `flutter pub get` to install dependencies

### Run all integration tests

```bash
# Run on a connected device or emulator
flutter test integration_test

# Run on a specific device
flutter test integration_test --device-id=<device_id>
```

### Run a specific test file

```bash
# Run only app tests
flutter test integration_test/app_test.dart

# Run only movie detail tests
flutter test integration_test/movie_detail_test.dart

# Run only person detail tests
flutter test integration_test/person_detail_test.dart
```

### Run with test driver (for performance reports)

```bash
# Run with driver for detailed reporting
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

## Test Coverage

The integration tests cover the following user flows:

### App Test (`app_test.dart`)
- ✅ Complete user flow from movie browse to movie detail to cast member
- ✅ Movie list loading and error handling
- ✅ Pull to refresh functionality
- ✅ Scroll to load more movies (pagination)

### Movie Detail Test (`movie_detail_test.dart`)
- ✅ Navigate to movie detail and view information
- ✅ Toggle favorite on movie detail page
- ✅ View cast members on movie detail page
- ✅ Navigate back from movie detail page
- ✅ Error handling and retry functionality

### Person Detail Test (`person_detail_test.dart`)
- ✅ Navigate from movie detail to person detail
- ✅ View person details and biography
- ✅ Navigate back from person detail page
- ✅ Error handling for person detail
- ✅ Display profile photo or placeholder

## Tips for Running Integration Tests

1. **Real Device vs Emulator**: Integration tests run on both real devices and emulators. Real devices provide more accurate results but emulators are more convenient for CI/CD.

2. **Network Dependency**: These tests rely on real API calls to TMDB (The Movie Database). Ensure you have a stable internet connection.

3. **Test Timeouts**: Some tests include timeouts (e.g., `Duration(seconds: 5)`) to wait for API responses. If tests fail due to slow network, you may need to increase these timeouts.

4. **Parallel Execution**: Integration tests should be run sequentially, not in parallel, as they interact with the UI state.

5. **CI/CD Integration**: For CI/CD pipelines, consider using Firebase Test Lab or similar services for automated integration testing across multiple devices.

## Troubleshooting

### Tests timeout or fail
- Check your internet connection
- Ensure the TMDB API is accessible
- Verify the API token in `lib/main.dart` is valid

### Widget not found errors
- The app UI might have changed - update test finders accordingly
- API responses might be empty - verify test data availability

### Tests are flaky
- Increase timeout durations for API calls
- Add more `pumpAndSettle()` calls after interactions
- Check for race conditions in async operations

## Adding New Tests

When adding new integration tests:

1. Follow the existing test structure
2. Use descriptive test names
3. Include proper setup and teardown
4. Add appropriate timeouts for async operations
5. Handle edge cases (empty states, errors, etc.)
6. Update this README with new test coverage

## Best Practices

- Keep tests focused on user flows, not implementation details
- Use `pumpAndSettle()` after interactions to wait for animations
- Add reasonable timeouts for network operations
- Make tests resilient to UI changes where possible
- Test both happy paths and error scenarios
