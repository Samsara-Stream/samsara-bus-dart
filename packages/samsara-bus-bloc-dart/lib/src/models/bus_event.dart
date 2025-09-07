/// Base class for events that originate from SamsaraBus topics.
abstract class BusEvent {
  /// The topic name this event originated from.
  final String topicName;

  /// The correlation ID of the message.
  final String correlationId;

  /// The timestamp when the event was received.
  final DateTime timestamp;

  const BusEvent({
    required this.topicName,
    required this.correlationId,
    required this.timestamp,
  });
}

/// A concrete bus event containing the actual message data.
class BusMessageEvent<T> extends BusEvent {
  /// The actual message data.
  final T data;

  const BusMessageEvent({
    required super.topicName,
    required super.correlationId,
    required super.timestamp,
    required this.data,
  });

  @override
  String toString() =>
      'BusMessageEvent(topicName: $topicName, correlationId: $correlationId, data: $data)';
}
