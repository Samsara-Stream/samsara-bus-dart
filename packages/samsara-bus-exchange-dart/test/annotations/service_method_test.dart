// Test imports
import 'package:test/test.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

void main() {
  group('ServiceMethod annotation', () {
    test('creates ServiceMethod with default values', () {
      const method = ServiceMethod();

      expect(method.operation, isNull);
    });

    test('creates ServiceMethod with operation name', () {
      const method = ServiceMethod(operation: 'handleUserRequest');

      expect(method.operation, equals('handleUserRequest'));
    });

    test('ServiceMethod is const constructible', () {
      const method1 = ServiceMethod(operation: 'test');
      const method2 = ServiceMethod(operation: 'test');

      expect(identical(method1, method2), isTrue);
    });

    test('ServiceMethod accepts different operation names', () {
      const method1 = ServiceMethod(operation: 'createUser');
      const method2 = ServiceMethod(operation: 'deleteUser');
      const method3 = ServiceMethod(operation: 'updateUser');

      expect(method1.operation, equals('createUser'));
      expect(method2.operation, equals('deleteUser'));
      expect(method3.operation, equals('updateUser'));
    });
  });
}
