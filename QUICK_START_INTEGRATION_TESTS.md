# Quick Start - Integration Tests

## Run Tests

```bash
# Run all integration tests
flutter test integration_test

# Run specific test file
flutter test integration_test/app_test.dart
flutter test integration_test/movie_detail_test.dart
flutter test integration_test/person_detail_test.dart
```

## What Was Added

### Files Created
```
integration_test/
├── app_test.dart              # Main app flow tests
├── movie_detail_test.dart     # Movie detail tests
├── person_detail_test.dart    # Person detail tests
└── README.md                  # Integration test documentation

test_driver/
└── integration_test.dart      # Test driver for device runs

INTEGRATION_TESTING_GUIDE.md   # Comprehensive testing guide
```

### Code Changes
- Added `integration_test` dependency to `pubspec.yaml`
- Added `resetServiceLocator()` function to `lib/core/di/service_locator.dart`

## Test Coverage

### App Tests (`app_test.dart`)
✅ Complete user flow: browse → detail → back
✅ Movie list displays or shows error
✅ Pull to refresh
✅ Scroll through movie list

### Movie Detail Tests (`movie_detail_test.dart`)
✅ Navigate to movie detail
✅ Toggle favorite button
✅ View cast members
✅ Navigate back
✅ Error handling and retry

### Person Detail Tests (`person_detail_test.dart`)
✅ Navigate to person detail
✅ View person information
✅ Navigate back
✅ Error handling
✅ Profile photo or placeholder display

## Common Commands

```bash
# Install dependencies
flutter pub get

# List available devices
flutter devices

# Run on specific device
flutter test integration_test --device-id=<device_id>

# Run with detailed output
flutter test integration_test --verbose

# Run with test driver (performance metrics)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

## Troubleshooting

### Tests fail with "Type already registered"
✅ Already handled! The tests use `resetServiceLocator()` in `setUp()`

### Tests timeout
- Check internet connection
- Verify TMDB API is accessible
- Increase timeout durations in test code

### Widget not found
- Tests include appropriate waits with `pumpAndSettle()`
- Check if the API returned data

## Next Steps

1. Run the tests: `flutter test integration_test`
2. Check the comprehensive guide: `INTEGRATION_TESTING_GUIDE.md`
3. Add more tests as needed
4. Set up CI/CD automation

## Notes

- Tests make real API calls to TMDB
- Requires internet connection
- Tests run on simulator/emulator or real device
- Each test is independent and resets state
