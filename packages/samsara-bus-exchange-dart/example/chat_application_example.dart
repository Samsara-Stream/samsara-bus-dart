// A simple chat application using the Exchange Pattern

import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'package:uuid/uuid.dart';

// Main entry point
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

  // Start the chat service
  final chatService = ChatService$Generated(bus);
  await chatService.start();

  print('Chat service started successfully');

  // Subscribe to chat messages
  final chatSubscription =
      bus.getStream<ChatMessage>('chat.messages').listen((message) {
    print(
        '\n[${message.timestamp.hour}:${message.timestamp.minute}:${message.timestamp.second}] ${message.username}: ${message.content}');
  });

  // Create a client for our chat service
  final chatClient = ChatClient$Generated(bus);

  try {
    // User registration
    print('\n=== User Registration ===');
    final user1 = await chatClient.registerUser('Alice');
    print('Registered: ${user1.username} (ID: ${user1.id})');

    final user2 = await chatClient.registerUser('Bob');
    print('Registered: ${user2.username} (ID: ${user2.id})');

    // Send messages
    print('\n=== Chat Session ===');
    await chatClient.sendMessage(user1.id, 'Hello everyone!');
    await Future.delayed(Duration(milliseconds: 500));

    await chatClient.sendMessage(user2.id, 'Hi Alice! How are you?');
    await Future.delayed(Duration(milliseconds: 500));

    await chatClient.sendMessage(user1.id,
        'I\'m doing great! Just testing out this new chat app using SamsaraBus Exchange Pattern.');
    await Future.delayed(Duration(milliseconds: 500));

    await chatClient.sendMessage(user2.id,
        'That\'s cool! The request-response pattern makes it easy to implement features like user registration.');
    await Future.delayed(Duration(milliseconds: 500));

    // Get chat history
    print('\n=== Chat History ===');
    final history = await chatClient.getChatHistory();
    print('Retrieved ${history.length} messages from history');

    // User information
    print('\n=== User Information ===');
    final users = await chatClient.getActiveUsers();
    print('Active users: ${users.map((u) => u.username).join(', ')}');

    // Error handling
    print('\n=== Error Handling ===');
    try {
      await chatClient.sendMessage('invalid-id', 'This should fail');
    } catch (e) {
      print('Caught expected error: $e');
    }
  } finally {
    // Clean up
    print('\nShutting down chat application...');
    await chatSubscription.cancel();
    await chatService.stop();
    chatClient.dispose();
    await bus.close();
    print('Example completed.');
  }
}

// ========== Data Models ==========

