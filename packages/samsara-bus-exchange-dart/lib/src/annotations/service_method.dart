/// Annotation for service methods that handle Exchange requests

/// Annotation for service methods that handle Exchange requests
class ServiceMethod {
  /// Optional operation name (defaults to method name)
  final String? operation;

  const ServiceMethod({
    this.operation,
  });
}
