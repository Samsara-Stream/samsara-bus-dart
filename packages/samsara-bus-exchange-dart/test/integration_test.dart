// Integration test to verify the main library export works correctly
import 'package:test/test.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

void main() {
  group('Library Export Integration Test', () {
    test('all annotations are accessible', () {
      // Test that all annotation classes can be instantiated
      const client = ExchangeClient('req', 'resp');
      const service = ExchangeService('req', 'resp');
      const method = ExchangeMethod();
      const serviceMethod = ServiceMethod();

      expect(client, isA<ExchangeClient>());
      expect(service, isA<ExchangeService>());
      expect(method, isA<ExchangeMethod>());
      expect(serviceMethod, isA<ServiceMethod>());
    });

    test('MessageEnvelope is accessible', () {
      final envelope = MessageEnvelope<String>(
        payload: 'test',
        correlationId: 'test-id',
      );

      expect(envelope, isA<MessageEnvelope<String>>());
      expect(envelope.payload, equals('test'));
      expect(envelope.correlationId, equals('test-id'));
    });

    test('base classes are accessible for extension', () {
      // Verify that the abstract base classes are accessible
      // (We can't instantiate them directly, but we can check their types)
      expect(ExchangeClientBase, isA<Type>());
      expect(ExchangeServiceBase, isA<Type>());
    });

    test('library exports maintain type safety', () {
      // Test generic type safety
      final stringEnvelope = MessageEnvelope<String>(
        payload: 'test string',
        correlationId: 'string-id',
      );

      final intEnvelope = MessageEnvelope<int>(
        payload: 42,
        correlationId: 'int-id',
      );

      expect(stringEnvelope.payload, isA<String>());
      expect(intEnvelope.payload, isA<int>());

      // Test map transformation maintains type safety
      final mappedEnvelope = stringEnvelope.map<int>((s) => s.length);
      expect(mappedEnvelope.payload, isA<int>());
      expect(mappedEnvelope.payload, equals(11)); // "test string".length
    });
  });
}
