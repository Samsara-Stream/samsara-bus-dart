import 'combiner.dart';
import 'parameter_definition.dart';
import 'processor_definition.dart';
import 'topic_definition.dart';
import 'topology_instance.dart';
import 'ui_stream_definition.dart';

/// Type validator for parameter definitions.
class TypeValidator {
  const TypeValidator();

  /// Validates string type.
  bool Function(dynamic) string() => (value) => value is String;

  /// Validates number type.
  bool Function(dynamic) number() => (value) => value is num;

  /// Validates boolean type.
  bool Function(dynamic) boolean() => (value) => value is bool;

  /// Validates object type.
  bool Function(dynamic) object<T extends Object>() => (value) => value is T;

  /// Validates list type.
  bool Function(dynamic) array<T>() => (value) => value is List<T>;
}

/// Builder interface for creating topologies.
abstract class TopologyBuilder {
  /// Adds a parameter definition to the topology.
  TopologyBuilder param<T>(
      String name, bool Function(dynamic) Function(TypeValidator) validator);

  /// Adds a topic definition to the topology.
  TopologyBuilder topic<T>(String name, String topicName);

  /// Adds a UI stream definition to the topology.
  TopologyBuilder uiStream<T>(String name);

  /// Adds a processor definition to the topology.
  TopologyBuilder proc(ProcessorDefinition processor);

  /// Sets the output node for the topology.
  TopologyBuilder output(String nodeId);

  /// Builds the topology instance.
  TopologyInstance build();
}

/// Implementation of the topology builder.
class TopologyBuilderImpl implements TopologyBuilder {
  final String _topologyName;
  final Map<String, ParameterDefinition> _params;
  final Map<String, TopicDefinition> _topics;
  final Map<String, UIStreamDefinition> _uiStreams;
  final Map<String, ProcessorDefinition> _processors;
  final String? _outputNode;

  const TopologyBuilderImpl(
    this._topologyName, [
    this._params = const {},
    this._topics = const {},
    this._uiStreams = const {},
    this._processors = const {},
    this._outputNode,
  ]);

  @override
  TopologyBuilder param<T>(
      String name, bool Function(dynamic) Function(TypeValidator) validator) {
    final typeValidator = const TypeValidator();
    final validatorFn = validator(typeValidator);

    return TopologyBuilderImpl(
      _topologyName,
      {
        ..._params,
        name: ParameterDefinition(name: name, validator: validatorFn)
      },
      _topics,
      _uiStreams,
      _processors,
      _outputNode,
    );
  }

  @override
  TopologyBuilder topic<T>(String name, String topicName) {
    return TopologyBuilderImpl(
      _topologyName,
      _params,
      {..._topics, name: TopicDefinition<T>(name: name, topicName: topicName)},
      _uiStreams,
      _processors,
      _outputNode,
    );
  }

  @override
  TopologyBuilder uiStream<T>(String name) {
    return TopologyBuilderImpl(
      _topologyName,
      _params,
      _topics,
      {..._uiStreams, name: UIStreamDefinition<T>(name: name)},
      _processors,
      _outputNode,
    );
  }

  @override
  TopologyBuilder proc(ProcessorDefinition processor) {
    return TopologyBuilderImpl(
      _topologyName,
      _params,
      _topics,
      _uiStreams,
      {..._processors, processor.id: processor},
      _outputNode,
    );
  }

  @override
  TopologyBuilder output(String nodeId) {
    return TopologyBuilderImpl(
      _topologyName,
      _params,
      _topics,
      _uiStreams,
      _processors,
      nodeId,
    );
  }

  @override
  TopologyInstance build() {
    if (_outputNode == null) {
      throw StateError(
          'Output node must be specified before building topology');
    }

    return TopologyInstance(
      name: _topologyName,
      paramTypes: _params,
      topics: _topics,
      uiStreams: _uiStreams,
      processors: _processors,
      outputNode: _outputNode!,
    );
  }
}

/// Creates a new topology builder with the given name.
TopologyBuilder topology(String name) => TopologyBuilderImpl(name);

/// Helper for creating processor definitions.
ProcessorDefinition<TOutput> processor<TOutput>({
  required String id,
  required List<String> inputs,
  required dynamic Function(List<dynamic>) fn,
  TopologyCombiner? combiner,
}) {
  return ProcessorDefinition<TOutput>(
    id: id,
    inputs: inputs,
    fn: fn,
    combiner: combiner,
  );
}
