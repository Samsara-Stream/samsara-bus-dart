import 'dart:async';
import 'topic.dart';
import 'samsara_bus.dart';
import 'default_samsara_bus.dart';

/// A global singleton implementation of SamsaraBus that delegates all calls
/// to an internal DefaultSamsaraBus instance.
class GlobalSamsaraBus implements SamsaraBus {
  /// Singleton instance
  static final GlobalSamsaraBus _instance = GlobalSamsaraBus._internal();

  /// Internal implementation that handles the actual work
  final DefaultSamsaraBus _implementation = DefaultSamsaraBus();

  /// Private constructor for singleton
  GlobalSamsaraBus._internal();

  /// Factory constructor to return the singleton instance
  factory GlobalSamsaraBus() => _instance;

  /// Registers a new topic with the specified name, data type, and topic type.
  @override
  Topic<T> registerTopic<T>(String name, TopicType type,
          {int? replayBufferSize}) =>
      _implementation.registerTopic<T>(name, type,
          replayBufferSize: replayBufferSize);

  /// Gets an existing topic by name, ensuring it has the expected type.
  @override
  Topic<T> getTopic<T>(String name) => _implementation.getTopic<T>(name);

  /// Emits a message to the specified topic.
  ///
  /// Returns the correlation ID used for the message, either the provided one
  /// or a newly generated UUID if none was specified.
  @override
  String emit<T>(String topicName, T message, {String? correlationId}) =>
      _implementation.emit<T>(topicName, message, correlationId: correlationId);

  /// Gets the stream of messages for the specified topic.
  @override
  Stream<T> getStream<T>(String topicName) =>
      _implementation.getStream<T>(topicName);

  /// Connects two topics, mapping messages from the source to the destination.
  @override
  void connectTopics<S, D>(
          String sourceTopic, String destinationTopic, D Function(S) mapper) =>
      _implementation.connectTopics<S, D>(
          sourceTopic, destinationTopic, mapper);

  /// Injects an external stream into a topic.
  @override
  void injectStream<S, T>(
    String topicName,
    Stream<S> source,
    T Function(S) mapper, {
    String Function()? correlationIdProvider,
  }) =>
      _implementation.injectStream<S, T>(
        topicName,
        source,
        mapper,
        correlationIdProvider: correlationIdProvider,
      );

  /// Closes all topics and releases resources.
  @override
  Future<void> close() => _implementation.close();
}
