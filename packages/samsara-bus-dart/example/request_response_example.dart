import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:uuid/uuid.dart';

/// Example demonstrating request-response pattern using SamsaraBus and correlation IDs.
void main() async {
  print('Request-Response Pattern Example with Correlation IDs');
  print('===================================================');

  // Create the bus
  final bus = DefaultSamsaraBus();

  // Register topics for both service and client
  bus.registerTopic<Map<String, dynamic>>(
      'math.request', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'math.response', TopicType.publishSubject);

  // Create the service and client
  final mathService = MathService(bus);
  final client = ServiceClient(bus);

  // Start the service
  await mathService.start();

  // Make some requests
  await client.sendRequest('add', {'a': 5, 'b': 3});
  await client.sendRequest('subtract', {'a': 10, 'b': 4});
  await client.sendRequest('multiply', {'a': 7, 'b': 6});

  // Make a request and demonstrate an invalid operation
  await client.sendRequest('divide', {'a': 20, 'b': 0});

  // Wait for all responses to be processed
  await Future.delayed(Duration(milliseconds: 300));

  // Clean up
  await mathService.stop();
  await bus.close();

  print('\nExample completed.');
}

/// A simple math service that processes requests and returns responses
class MathService {
  final SamsaraBus _bus;
  late StreamSubscription _subscription;

  MathService(this._bus);
  Future<void> start() async {
    // Subscribe to requests and process them
    _subscription = _bus
        .getStream<Map<String, dynamic>>('math.request')
        .listen(_handleRequest);

    print('Math service started - Ready to process requests');
    print('------------------------------------------------');
  }

  Future<void> stop() async {
    await _subscription.cancel();
    print('\nMath service stopped');
  }

  void _handleRequest(Map<String, dynamic> request) async {
    final operation = request['operation'] as String?;
    final params = request['params'] as Map<String, dynamic>?;
    final correlationId = request['correlationId'] as String?;

    if (operation == null || params == null || correlationId == null) {
      print('Invalid request format');
      return;
    }

    print(
        'Processing math request: $operation with params: $params (ID: $correlationId)');

    // Simulate some processing time
    await Future.delayed(Duration(milliseconds: 100));

    // Create response with the same correlation ID
    final response = <String, dynamic>{
      'correlationId': correlationId,
      'operation': operation,
      'result': _performOperation(operation, params),
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Send response back
    _bus.emit<Map<String, dynamic>>('math.response', response);
  }

  dynamic _performOperation(String operation, Map<String, dynamic> params) {
    final a = params['a'] as num;
    final b = params['b'] as num;

    try {
      switch (operation) {
        case 'add':
          return a + b;
        case 'subtract':
          return a - b;
        case 'multiply':
          return a * b;
        case 'divide':
          if (b == 0) throw Exception('Division by zero');
          return a / b;
        default:
          return {'error': 'Unknown operation: $operation'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

/// Client that sends requests to the math service and handles responses
class ServiceClient {
  final SamsaraBus _bus;
  late StreamSubscription _subscription;
  final Map<String, Completer<dynamic>> _pendingRequests = {};

  ServiceClient(this._bus) {
    // Subscribe to responses - the topic is already registered by the service
    _subscription = _bus
        .getStream<Map<String, dynamic>>('math.response')
        .listen(_handleResponse);
  }

  Future<dynamic> sendRequest(
      String operation, Map<String, dynamic> params) async {
    // Generate a UUID for the request
    final correlationId = Uuid().v4();

    final request = <String, dynamic>{
      'operation': operation,
      'params': params,
      'correlationId': correlationId
    };

    // Send the request with our generated correlation ID
    _bus.emit<Map<String, dynamic>>('math.request', request);

    print('Client sent $operation request with ID: $correlationId');

    // Create a completer that will be resolved when the response arrives
    final completer = Completer<dynamic>();
    _pendingRequests[correlationId] = completer;

    // Set a timeout for the request
    Timer(Duration(seconds: 5), () {
      if (!completer.isCompleted) {
        completer.completeError('Request timed out: $operation');
        _pendingRequests.remove(correlationId);
      }
    });

    // Wait for the response
    try {
      final result = await completer.future;
      print('Client received response for $operation: $result');
      return result;
    } catch (e) {
      print('Error: $e');
      return {'error': e.toString()};
    }
  }

  void _handleResponse(Map<String, dynamic> response) {
    final correlationId = response['correlationId'] as String?;
    if (correlationId == null) return;

    final completer = _pendingRequests[correlationId];
    if (completer != null) {
      _pendingRequests.remove(correlationId);
      if (!completer.isCompleted) {
        completer.complete(response['result']);
      }
    }
  }

  void dispose() {
    _subscription.cancel();
    for (final completer in _pendingRequests.values) {
      if (!completer.isCompleted) {
        completer.completeError('Client disposed');
      }
    }
    _pendingRequests.clear();
  }
}
