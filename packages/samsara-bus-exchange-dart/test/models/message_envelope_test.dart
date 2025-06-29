// Test imports
import 'package:test/test.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

void main() {
  group('MessageEnvelope', () {
    test('creates MessageEnvelope with required parameters', () {
      final envelope = MessageEnvelope<String>(
        payload: 'test message',
        correlationId: 'test-correlation-id',
      );

      expect(envelope.payload, equals('test message'));
      expect(envelope.correlationId, equals('test-correlation-id'));
      expect(envelope.timestamp, isA<DateTime>());
    });

    test('creates MessageEnvelope with custom timestamp', () {
      final customTimestamp = DateTime(2023, 1, 1, 12, 0, 0);
      final envelope = MessageEnvelope<String>(
        payload: 'test message',
        correlationId: 'test-correlation-id',
        timestamp: customTimestamp,
      );

      expect(envelope.payload, equals('test message'));
      expect(envelope.correlationId, equals('test-correlation-id'));
      expect(envelope.timestamp, equals(customTimestamp));
    });

    test('map transforms payload while preserving metadata', () {
      final envelope = MessageEnvelope<String>(
        payload: '42',
        correlationId: 'test-correlation-id',
      );

      final mappedEnvelope = envelope.map<int>((payload) => int.parse(payload));

      expect(mappedEnvelope.payload, equals(42));
      expect(mappedEnvelope.correlationId, equals('test-correlation-id'));
      expect(mappedEnvelope.timestamp, equals(envelope.timestamp));
    });

    test('map can transform to different types', () {
      final envelope = MessageEnvelope<Map<String, dynamic>>(
        payload: {'name': 'John', 'age': 30},
        correlationId: 'user-correlation-id',
      );

      final mappedEnvelope = envelope.map<String>((payload) => payload['name']);

      expect(mappedEnvelope.payload, equals('John'));
      expect(mappedEnvelope.correlationId, equals('user-correlation-id'));
      expect(mappedEnvelope.timestamp, equals(envelope.timestamp));
    });

    test('toString returns readable format', () {
      final envelope = MessageEnvelope<String>(
        payload: 'test',
        correlationId: 'corr-123',
        timestamp: DateTime(2023, 1, 1, 12, 0, 0),
      );

      final result = envelope.toString();

      expect(result, contains('MessageEnvelope'));
      expect(result, contains('correlationId: corr-123'));
      expect(result, contains('payload: test'));
      expect(result, contains('timestamp: 2023-01-01 12:00:00.000'));
    });

    test('works with complex payload types', () {
      final complexPayload = {
        'users': ['Alice', 'Bob'],
        'metadata': {'version': 1, 'source': 'api'}
      };

      final envelope = MessageEnvelope<Map<String, dynamic>>(
        payload: complexPayload,
        correlationId: 'complex-correlation-id',
      );

      expect(envelope.payload, equals(complexPayload));
      expect(envelope.correlationId, equals('complex-correlation-id'));
    });

    test('timestamp defaults to current time when not provided', () {
      final before = DateTime.now();
      final envelope = MessageEnvelope<String>(
        payload: 'test',
        correlationId: 'test-id',
      );
      final after = DateTime.now();

      expect(
          envelope.timestamp.isAfter(before) ||
              envelope.timestamp.isAtSameMomentAs(before),
          isTrue);
      expect(
          envelope.timestamp.isBefore(after) ||
              envelope.timestamp.isAtSameMomentAs(after),
          isTrue);
    });
  });
}
