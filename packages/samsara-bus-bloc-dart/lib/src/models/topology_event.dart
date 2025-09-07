/// Base class for events that are produced by topology processing.
abstract class TopologyEvent {
  /// The name of the topology that produced this event.
  final String topologyName;

  /// The timestamp when the event was processed.
  final DateTime timestamp;

  const TopologyEvent({
    required this.topologyName,
    required this.timestamp,
  });
}

/// A concrete topology event containing the processed result.
class TopologyResultEvent<T> extends TopologyEvent {
  /// The processed result data.
  final T data;

  const TopologyResultEvent({
    required super.topologyName,
    required super.timestamp,
    required this.data,
  });

  @override
  String toString() =>
      'TopologyResultEvent(topologyName: $topologyName, data: $data)';
}
