/// A wrapper class for messages/events emitted through the bus.
///
/// This envelope contains the actual message payload and metadata like
/// a correlation ID to track related messages across different topics.
class MessageEnvelope<T> {
  /// The actual message payload
  final T payload;

  /// Correlation ID used to track related messages across topics
  final String correlationId;

  /// Timestamp when the message was created
  final DateTime timestamp;

  /// Creates a new message envelope with the given payload and correlation ID.
  MessageEnvelope({
    required this.payload,
    required this.correlationId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a new message envelope with the same correlation ID but a new payload.
  MessageEnvelope<R> map<R>(R Function(T) mapper) {
    return MessageEnvelope<R>(
      payload: mapper(payload),
      correlationId: correlationId,
      timestamp: timestamp,
    );
  }

  @override
  String toString() =>
      'MessageEnvelope(correlationId: $correlationId, payload: $payload, timestamp: $timestamp)';
}