/// A chat message
class ChatMessage {
  final String id;
  final String userId;
  final String username;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'username': username,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        userId: json['userId'] as String,
        username: json['username'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

/// A chat user
class ChatUser {
  final String id;
  final String username;
  final DateTime registeredAt;

  ChatUser({
    required this.id,
    required this.username,
    required this.registeredAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'registeredAt': registeredAt.toIso8601String(),
      };

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: json['id'] as String,
        username: json['username'] as String,
        registeredAt: DateTime.parse(json['registeredAt'] as String),
      );
}

// ========== Service and Client Interfaces ==========

/// Chat Service Interface
@ExchangeService('chat.request', 'chat.response')
abstract class ChatService {
  @ServiceMethod()
  ChatUser registerUser(String username);

  @ServiceMethod()
  List<ChatUser> getActiveUsers();

  @ServiceMethod()
  void sendMessage(String userId, String content);

  @ServiceMethod()
  List<ChatMessage> getChatHistory();
}

/// Chat Client Interface
@ExchangeClient('chat.request', 'chat.response')
abstract class ChatClient {
  @ExchangeMethod()
  Future<ChatUser> registerUser(String username);

  @ExchangeMethod()
  Future<List<ChatUser>> getActiveUsers();

  @ExchangeMethod(timeout: Duration(seconds: 10))
  Future<void> sendMessage(String userId, String content);

  @ExchangeMethod()
  Future<List<ChatMessage>> getChatHistory();
}

// ========== Service Implementation ==========

/// Chat service implementation
class ChatServiceImpl implements ChatService {
  final _messages = <ChatMessage>[];
  final _users = <String, ChatUser>{};
  final SamsaraBus _bus;
  final _uuid = Uuid();

  ChatServiceImpl(this._bus);

  @override
  ChatUser registerUser(String username) {
    // In a real app, we would validate uniqueness, etc.
    final user = ChatUser(
      id: _uuid.v4(),
      username: username,
      registeredAt: DateTime.now(),
    );

    _users[user.id] = user;
    return user;
  }

  @override
  List<ChatUser> getActiveUsers() {
    return _users.values.toList();
  }

  @override
  void sendMessage(String userId, String content) {
    if (!_users.containsKey(userId)) {
      throw Exception('User not found: $userId');
    }

    final user = _users[userId]!;
    final message = ChatMessage(
      id: _uuid.v4(),
      userId: userId,
      username: user.username,
      content: content,
      timestamp: DateTime.now(),
    );

    _messages.add(message);

    // Publish the message to subscribers
    _bus.emit<ChatMessage>('chat.messages', message);
  }

  @override
  List<ChatMessage> getChatHistory() {
    // In a real app, we would implement pagination, filtering, etc.
    return _messages;
  }
}

// ========== Generated Service Implementation ==========

class ChatService$Generated implements ChatService {
  final SamsaraBus _bus;
  late StreamSubscription _subscription;
  final ChatService _implementation;

  ChatService$Generated(this._bus) : _implementation = ChatServiceImpl(_bus);

  Future<void> start() async {
    _subscription = _bus
        .getStream<Map<String, dynamic>>('chat.request')
        .listen(_handleRequest);
  }

  Future<void> stop() async {
    await _subscription.cancel();
  }

  Future<void> _handleRequest(Map<String, dynamic> request) async {
    final operation = request['operation'] as String?;
    final params = request['params'] as Map<String, dynamic>?;
    final correlationId = request['correlationId'] as String?;

    if (operation == null || params == null || correlationId == null) {
      return;
    }

    Map<String, dynamic> response;

    try {
      final paramsList = params['params'] as List<dynamic>;
      dynamic result;

      switch (operation) {
        case 'registerUser':
          final username = paramsList[0] as String;
          result = _implementation.registerUser(username).toJson();
          break;
        case 'getActiveUsers':
          result =
              _implementation.getActiveUsers().map((u) => u.toJson()).toList();
          break;
        case 'sendMessage':
          final userId = paramsList[0] as String;
          final content = paramsList[1] as String;
          _implementation.sendMessage(userId, content);
          result = null;
          break;
        case 'getChatHistory':
          result =
              _implementation.getChatHistory().map((m) => m.toJson()).toList();
          break;
        default:
          throw Exception('Unknown operation: $operation');
      }

      response = {
        'correlationId': correlationId,
        'result': result,
        'success': true,
      };
    } catch (e) {
      response = {
        'correlationId': correlationId,
        'error': e.toString(),
        'success': false,
      };
    }

    _bus.emit<Map<String, dynamic>>('chat.response', response);
  }

  @override
  ChatUser registerUser(String username) =>
      _implementation.registerUser(username);

  @override
  List<ChatUser> getActiveUsers() => _implementation.getActiveUsers();

  @override
  void sendMessage(String userId, String content) =>
      _implementation.sendMessage(userId, content);

  @override
  List<ChatMessage> getChatHistory() => _implementation.getChatHistory();
}

// ========== Generated Client Implementation ==========

class ChatClient$Generated extends ExchangeClientBase implements ChatClient {
  ChatClient$Generated(SamsaraBus bus)
      : super(bus, 'chat.request', 'chat.response');

  @override
  Future<ChatUser> registerUser(String username) async {
    final result = await makeRequest<Map<String, dynamic>>('registerUser', {
      'params': [username],
    });
    return ChatUser.fromJson(result);
  }

  @override
  Future<List<ChatUser>> getActiveUsers() async {
    final result = await makeRequest<List<dynamic>>('getActiveUsers', {
      'params': [],
    });
    return result
        .map((item) => ChatUser.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> sendMessage(String userId, String content) async {
    await makeRequest<dynamic>(
        'sendMessage',
        {
          'params': [userId, content],
        },
        timeout: Duration(seconds: 10));
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    final result = await makeRequest<List<dynamic>>('getChatHistory', {
      'params': [],
    });
    return result
        .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
