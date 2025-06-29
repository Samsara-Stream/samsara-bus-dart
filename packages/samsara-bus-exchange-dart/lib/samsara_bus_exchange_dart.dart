/// A Dart library for implementing Exchange patterns (request-response) with SamsaraBus
///
/// This library provides annotations and base classes for generating
/// type-safe Exchange clients and services that handle request-response
/// communication patterns over the SamsaraBus message bus.

library samsara_bus_exchange_dart;

// Export annotations for code generation
export 'src/annotations/exchange_annotations.dart';

// Export base classes for Exchange patterns
export 'src/exchange/exchange_base.dart';

// Export models and data structures
export 'src/models/message_envelope.dart';
