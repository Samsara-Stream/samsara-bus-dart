import 'dart:async';
import 'topic.dart';
import 'samsara_bus.dart';

/// Default implementation of the SamsaraBus interface.
class DefaultSamsaraBus implements SamsaraBus {
  /// Map of topic name to topic instance
  final Map<String, Topic<dynamic>> _topics = {};

  /// Registers a new topic with the specified name, data type, and topic type.
  @override
  Topic<T> registerTopic<T>(String name, TopicType type,
      {int? replayBufferSize}) {
    if (_topics.containsKey(name)) {
      throw Exception('Topic with name "$name" already exists');
    }

    final topic = Topic<T>(name, type, replayBufferSize: replayBufferSize);
    _topics[name] = topic;
    return topic;
  }

  /// Gets an existing topic by name, ensuring it has the expected type.
  @override
  Topic<T> getTopic<T>(String name) {
    final topic = _topics[name];
    if (topic == null) {
      throw Exception('Topic "$name" does not exist');
    }

    if (topic is Topic<T>) {
      return topic;
    } else {
      throw Exception('Topic "$name" exists but with a different type');
    }
  }

  /// Emits a message to the specified topic.
  ///
  /// Returns the correlation ID used for the message, either the provided one
  /// or a newly generated UUID if none was specified.
  @override
  String emit<T>(String topicName, T message, {String? correlationId}) {
    return getTopic<T>(topicName).emit(message, correlationId: correlationId);
  }

  /// Gets the stream of messages for the specified topic.
  @override
  Stream<T> getStream<T>(String topicName) {
    return getTopic<T>(topicName).stream;
  }

  /// Connects two topics, mapping messages from the source to the destination.
  @override
  void connectTopics<S, D>(
      String sourceTopic, String destinationTopic, D Function(S) mapper) {
    final source = getTopic<S>(sourceTopic);
    final destination = getTopic<D>(destinationTopic);
    source.connectTo(destination, mapper);
  }

  /// Injects an external stream into a topic.
  @override
  void injectStream<S, T>(
    String topicName,
    Stream<S> source,
    T Function(S) mapper, {
    String Function()? correlationIdProvider,
  }) {
    getTopic<T>(topicName).injectStream(
      source,
      mapper,
      correlationIdProvider: correlationIdProvider,
    );
  }

  /// Closes all topics and releases resources.
  @override
  Future<void> close() async {
    final futures = _topics.values.map((topic) => topic.close());
    await Future.wait(futures);
    _topics.clear();
  }
}
