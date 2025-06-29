# Test Configuration for SamsaraBus Generator

This directory contains comprehensive unit tests for the SamsaraBus code generator.

## Test Structure

- `builder_test.dart` - Tests for the main builder configuration
- `exchange/` - Tests for exchange-specific generators
  - `exchange_client_generator_test.dart` - Client generator tests
  - `exchange_service_generator_test.dart` - Service generator tests
- `integration_test.dart` - End-to-end integration tests
- `utils_test.dart` - Utility function tests
- `fixtures/` - Sample input files for testing
- `all_tests.dart` - Main test runner

## Running Tests

Run all tests:
```bash
dart test
```

Run specific test files:
```bash
dart test test/builder_test.dart
dart test test/exchange/exchange_client_generator_test.dart
dart test test/integration_test.dart
```

Run with coverage:
```bash
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
```

## Test Categories

### Unit Tests
- Individual generator functionality
- Utility method behavior
- Error handling and edge cases

### Integration Tests
- Client + Service generation together
- Complex type handling
- Real-world scenarios

### Builder Tests
- Builder configuration
- Build system integration
- Option handling

## Coverage Goals

- Line coverage: > 90%
- Branch coverage: > 85%
- Function coverage: > 95%

## Adding New Tests

When adding new functionality to the generators:

1. Add unit tests for new methods/classes
2. Add integration tests for new features
3. Update fixtures if needed
4. Ensure test coverage remains high
5. Document any new test patterns or utilities
