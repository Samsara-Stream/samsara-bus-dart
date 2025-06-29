import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';

import '../lib/chat_client.dart';
import '../lib/chat_service.dart';
import '../lib/chat_service_impl.dart';
import '../lib/models.dart';

void main() async {
  print('Chat Application using SamsaraBus Exchange Pattern');
  print('================================================');

  final bus = DefaultSamsaraBus();

  // Register topics for our chat service
  bus.registerTopic<Map<String, dynamic>>(
      'chat.request', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'chat.response', TopicType.publishSubject);
  bus.registerTopic<ChatMessage>('chat.messages', TopicType.publishSubject);

  // Subscribe to chat messages
  late StreamSubscription chatSubscription;
  chatSubscription =
      bus.getStream<ChatMessage>('chat.messages').listen((message) {
    print('\n[BROADCAST] $message');
  });

  // Create the service implementation
  final serviceImpl = ChatServiceImpl(bus);

  // Start the generated service
  final service = ChatService$Generated(bus, serviceImpl);
  await service.start();

  print('Chat service started successfully');

  // Create a client for our chat service
  final client = ChatClient$Generated(bus);

  try {
    // Demo 1: User registration
    print('\n=== Demo 1: User Registration ===');
    final alice = await client.registerUser('Alice');
    print('Registered: ${alice.username} (ID: ${alice.id})');

    final bob = await client.registerUser('Bob');
    print('Registered: ${bob.username} (ID: ${bob.id})');

    // Demo 2: Send messages
    print('\n=== Demo 2: Chat Session ===');
    await client.sendMessage(SendMessageRequest(
      userId: alice.id,
      content: 'Hello everyone!',
    ));

    await client.sendMessage(SendMessageRequest(
      userId: bob.id,
      content: 'Hi Alice! How are you?',
    ));

    await client.sendMessage(SendMessageRequest(
      userId: alice.id,
      content: 'I\'m doing great! Thanks for asking.',
    ));

    // Demo 3: Get message history
    print('\n=== Demo 3: Message History ===');
    final history = await client.getMessageHistory(10);
    print('Recent messages:');
    for (final message in history) {
      print('  $message');
    }

    // Demo 4: Get active users
    print('\n=== Demo 4: Active Users ===');
    final users = await client.getActiveUsers();
    print('Active users:');
    for (final user in users) {
      print('  ${user.username} (joined: ${user.joinedAt})');
    }

    // Demo 5: Error handling
    print('\n=== Demo 5: Error Handling ===');
    try {
      await client.registerUser('Alice'); // Duplicate username
    } catch (e) {
      print('Caught expected error: $e');
    }

    try {
      await client.sendMessage(SendMessageRequest(
        userId: 'invalid-user-id',
        content: 'This should fail',
      ));
    } catch (e) {
      print('Caught expected error: $e');
    }
  } finally {
    // Clean up
    print('\nShutting down...');
    await chatSubscription.cancel();
    await service.stop();
    client.dispose();
    await bus.close();
    print('Example completed.');
  }
}
