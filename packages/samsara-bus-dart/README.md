  # Samsara Bus Dart

A multi-topic RxDart-based message/event bus for Dart.

SamsaraBus is a powerful message bus implementation for Dart applications, built on top of RxDart. It enables decoupled communication between different parts of your application through typed topics, with support for transformation, correlation, and stream injection.

This package is part of the [Samsara Bus Dart monorepo](https://github.com/Samsara-Stream/samsara-bus-dart).

## Features

- **Type-safe Topics:** Register topics with specific message types and stream behaviors
- **Flexible Stream Types:** Choose between PublishSubject, BehaviorSubject, or ReplaySubject for each topic
- **Topic Connections:** Connect topics with transformation functions
- **Stream Injection:** Inject external streams into topics
- **Message Correlation:** Track related messages across different topics
- **Type Enforcement:** Enforces message types at compile-time and runtime
- **Flexible Architecture:** Use `DefaultSamsaraBus` for local scopes or `GlobalSamsaraBus` singleton for application-wide messaging

## Getting Started

Add the package to your pubspec.yaml:

```yaml
dependencies:
  samsara_bus: ^1.0.0
```

## Usage

### Architecture Options

SamsaraBus provides three ways to use the message bus:

1. **SamsaraBus Interface**: The abstract interface that defines all message bus operations
2. **DefaultSamsaraBus**: A concrete implementation for local scope usage
3. **GlobalSamsaraBus**: A singleton implementation for application-wide messaging

Choose the implementation that best fits your use case:

```dart
// For local scope usage
final localBus = DefaultSamsaraBus();

// For application-wide singleton usage
final globalBus = GlobalSamsaraBus(); // Same instance throughout your app
```

### Creating a Bus and Registering Topics

```dart
import 'package:samsara_bus/samsara_bus.dart';

void main() {
  // Create the bus with DefaultSamsaraBus
  final bus = DefaultSamsaraBus();
  
  // Register topics with different types
  bus.registerTopic<String>('stringTopic', TopicType.publishSubject);
  bus.registerTopic<int>('numberTopic', TopicType.behaviorSubject);
  bus.registerTopic<Map<String, dynamic>>('jsonTopic', TopicType.replaySubject, 
      replayBufferSize: 5);
}
```

### Using the Global Singleton

```dart
import 'package:samsara_bus/samsara_bus.dart';

void someFunction() {
  // Get the singleton instance
  final bus = GlobalSamsaraBus();
  
  // Use it as you would a normal bus
  bus.emit<String>('globalTopic', 'This message is available app-wide');
}

void anotherFunction() {
  // Get the same singleton instance
  final bus = GlobalSamsaraBus();
  
  // Listen to messages from anywhere in the app
  bus.getStream<String>('globalTopic').listen((message) {
    print('Received: $message');
  });
}
```

### Subscribing to Topics

```dart
// Subscribe to a topic
final subscription = bus.getStream<String>('stringTopic').listen(
  (message) {
    print('Message: $message');
  },
);

// Don't forget to cancel subscriptions when done
subscription.cancel();
```

### Emitting Messages

```dart
// Emit a message with auto-generated correlation ID
bus.emit<String>('stringTopic', 'Hello, world!');

// Emit a message with custom correlation ID
bus.emit<String>('stringTopic', 'Hello with ID', 
    correlationId: 'custom-id-123');
```

### Connecting Topics

```dart
// Connect topics with a transformation function
bus.connectTopics<String, int>(
  'stringTopic',
  'numberTopic',
  (message) => message.length, // Map string to its length
);

// Now when you emit to stringTopic, it also emits to numberTopic
bus.emit<String>('stringTopic', 'Hello'); // Will emit 5 to numberTopic
```

### Injecting External Streams

```dart
import 'dart:async';

// Create an external stream
final controller = StreamController<DateTime>();

// Inject it into a topic with transformation
bus.injectStream<DateTime, String>(
  'stringTopic',
  controller.stream,
  (datetime) => datetime.toIso8601String(),
);

// Now when you add to the controller, it emits to the topic
controller.add(DateTime.now());
```

### Cleanup

```dart
// Close the bus when done
await bus.close();
```

## Complete Example

See the [example](example/samsara_bus_example.dart) for a complete demonstration of all features.

## Additional Information

SamsaraBus is designed to provide a flexible and type-safe way to implement the publish-subscribe pattern in Dart applications. It is particularly useful for:

- Decoupling components in complex applications
- Event-driven architectures
- Reactive programming patterns
- Cross-component communication
- Message transformation and correlation

For more details about RxDart, see the [RxDart package](https://pub.dev/packages/rxdart).

## Contributing

### Preparation

Make sure you install lefthook and set up the necessary git hooks:

```bash
brew install lefthook
lefthook install
```

These hooks will analyze and check the formatting of your code before committing to the repo.