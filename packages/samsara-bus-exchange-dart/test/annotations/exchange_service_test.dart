// Test imports
import 'package:test/test.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

void main() {
  group('ExchangeService annotation', () {
    test('creates ExchangeService with required parameters', () {
      const service = ExchangeService('request-topic', 'response-topic');

      expect(service.requestTopic, equals('request-topic'));
      expect(service.responseTopic, equals('response-topic'));
    });

    test('ExchangeService is const constructible', () {
      const service1 = ExchangeService('topic1', 'topic2');
      const service2 = ExchangeService('topic1', 'topic2');

      expect(identical(service1, service2), isTrue);
    });

    test('ExchangeService accepts different topic names', () {
      const service = ExchangeService('user.requests', 'user.responses');

      expect(service.requestTopic, equals('user.requests'));
      expect(service.responseTopic, equals('user.responses'));
    });
  });
}
