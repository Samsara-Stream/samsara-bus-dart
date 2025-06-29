// Test imports
import 'dart:async';
import 'package:test/test.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';

// Mock implementations for testing
class MockSamsaraBus implements SamsaraBus {
  final Map<String, StreamController<dynamic>> _controllers = {};
  final List<EmitCall> emittedMessages = [];

  @override
  String emit<T>(String topicName, T message, {String? correlationId}) {
    final id = correlationId ?? 'mock-correlation-id';
    emittedMessages.add(EmitCall(topicName, message));
    final controller = _controllers[topicName];
    if (controller != null) {
      controller.add(message);
    }
    return id;
  }

  @override
  Stream<T> getStream<T>(String topicName) {
    _controllers[topicName] ??= StreamController<T>.broadcast();
    return _controllers[topicName]!.stream.cast<T>();
  }

  @override
  Topic<T> registerTopic<T>(String name, TopicType type,
      {int? replayBufferSize}) {
    throw UnimplementedError('Mock does not implement registerTopic');
  }

  @override
  Topic<T> getTopic<T>(String name) {
    throw UnimplementedError('Mock does not implement getTopic');
  }

  @override
  void connectTopics<S, D>(
      String sourceTopic, String destinationTopic, D Function(S) mapper) {
    throw UnimplementedError('Mock does not implement connectTopics');
  }

  @override
  void injectStream<S, T>(
      String topicName, Stream<S> source, T Function(S) mapper,
      {String Function()? correlationIdProvider}) {
    throw UnimplementedError('Mock does not implement injectStream');
  }

  @override
  Future<void> close() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
  }

  void simulateMessage<T>(String topic, T message) {
    final controller = _controllers[topic];
    if (controller != null) {
      controller.add(message);
    }
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}

class EmitCall {
  final String topic;
  final dynamic data;
  EmitCall(this.topic, this.data);
}

class TestExchangeClient extends ExchangeClientBase {
  TestExchangeClient(SamsaraBus bus, String requestTopic, String responseTopic,
      {Duration? defaultTimeout})
      : super(bus, requestTopic, responseTopic, defaultTimeout: defaultTimeout);

  Future<String> testOperation(String input) {
    return makeRequest<String>('testOperation', {'input': input});
  }

  Future<int> timeoutOperation() {
    return makeRequest<int>('timeoutOperation', {},
        timeout: Duration(milliseconds: 100));
  }
}

class TestExchangeService extends ExchangeServiceBase {
  final Map<String, Function> _handlers = {};

  TestExchangeService(SamsaraBus bus, String requestTopic, String responseTopic)
      : super(bus, requestTopic, responseTopic);

  void registerHandler(String operation, Function handler) {
    _handlers[operation] = handler;
  }

  @override
  Future<dynamic> handleOperation(
      String operation, Map<String, dynamic> params) async {
    final handler = _handlers[operation];
    if (handler != null) {
      return await handler(params);
    }
    throw Exception('Unknown operation: $operation');
  }
}

