import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'models/message_envelope.dart';

/// Types of subjects that can be used for topics
enum TopicType {
  /// Basic publish/subscribe behavior
  publishSubject,

  /// Caches the latest event and replays it to new subscribers
  behaviorSubject,

  /// Caches multiple events and replays them to new subscribers
  replaySubject,
}

/// A topic in the message bus.
///
/// A topic represents a stream of messages of a specific type T.
class Topic<T> {
  /// The name of the topic
  final String name;

  /// The subject that backs this topic
  final Subject<MessageEnvelope<T>> _subject;

  /// List of subscriptions to external streams
  final List<StreamSubscription<dynamic>> _externalSubscriptions = [];

  /// Creates a new topic with the given name and subject type.
  Topic(this.name, TopicType type, {int? replayBufferSize})
      : _subject = _createSubject<T>(type, replayBufferSize);

  /// Create the appropriate subject based on the topic type
  static Subject<MessageEnvelope<T>> _createSubject<T>(
      TopicType type, int? replayBufferSize) {
    switch (type) {
      case TopicType.publishSubject:
        return PublishSubject<MessageEnvelope<T>>();
      case TopicType.behaviorSubject:
        return BehaviorSubject<MessageEnvelope<T>>();
      case TopicType.replaySubject:
        return ReplaySubject<MessageEnvelope<T>>(maxSize: replayBufferSize);
    }
  }

  /// Emits a message to this topic.
  ///
  /// Returns the correlation ID used for the message, either the provided one
  /// or a newly generated UUID if none was specified.
  String emit(T message, {String? correlationId}) {
    final actualCorrelationId = correlationId ?? _generateCorrelationId();
    final envelope = MessageEnvelope<T>(
      payload: message,
      correlationId: actualCorrelationId,
    );
    _subject.add(envelope);
    return actualCorrelationId;
  }

  /// Gets the stream of messages for this topic.
  Stream<T> get stream => _subject.stream.map((envelope) => envelope.payload);

  /// Maps this topic's messages to another topic using the provided mapping function.
  void connectTo<R>(Topic<R> destination, R Function(T) mapper) {
    final subscription = _subject.stream.listen((envelope) {
      destination.emit(
        mapper(envelope.payload),
        correlationId: envelope.correlationId,
      );
    });
    _externalSubscriptions.add(subscription);
  }

  /// Injects an external stream into this topic.
  void injectStream<S>(Stream<S> source, T Function(S) mapper,
      {String Function()? correlationIdProvider}) {
    final subscription = source.listen((data) {
      emit(
        mapper(data),
        correlationId: correlationIdProvider != null
            ? correlationIdProvider()
            : _generateCorrelationId(),
      );
    });
    _externalSubscriptions.add(subscription);
  }

  /// Closes the topic and all its subscriptions.
  Future<void> close() async {
    for (final subscription in _externalSubscriptions) {
      await subscription.cancel();
    }
    _externalSubscriptions.clear();
    await _subject.close();
  }

  /// UUID generator for correlation IDs
  static final Uuid _uuid = Uuid();

  /// Generates a new random correlation ID using UUID v4.
  String _generateCorrelationId() {
    return _uuid.v4();
  }
}
