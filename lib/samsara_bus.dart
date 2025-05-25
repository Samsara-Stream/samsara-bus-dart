/// A multi-topic RxDart-based message/event bus for Dart.
///
/// This library provides a message bus implementation with support for:
/// - Registering topics with specific message types and stream behaviors
/// - Type-safe message emission and consumption
/// - Connecting topics with mapping functions
/// - Injecting external streams into topics
/// - Message correlation across topics
library samsara_bus;

export 'src/samsara_bus.dart' show SamsaraBus;
export 'src/default_samsara_bus.dart' show DefaultSamsaraBus;
export 'src/global_samsara_bus.dart' show GlobalSamsaraBus;
export 'src/topic.dart';
export 'src/models/message_envelope.dart';
