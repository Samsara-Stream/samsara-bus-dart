// Test imports
import 'package:test/test.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

void main() {
  group('ExchangeClient annotation', () {
    test('creates ExchangeClient with required parameters', () {
      const client = ExchangeClient('request-topic', 'response-topic');

      expect(client.requestTopic, equals('request-topic'));
      expect(client.responseTopic, equals('response-topic'));
      expect(client.defaultTimeout, isNull);
    });

    test('creates ExchangeClient with optional timeout', () {
      const timeout = Duration(seconds: 10);
      const client = ExchangeClient(
        'request-topic',
        'response-topic',
        defaultTimeout: timeout,
      );

      expect(client.requestTopic, equals('request-topic'));
      expect(client.responseTopic, equals('response-topic'));
      expect(client.defaultTimeout, equals(timeout));
    });

    test('ExchangeClient is const constructible', () {
      const client1 = ExchangeClient('topic1', 'topic2');
      const client2 = ExchangeClient('topic1', 'topic2');

      expect(identical(client1, client2), isTrue);
    });
  });
}
