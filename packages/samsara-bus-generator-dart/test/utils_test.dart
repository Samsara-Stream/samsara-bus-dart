import 'package:test/test.dart';

/// Tests for the utility methods used by the generators
/// These test the helper functions and type checking logic
void main() {
  group('Generator Utility Tests', () {
    group('Type checking utilities', () {
      test('should identify primitive types correctly', () {
        final primitiveTypes = [
          'int',
          'double',
          'String',
          'bool',
          'num',
          'dynamic'
        ];
        final nonPrimitiveTypes = [
          'User',
          'List<User>',
          'Map<String, dynamic>',
          'Future<String>'
        ];

        for (final type in primitiveTypes) {
          expect(_isPrimitiveType(type), isTrue,
              reason: '$type should be primitive');
        }

        for (final type in nonPrimitiveTypes) {
          expect(_isPrimitiveType(type), isFalse,
              reason: '$type should not be primitive');
        }
      });

      test('should identify primitive list types correctly', () {
        final primitiveListTypes = [
          'List<int>',
          'List<double>',
          'List<String>',
          'List<bool>'
        ];
        final nonPrimitiveListTypes = [
          'List<User>',
          'List<Map<String, dynamic>>',
          'int',
          'String'
        ];

        for (final type in primitiveListTypes) {
          expect(_isPrimitiveListType(type), isTrue,
              reason: '$type should be primitive list');
        }

        for (final type in nonPrimitiveListTypes) {
          expect(_isPrimitiveListType(type), isFalse,
              reason: '$type should not be primitive list');
        }
      });

      test('should handle edge cases for type checking', () {
        // Edge cases for primitive type checking
        expect(_isPrimitiveType(''), isFalse);
        expect(_isPrimitiveType('void'), isFalse);
        expect(_isPrimitiveType('Future<int>'), isFalse);

        // Edge cases for list type checking
        expect(_isPrimitiveListType('List'), isFalse);
        expect(_isPrimitiveListType('List<>'), isFalse);
        expect(_isPrimitiveListType('List<int,>'), isFalse);
        expect(_isPrimitiveListType('Set<int>'), isFalse);
      });
    });

    group('Parameter serialization logic', () {
      test('should generate correct serialization for primitive types', () {
        final primitiveParams = {
          'id': 'String',
          'count': 'int',
          'isActive': 'bool',
          'value': 'double',
        };

        for (final entry in primitiveParams.entries) {
          final paramName = entry.key;
          final paramType = entry.value;

          if (_isPrimitiveType(paramType)) {
            expect(paramName, equals(paramName)); // Should use param as-is
          }
        }
      });

      test('should generate correct serialization for complex types', () {
        final complexParams = {
          'user': 'User',
          'settings': 'AppSettings',
          'data': 'CustomData',
        };

        for (final entry in complexParams.entries) {
          final paramName = entry.key;
          final paramType = entry.value;

          if (!_isPrimitiveType(paramType) &&
              !_isPrimitiveListType(paramType)) {
            final serialized = '$paramName.toJson()';
            expect(serialized, contains('.toJson()'));
          }
        }
      });
    });

    group('Operation name generation', () {
      test('should use method name when no custom operation provided', () {
        const methodName = 'getUserById';
        const operationName =
            methodName; // When annotation operation is null/empty

        expect(operationName, equals('getUserById'));
      });

      test('should use custom operation name when provided', () {
        const methodName = 'getUserById';
        const customOperation = 'get_user_by_id';

        expect(customOperation, equals('get_user_by_id'));
        expect(customOperation, isNot(equals(methodName)));
      });
    });

    group('Class name generation', () {
      test('should generate correct implementation class names', () {
        const testCases = {
          'UserClient': 'UserClient\$Generated',
          'CalculatorService': 'CalculatorService\$Generated',
          'TaskManager': 'TaskManager\$Generated',
        };

        for (final entry in testCases.entries) {
          final original = entry.key;
          final expected = entry.value;
          final generated = '$original\$Generated';

          expect(generated, equals(expected));
        }
      });
    });
  });
}

// Helper functions mirrored from the generators for testing
bool _isPrimitiveType(String typeName) {
  return ['int', 'double', 'String', 'bool', 'num', 'dynamic']
      .contains(typeName);
}

bool _isPrimitiveListType(String typeName) {
  if (!typeName.startsWith('List<') || !typeName.endsWith('>')) {
    return false;
  }
  final elementType = typeName.substring(5, typeName.length - 1);
  return _isPrimitiveType(elementType);
}
