/// Annotation for generating an Exchange service that receives requests and sends responses

/// Annotation for generating an Exchange service that receives requests and sends responses
class ExchangeService {
  /// Topic name for receiving requests
  final String requestTopic;

  /// Topic name for sending responses
  final String responseTopic;

  const ExchangeService(
    this.requestTopic,
    this.responseTopic,
  );
}
