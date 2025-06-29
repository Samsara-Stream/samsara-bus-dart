import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';

void main() async {
  // Example 1: Using DefaultSamsaraBus (for local scope)
  print('=== Example 1: DefaultSamsaraBus ===');
  await usingDefaultBus();

  // Example 2: Using GlobalSamsaraBus (for application-wide singleton)
  print('\n=== Example 2: GlobalSamsaraBus ===');
  await usingGlobalBus();
}

/// Example showing DefaultSamsaraBus for local usage
Future<void> usingDefaultBus() async {
  // Create the bus as a DefaultSamsaraBus implementation
  final bus = DefaultSamsaraBus();

  // Register topics with different types
  bus.registerTopic<String>('stringTopic', TopicType.publishSubject);
  bus.registerTopic<int>('numberTopic', TopicType.behaviorSubject);
  bus.registerTopic<Map<String, dynamic>>('jsonTopic', TopicType.replaySubject,
      replayBufferSize: 5);

  // Subscribe to topics
  final stringSubscription = bus.getStream<String>('stringTopic').listen(
        (message) => print('String message: $message'),
      );

  final numberSubscription = bus.getStream<int>('numberTopic').listen(
        (message) => print('Number message: $message'),
      );

  final jsonSubscription =
      bus.getStream<Map<String, dynamic>>('jsonTopic').listen(
            (message) => print('JSON message: $message'),
          );

  // Emit messages to topics
  bus.emit<String>('stringTopic', 'Hello, world!');
  bus.emit<int>('numberTopic', 42);
  bus.emit<Map<String, dynamic>>('jsonTopic', {'name': 'Alice', 'age': 30});

  // Connect topics with transformation
  bus.connectTopics<String, int>(
    'stringTopic',
    'numberTopic',
    (message) => message.length, // Map string to its length
  );

  // Now when we emit to stringTopic, it will also emit to numberTopic
  final correlationId = DateTime.now().toIso8601String();
  bus.emit<String>('stringTopic', 'This will be converted to length 25',
      correlationId: correlationId);

  // Inject an external stream
  final controller = StreamController<DateTime>();
  bus.injectStream<DateTime, Map<String, dynamic>>(
    'jsonTopic',
    controller.stream,
    (datetime) =>
        {'timestamp': datetime.toIso8601String(), 'type': 'timestamp'},
  );

  // Emit to the external stream
  controller.add(DateTime.now());

  // Wait a bit for all events to be processed
  await Future.delayed(Duration(milliseconds: 500));

  // Clean up
  await controller.close();
  await stringSubscription.cancel();
  await numberSubscription.cancel();
  await jsonSubscription.cancel();
  await bus.close();
}

/// Example showing GlobalSamsaraBus for application-wide singleton usage
Future<void> usingGlobalBus() async {
  // Get the singleton instance - this will be the same across your entire app
  final bus = GlobalSamsaraBus();

  // Another reference to the same bus
  final sameBus = GlobalSamsaraBus();
  print(
      'Is the same instance? ${identical(bus, sameBus)}'); // Should print true

  // Register a couple of topics
  bus.registerTopic<String>('globalTopic', TopicType.publishSubject);
  bus.registerTopic<int>('counterTopic', TopicType.behaviorSubject);

  // Subscribe to them
  final subscription1 = bus.getStream<String>('globalTopic').listen(
        (message) => print('Global message: $message'),
      );

  final subscription2 = bus.getStream<int>('counterTopic').listen(
        (message) => print('Counter value: $message'),
      );

  // Emit some messages
  bus.emit<String>('globalTopic', 'This is a global message');
  bus.emit<int>('counterTopic', 1);

  // Use the second reference to emit messages
  sameBus.emit<String>('globalTopic', 'Still the same bus!');
  sameBus.emit<int>('counterTopic', 2);

  // Wait a bit for all events to be processed
  await Future.delayed(Duration(milliseconds: 500));

  // Clean up
  await subscription1.cancel();
  await subscription2.cancel();
  await bus.close();
}
