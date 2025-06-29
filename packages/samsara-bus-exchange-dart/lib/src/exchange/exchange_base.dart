import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:uuid/uuid.dart';

/// Base class for generated Exchange clients
abstract class ExchangeClientBase {
  final SamsaraBus _bus;
  final String _requestTopic;
  final String _responseTopic;
  final Duration _defaultTimeout;

  late StreamSubscription _subscription;
  final Map<String, Completer<dynamic>> _pendingRequests = {};
  final _uuid = Uuid();

  ExchangeClientBase(
    this._bus,
    this._requestTopic,
    this._responseTopic, {
    Duration? defaultTimeout,
  }) : _defaultTimeout = defaultTimeout ?? const Duration(seconds: 5) {
    _subscription = _bus
        .getStream<Map<String, dynamic>>(_responseTopic)
        .listen(_handleResponse);
  }

  /// Make a request and wait for response
  Future<T> makeRequest<T>(
    String operation,
    Map<String, dynamic> params, {
    Duration? timeout,
  }) async {
    final correlationId = _uuid.v4();
    final requestTimeout = timeout ?? _defaultTimeout;

    final request = <String, dynamic>{
      'operation': operation,
      'params': params,
      'correlationId': correlationId,
    };

    _bus.emit<Map<String, dynamic>>(_requestTopic, request);

    final completer = Completer<T>();
    _pendingRequests[correlationId] = completer;

    Timer(requestTimeout, () {
      if (!completer.isCompleted) {
        completer.completeError('Request timed out: $operation');
        _pendingRequests.remove(correlationId);
      }
    });

    try {
      return await completer.future;
    } catch (e) {
      rethrow;
    }
  }

  void _handleResponse(Map<String, dynamic> response) {
    final correlationId = response['correlationId'] as String?;
    if (correlationId == null) return;

    final completer = _pendingRequests[correlationId];
    if (completer != null) {
      _pendingRequests.remove(correlationId);
      if (!completer.isCompleted) {
        final result = response['result'];
        final error = response['error'];

        if (error != null) {
          completer.completeError(Exception(error));
        } else {
          completer.complete(result);
        }
      }
    }
  }

  /// Dispose resources
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

/// Base class for generated Exchange services
abstract class ExchangeServiceBase {
  final SamsaraBus _bus;
  final String _requestTopic;
  final String _responseTopic;

  late StreamSubscription _subscription;

  ExchangeServiceBase(
    this._bus,
    this._requestTopic,
    this._responseTopic,
  );

  /// Start the service
  Future<void> start() async {
    _subscription = _bus
        .getStream<Map<String, dynamic>>(_requestTopic)
        .listen(_handleRequest);
  }

  /// Stop the service
  Future<void> stop() async {
    await _subscription.cancel();
  }

  void _handleRequest(Map<String, dynamic> request) async {
    final operation = request['operation'] as String?;
    final paramsValue = request['params'];
    final correlationId = request['correlationId'] as String?;

    if (operation == null || paramsValue == null || correlationId == null) {
      return;
    }

    // Safely convert params to Map<String, dynamic>
    Map<String, dynamic> params;
    if (paramsValue is Map<String, dynamic>) {
      params = paramsValue;
    } else if (paramsValue is Map) {
      params = Map<String, dynamic>.from(paramsValue);
    } else {
      return; // Invalid params format
    }

    try {
      final result = await handleOperation(operation, params);

      final response = <String, dynamic>{
        'correlationId': correlationId,
        'operation': operation,
        'result': result,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _bus.emit<Map<String, dynamic>>(_responseTopic, response);
    } catch (e) {
      final response = <String, dynamic>{
        'correlationId': correlationId,
        'operation': operation,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      _bus.emit<Map<String, dynamic>>(_responseTopic, response);
    }
  }

  /// Override this method in generated classes to handle operations
  Future<dynamic> handleOperation(
      String operation, Map<String, dynamic> params);
}
