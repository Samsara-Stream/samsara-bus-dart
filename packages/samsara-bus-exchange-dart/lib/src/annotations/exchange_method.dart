/// Annotation for client methods that make Exchange requests

/// Annotation for client methods that make Exchange requests
class ExchangeMethod {
  /// Optional operation name (defaults to method name)
  final String? operation;

  /// Optional timeout override for this specific method
  final Duration? timeout;

  const ExchangeMethod({
    this.operation,
    this.timeout,
  });
}
