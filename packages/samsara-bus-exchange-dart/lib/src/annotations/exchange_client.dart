/// Annotation for generating an Exchange client that sends requests and receives responses

/// Annotation for generating an Exchange client that sends requests and receives responses
class ExchangeClient {
  /// Topic name for sending requests
  final String requestTopic;

  /// Topic name for receiving responses
  final String responseTopic;

  /// Default timeout for all requests (can be overridden per method)
  final Duration? defaultTimeout;

  const ExchangeClient(
    this.requestTopic,
    this.responseTopic, {
    this.defaultTimeout,
  });
}
