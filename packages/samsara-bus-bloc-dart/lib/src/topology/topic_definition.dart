/// Defines a topic source in a topology.
class TopicDefinition<T> {
  /// The name used to reference this topic within the topology.
  final String name;

  /// The actual topic name in the SamsaraBus.
  final String topicName;

  const TopicDefinition({
    required this.name,
    required this.topicName,
  });
}
