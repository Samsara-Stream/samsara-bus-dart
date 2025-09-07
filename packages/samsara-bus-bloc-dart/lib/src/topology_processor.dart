import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';

import 'topology/topology_instance.dart';
import 'topology/processor_definition.dart';
import 'topology/combiner.dart';

/// A standalone topology processor that can be used independently of BusBloc.
class TopologyProcessor {
  final SamsaraBus _bus;
  final Map<String, Stream<dynamic>> _nodeStreams = {};
  final Map<String, StreamSubscription> _subscriptions = {};

  TopologyProcessor(this._bus);

  /// Processes a topology and returns a stream of results.
  Stream<T> process<T>(
    TopologyInstance topology,
    Map<String, dynamic> parameters,
  ) {
    return _buildTopologyStream<T>(topology, parameters);
  }

  /// Builds a stream for the given topology.
  Stream<T> _buildTopologyStream<T>(
    TopologyInstance topology,
    Map<String, dynamic> parameters,
  ) {
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

  /// Emits a value to a UI stream in a topology.
  void emitToUIStream<T>(
      TopologyInstance topology, String streamName, T value) {
    if (topology.uiStreams.containsKey(streamName)) {
      final uiStream = topology.uiStreams[streamName]!;
      (uiStream as dynamic).emit(value);
    } else {
      throw ArgumentError(
          'UI stream $streamName not found in topology ${topology.name}');
    }
  }

  /// Closes all subscriptions and releases resources.
  Future<void> close() async {
    for (final subscription in _subscriptions.values) {
      await subscription.cancel();
    }

    _subscriptions.clear();
    _nodeStreams.clear();

    // Close UI streams
    for (final topology in _topologies) {
      for (final uiStream in topology.uiStreams.values) {
        uiStream.close();
      }
    }
  }

  final Set<TopologyInstance> _topologies = {};

  /// Registers a topology for cleanup tracking.
  void _registerTopology(TopologyInstance topology) {
    _topologies.add(topology);
  }
}
