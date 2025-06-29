// Main test file for samsara-bus-exchange-dart
import 'package:test/test.dart';

// Import all test suites
import 'annotations/exchange_client_test.dart' as exchange_client_tests;
import 'annotations/exchange_service_test.dart' as exchange_service_tests;
import 'annotations/exchange_method_test.dart' as exchange_method_tests;
import 'annotations/service_method_test.dart' as service_method_tests;
import 'models/message_envelope_test.dart' as message_envelope_tests;
import 'exchange/exchange_base_test.dart' as exchange_base_tests;

void main() {
  group('SamsaraBus Exchange Dart Tests', () {
    group('Annotations', () {
      exchange_client_tests.main();
      exchange_service_tests.main();
      exchange_method_tests.main();
      service_method_tests.main();
    });

    group('Models', () {
      message_envelope_tests.main();
    });

    group('Exchange Base Classes', () {
      exchange_base_tests.main();
    });
  });
}
