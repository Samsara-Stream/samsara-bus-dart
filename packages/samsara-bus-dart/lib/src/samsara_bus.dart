import 'dart:async';
import 'topic.dart';

/// The main message bus interface that manages multiple topics.
abstract class SamsaraBus {
  /// Registers a new topic with the specified name, data type, and topic type.
  Topic<T> registerTopic<T>(String name, TopicType type,
      {int? replayBufferSize});

  /// Gets an existing topic by name, ensuring it has the expected type.
  Topic<T> getTopic<T>(String name);

  /// Emits a message to the specified topic.
  ///
  /// Returns the correlation ID used for the message, either the provided one
  /// or a newly generated UUID if none was specified.
  String emit<T>(String topicName, T message, {String? correlationId});

  /// Gets the stream of messages for the specified topic.
  Stream<T> getStream<T>(String topicName);

  /// Connects two topics, mapping messages from the source to the destination.
  void connectTopics<S, D>(
      String sourceTopic, String destinationTopic, D Function(S) mapper);

  /// Injects an external stream into a topic.
  void injectStream<S, T>(
    String topicName,
    Stream<S> source,
    T Function(S) mapper, {
    String Function()? correlationIdProvider,
  });

  /// Closes all topics and releases resources.
  Future<void> close();
}
