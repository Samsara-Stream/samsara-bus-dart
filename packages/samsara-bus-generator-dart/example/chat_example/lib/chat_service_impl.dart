import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:uuid/uuid.dart';

import 'chat_service.dart';
import 'models.dart';

/// Concrete implementation of ChatService
class ChatServiceImpl implements ChatService {
  final Map<String, User> _users = {};
  final List<ChatMessage> _messages = [];
  final _uuid = Uuid();
  final SamsaraBus _bus;

  ChatServiceImpl(this._bus);

  @override
  User registerUser(String username) {
    // Check if username already exists
    for (final user in _users.values) {
      if (user.username == username) {
        throw Exception('Username "$username" is already taken');
      }
    }

    final user = User(
      id: _uuid.v4(),
      username: username,
      joinedAt: DateTime.now(),
    );

    _users[user.id] = user;
    print('User registered: ${user.username} (${user.id})');

    return user;
  }

  @override
  ChatMessage sendMessage(SendMessageRequest request) {
    final user = _users[request.userId];
    if (user == null) {
      throw Exception('User not found: ${request.userId}');
    }

    final message = ChatMessage(
      id: _uuid.v4(),
      userId: user.id,
      username: user.username,
      content: request.content,
      timestamp: DateTime.now(),
    );

    _messages.add(message);

    // Broadcast the message to all subscribers
    _bus.emit<ChatMessage>('chat.messages', message);

    print('Message sent: ${message.username}: ${message.content}');
    return message;
  }

  @override
  List<ChatMessage> getMessageHistory(int limit) {
    final messageCount = _messages.length;
    final startIndex = messageCount > limit ? messageCount - limit : 0;
    return _messages.sublist(startIndex);
  }

  @override
  List<User> getActiveUsers() {
    return _users.values.toList();
  }
}
