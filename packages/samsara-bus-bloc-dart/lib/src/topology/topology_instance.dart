import 'parameter_definition.dart';
import 'processor_definition.dart';
import 'topic_definition.dart';
import 'ui_stream_definition.dart';

/// Represents a complete topology instance with all its definitions.
class TopologyInstance {
  /// The name of the topology.
  final String name;

  /// Parameter definitions for this topology.
  final Map<String, ParameterDefinition> paramTypes;

  /// Topic definitions for this topology.
  final Map<String, TopicDefinition> topics;

  /// UI stream definitions for this topology.
  final Map<String, UIStreamDefinition> uiStreams;

  /// Processor definitions for this topology.
  final Map<String, ProcessorDefinition> processors;

  /// The output node ID that produces the final events.
  final String outputNode;

  const TopologyInstance({
    required this.name,
    required this.paramTypes,
    required this.topics,
    this.uiStreams = const {},
    required this.processors,
    required this.outputNode,
  });
}
