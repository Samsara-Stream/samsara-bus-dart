import 'package:test/test.dart';

// Import all test suites
import 'builder_test.dart' as builder_test;
import 'exchange/exchange_client_generator_test.dart' as client_test;
import 'exchange/exchange_service_generator_test.dart' as service_test;
import 'integration_test.dart' as integration_test;
import 'utils_test.dart' as utils_test;

void main() {
  group('SamsaraBus Generator Tests', () {
    group('Builder Tests', builder_test.main);
    group('Exchange Client Generator Tests', client_test.main);
    group('Exchange Service Generator Tests', service_test.main);
    group('Integration Tests', integration_test.main);
    group('Utility Tests', utils_test.main);
  });
}