void main() {
  group('ExchangeClientBase', () {
    late MockSamsaraBus mockBus;
    late TestExchangeClient client;

    setUp(() {
      mockBus = MockSamsaraBus();
      client = TestExchangeClient(mockBus, 'request-topic', 'response-topic',
          defaultTimeout: Duration(milliseconds: 100));
    });

    tearDown(() {
      client.dispose();
      mockBus.dispose();
    });

    test('makeRequest sends correct request format', () async {
      // Start the request but don't await it
      final resultFuture = client.testOperation('test input');

      // Give some time for the request to be emitted
      await Future.delayed(Duration(milliseconds: 10));

      expect(mockBus.emittedMessages, hasLength(1));
      final emitted = mockBus.emittedMessages.first;
      expect(emitted.topic, equals('request-topic'));

      final request = emitted.data as Map<String, dynamic>;
      expect(request['operation'], equals('testOperation'));
      expect(request['params'], equals({'input': 'test input'}));
      expect(request['correlationId'], isA<String>());

      // Send a response to complete the request properly
      final correlationId = request['correlationId'];
      mockBus.simulateMessage<Map<String, dynamic>>('response-topic', {
        'correlationId': correlationId,
        'operation': 'testOperation',
        'result': 'test response',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Wait for the request to complete
      await resultFuture;
    });

    test('makeRequest completes with response', () async {
      final resultFuture = client.testOperation('test input');

      // Wait for request to be sent
      await Future.delayed(Duration(milliseconds: 10));

      final request =
          mockBus.emittedMessages.first.data as Map<String, dynamic>;
      final correlationId = request['correlationId'];

      // Simulate response
      mockBus.simulateMessage<Map<String, dynamic>>('response-topic', {
        'correlationId': correlationId,
        'operation': 'testOperation',
        'result': 'test response',
        'timestamp': DateTime.now().toIso8601String(),
      });

      final result = await resultFuture;
      expect(result, equals('test response'));
    });

    test('makeRequest handles error response', () async {
      final resultFuture = client.testOperation('test input');

      // Wait for request to be sent
      await Future.delayed(Duration(milliseconds: 10));

      final request =
          mockBus.emittedMessages.first.data as Map<String, dynamic>;
      final correlationId = request['correlationId'];

      // Simulate error response
      mockBus.simulateMessage<Map<String, dynamic>>('response-topic', {
        'correlationId': correlationId,
        'operation': 'testOperation',
        'error': 'Something went wrong',
        'timestamp': DateTime.now().toIso8601String(),
      });

      expect(resultFuture, throwsA(isA<Exception>()));
    });

    test('makeRequest times out when no response', () async {
      final resultFuture = client.timeoutOperation();

      expect(
          resultFuture, throwsA(equals('Request timed out: timeoutOperation')));
    });

    test('makeRequest uses custom timeout when provided', () async {
      final stopwatch = Stopwatch()..start();

      try {
        await client.makeRequest<String>('customTimeout', {},
            timeout: Duration(milliseconds: 50));
      } catch (e) {
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds,
            lessThan(200)); // Should timeout quickly
        expect(e, equals('Request timed out: customTimeout'));
      }
    });

    test('makeRequest uses default timeout when not provided', () async {
      final clientWithTimeout = TestExchangeClient(
          mockBus, 'request-topic', 'response-topic',
          defaultTimeout: Duration(milliseconds: 100));

      try {
        final stopwatch = Stopwatch()..start();
        await clientWithTimeout.testOperation('test');
        stopwatch.stop();
      } catch (e) {
        expect(e, equals('Request timed out: testOperation'));
      } finally {
        clientWithTimeout.dispose();
      }
    });

    test('dispose cancels pending requests', () async {
      final resultFuture = client.testOperation('test input');

      // Dispose before response
      client.dispose();

      expect(resultFuture, throwsA(equals('Client disposed')));
    });

    test('ignores responses with missing correlation ID', () async {
      final resultFuture = client.testOperation('test input');

      // Wait for request to be sent
      await Future.delayed(Duration(milliseconds: 10));

      // Simulate response without correlation ID
      mockBus.simulateMessage<Map<String, dynamic>>('response-topic', {
        'operation': 'testOperation',
        'result': 'test response',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Request should still be pending (will timeout)
      expect(resultFuture, throwsA(equals('Request timed out: testOperation')));
    });

    test('ignores responses with unknown correlation ID', () async {
      final resultFuture = client.testOperation('test input');

      // Wait for request to be sent
      await Future.delayed(Duration(milliseconds: 10));

      // Simulate response with wrong correlation ID
      mockBus.simulateMessage<Map<String, dynamic>>('response-topic', {
        'correlationId': 'unknown-id',
        'operation': 'testOperation',
        'result': 'test response',
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Request should still be pending (will timeout)
      expect(resultFuture, throwsA(equals('Request timed out: testOperation')));
    });
  });

  group('ExchangeServiceBase', () {
    late MockSamsaraBus mockBus;
    late TestExchangeService service;

    setUp(() {
      mockBus = MockSamsaraBus();
      service = TestExchangeService(mockBus, 'request-topic', 'response-topic');
    });

    tearDown(() async {
      await service.stop();
      mockBus.dispose();
    });

    test('start begins listening for requests', () async {
      await service.start();

      service.registerHandler('testOp', (params) => 'success');

      // Simulate incoming request
      mockBus.simulateMessage<Map<String, dynamic>>('request-topic', {
        'operation': 'testOp',
        'params': {'input': 'test'},
        'correlationId': 'test-correlation-id',
      });

      // Wait for processing
      await Future.delayed(Duration(milliseconds: 10));

      expect(mockBus.emittedMessages, hasLength(1));
      final response =
          mockBus.emittedMessages.first.data as Map<String, dynamic>;
      expect(response['correlationId'], equals('test-correlation-id'));
      expect(response['operation'], equals('testOp'));
      expect(response['result'], equals('success'));
      expect(response['timestamp'], isA<String>());
    });

    test('handles operation errors gracefully', () async {
      await service.start();

      service.registerHandler(
          'errorOp', (params) => throw Exception('Handler error'));

      // Simulate incoming request
      mockBus.simulateMessage<Map<String, dynamic>>('request-topic', {
        'operation': 'errorOp',
        'params': {},
        'correlationId': 'error-correlation-id',
      });

      // Wait for processing
      await Future.delayed(Duration(milliseconds: 10));

      expect(mockBus.emittedMessages, hasLength(1));
      final response =
          mockBus.emittedMessages.first.data as Map<String, dynamic>;
      expect(response['correlationId'], equals('error-correlation-id'));
      expect(response['operation'], equals('errorOp'));
      expect(response['error'], contains('Handler error'));
      expect(response['timestamp'], isA<String>());
    });

    test('ignores malformed requests', () async {
      await service.start();

      service.registerHandler('testOp', (params) => 'success');

      // Simulate malformed requests
      mockBus.simulateMessage<Map<String, dynamic>>('request-topic', {
        'params': {'input': 'test'},
        'correlationId': 'test-correlation-id',
        // Missing operation
      });

      mockBus.simulateMessage<Map<String, dynamic>>('request-topic', {
        'operation': 'testOp',
        'correlationId': 'test-correlation-id',
        // Missing params
      });

      mockBus.simulateMessage<Map<String, dynamic>>('request-topic', {
        'operation': 'testOp',
        'params': {'input': 'test'},
        // Missing correlationId
      });

      // Wait for processing
      await Future.delayed(Duration(milliseconds: 10));

      // No responses should be sent for malformed requests
      expect(mockBus.emittedMessages, isEmpty);
    });

    test('handles unknown operations', () async {
      await service.start();

      // Don't register any handlers

      // Simulate incoming request for unknown operation
      mockBus.simulateMessage<Map<String, dynamic>>('request-topic', {
        'operation': 'unknownOp',
        'params': {},
        'correlationId': 'unknown-correlation-id',
      });

      // Wait for processing
      await Future.delayed(Duration(milliseconds: 10));

      expect(mockBus.emittedMessages, hasLength(1));
      final response =
          mockBus.emittedMessages.first.data as Map<String, dynamic>;
      expect(response['correlationId'], equals('unknown-correlation-id'));
      expect(response['operation'], equals('unknownOp'));
      expect(response['error'], contains('Unknown operation: unknownOp'));
    });

    test('handles async operations', () async {
      await service.start();

      service.registerHandler('asyncOp', (params) async {
        await Future.delayed(Duration(milliseconds: 50));
        return 'async result';
      });

      // Simulate incoming request
      mockBus.simulateMessage<Map<String, dynamic>>('request-topic', {
        'operation': 'asyncOp',
        'params': {},
        'correlationId': 'async-correlation-id',
      });

      // Wait for processing
      await Future.delayed(Duration(milliseconds: 100));

      expect(mockBus.emittedMessages, hasLength(1));
      final response =
          mockBus.emittedMessages.first.data as Map<String, dynamic>;
      expect(response['correlationId'], equals('async-correlation-id'));
      expect(response['result'], equals('async result'));
    });
  });
}
