// Test imports
import 'package:test/test.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

void main() {
  group('ExchangeMethod annotation', () {
    test('creates ExchangeMethod with default values', () {
      const method = ExchangeMethod();

      expect(method.operation, isNull);
      expect(method.timeout, isNull);
    });

    test('creates ExchangeMethod with operation name', () {
      const method = ExchangeMethod(operation: 'getUserInfo');

      expect(method.operation, equals('getUserInfo'));
      expect(method.timeout, isNull);
    });

    test('creates ExchangeMethod with timeout', () {
      const timeout = Duration(seconds: 15);
      const method = ExchangeMethod(timeout: timeout);

      expect(method.operation, isNull);
      expect(method.timeout, equals(timeout));
    });

    test('creates ExchangeMethod with both operation and timeout', () {
      const timeout = Duration(seconds: 20);
      const method = ExchangeMethod(
        operation: 'processPayment',
        timeout: timeout,
      );

      expect(method.operation, equals('processPayment'));
      expect(method.timeout, equals(timeout));
    });

    test('ExchangeMethod is const constructible', () {
      const method1 = ExchangeMethod(operation: 'test');
      const method2 = ExchangeMethod(operation: 'test');

      expect(identical(method1, method2), isTrue);
    });
  });
}
