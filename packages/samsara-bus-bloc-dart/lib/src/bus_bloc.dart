import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';

import 'models/bus_event.dart';
import 'models/topology_event.dart';
import 'topology/topology_instance.dart';
import 'topology/processor_definition.dart';
import 'topology/combiner.dart';
import 'topology/ui_stream_definition.dart';

/// Extended Bloc that can handle events from both UI and SamsaraBus topics through topologies.
abstract class BusBloc<Event, State> extends Bloc<Event, State> {
  final SamsaraBus _bus;
  final Map<String, StreamSubscription> _topicSubscriptions = {};
  final Map<String, StreamSubscription> _topologySubscriptions = {};
  final Map<String, Stream<dynamic>> _nodeStreams = {};

  BusBloc(this._bus, super.initialState);

  /// Gets the SamsaraBus instance.
  SamsaraBus get bus => _bus;

  /// Subscribes to a bus topic and converts messages to bloc events.
  void onBusTopic<T>(
    String topicName,
    Event Function(BusMessageEvent<T>) eventMapper,
  ) {
    if (_topicSubscriptions.containsKey(topicName)) {
      throw StateError('Already subscribed to topic: $topicName');
    }

    final stream = _bus.getStream<T>(topicName);
    final subscription = stream.listen((data) {
      final busEvent = BusMessageEvent<T>(
        topicName: topicName,
        correlationId: '', // TODO: Get correlation ID from envelope
        timestamp: DateTime.now(),
        data: data,
      );
      add(eventMapper(busEvent));
    });

    _topicSubscriptions[topicName] = subscription;
  }

  /// Subscribes to a topology and converts results to bloc events.
  void onTopology<T>(
    TopologyInstance topology,
    Map<String, dynamic> parameters,
    Event Function(TopologyResultEvent<T>) eventMapper,
  ) {
    final topologyKey = '${topology.name}_${parameters.hashCode}';

    if (_topologySubscriptions.containsKey(topologyKey)) {
      throw StateError(
          'Already subscribed to topology: ${topology.name} with these parameters');
    }

    try {
      final outputStream = _buildTopologyStream<T>(topology, parameters);
      final subscription = outputStream.listen((data) {
        final topologyEvent = TopologyResultEvent<T>(
          topologyName: topology.name,
          timestamp: DateTime.now(),
          data: data,
        );
        add(eventMapper(topologyEvent));
      });

      _topologySubscriptions[topologyKey] = subscription;
    } catch (e) {
      throw StateError('Failed to build topology ${topology.name}: $e');
    }
  }

  /// Emits a message to a bus topic.
  String emitToBus<T>(String topicName, T message, {String? correlationId}) {
    return _bus.emit(topicName, message, correlationId: correlationId);
  }

  /// Emits a value to a UI stream in a topology.
  void emitToUIStream<T>(
      TopologyInstance topology, String streamName, T value) {
    if (topology.uiStreams.containsKey(streamName)) {
      final uiStream = topology.uiStreams[streamName]! as UIStreamDefinition<T>;
      uiStream.emit(value);
    } else {
      throw ArgumentError(
          'UI stream $streamName not found in topology ${topology.name}');
    }
  }

  /// Builds a stream for the given topology.
  Stream<T> _buildTopologyStream<T>(
      TopologyInstance topology, Map<String, dynamic> parameters) {
    _nodeStreams.clear();

    // Validate parameters
    for (final entry in topology.paramTypes.entries) {
      final paramName = entry.key;
      final paramDef = entry.value;

      if (!parameters.containsKey(paramName)) {
        throw ArgumentError('Missing required parameter: $paramName');
      }

      if (!paramDef.validator(parameters[paramName])) {
        throw ArgumentError('Invalid type for parameter $paramName');
      }
    }

    // Create topic streams
    for (final entry in topology.topics.entries) {
      final nodeName = entry.key;
      final topicDef = entry.value;
      _nodeStreams[nodeName] = _bus.getStream(topicDef.topicName);
    }

    // Create UI streams
    for (final entry in topology.uiStreams.entries) {
      final nodeName = entry.key;
      final uiStreamDef = entry.value;
      _nodeStreams[nodeName] = uiStreamDef.stream;
    }

    // Process processors in dependency order
    final processedNodes = <String>{};
    final processingQueue = topology.processors.keys.toList();

    while (processingQueue.isNotEmpty) {
      final initialSize = processingQueue.length;
      final currentNode = processingQueue.removeAt(0);
      final processor = topology.processors[currentNode]!;

      // Check if all dependencies are available
      final allDepsAvailable = processor.inputs.every((input) =>
          _nodeStreams.containsKey(input) || processedNodes.contains(input));

      if (!allDepsAvailable) {
        // Put back at end of queue
        processingQueue.add(currentNode);

        // Check for circular dependency
        if (processingQueue.length == initialSize) {
          throw StateError(
              'Circular dependency detected in topology ${topology.name}');
        }
        continue;
      }

      // Build the processor stream
      _nodeStreams[currentNode] = _buildProcessorStream(processor, parameters);
      processedNodes.add(currentNode);
    }

    // Return the output stream
    if (!_nodeStreams.containsKey(topology.outputNode)) {
      throw StateError(
          'Output node ${topology.outputNode} not found in topology ${topology.name}');
    }

    return _nodeStreams[topology.outputNode]!.cast<T>();
  }

  /// Builds a stream for a single processor.
  Stream<dynamic> _buildProcessorStream(
      ProcessorDefinition processor, Map<String, dynamic> parameters) {
    final inputStreams = processor.inputs.map((input) {
      if (!_nodeStreams.containsKey(input)) {
        throw StateError('Input stream not found: $input');
      }
      return _nodeStreams[input]!;
    }).toList();

    if (inputStreams.isEmpty) {
      throw ArgumentError('Processor ${processor.id} has no inputs');
    }

    final combiner = processor.combiner ?? TopologyCombiner.combineLatest;
    final combinedStream = combiner.combine(inputStreams);

    return combinedStream
        .map((inputs) => processor.fn(inputs))
        .where((result) => result != skip);
  }

  @override
  Future<void> close() async {
    // Cancel all subscriptions
    for (final subscription in _topicSubscriptions.values) {
      await subscription.cancel();
    }
    for (final subscription in _topologySubscriptions.values) {
      await subscription.cancel();
    }

    _topicSubscriptions.clear();
    _topologySubscriptions.clear();
    _nodeStreams.clear();

    return super.close();
  }
}
