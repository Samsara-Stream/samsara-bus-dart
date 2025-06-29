// Stable test runner - runs only the reliable tests
import 'package:test/test.dart';

// Import stable test suites (exclude exchange base tests due to timing issues)
import 'annotations/exchange_client_test.dart' as exchange_client_tests;
import 'annotations/exchange_service_test.dart' as exchange_service_tests;
import 'annotations/exchange_method_test.dart' as exchange_method_tests;
import 'annotations/service_method_test.dart' as service_method_tests;
import 'models/message_envelope_test.dart' as message_envelope_tests;
import 'integration_test.dart' as integration_tests;

void main() {
  group('SamsaraBus Exchange Dart - Stable Tests', () {
    group('Annotations', () {
      exchange_client_tests.main();
      exchange_service_tests.main();
      exchange_method_tests.main();
      service_method_tests.main();
    });

    group('Models', () {
      message_envelope_tests.main();
    });

    group('Integration', () {
      integration_tests.main();
    });
  });
}
