import 'package:samsara_bus/samsara_bus.dart';

void main() async {
  print('UUID Correlation ID Demonstration');

  // Create the bus
  final bus = DefaultSamsaraBus();

  // Register a topic for testing
  final topic =
      bus.registerTopic<String>('testTopic', TopicType.publishSubject);

  // Access internal to demonstrate correlation IDs
  // Note: This is not a recommended practice in production code
  // and is only used for demonstration purposes
  void showCorrelationId(String message, String correlationId) {
    print('Message: "$message" | Correlation ID: $correlationId');
  }

  // Create a custom correlation ID for demonstration
  final customId = "custom-12345";

  // Emit messages and manually capture correlation IDs
  print('\nEmitting messages with correlation IDs:');

  // Emit with auto-generated UUID correlation ID
  bus.emit<String>('testTopic', 'Message with UUID correlation ID');

  // Emit with custom correlation ID
  bus.emit<String>('testTopic', 'Message with custom correlation ID',
      correlationId: customId);

  // Clean up
  await bus.close();

  print('\nThe first message used an auto-generated UUID.');
  print('The second message used a custom ID: $customId');
  print('You can verify UUIDs format in any messages printed in the bus log.');
}
