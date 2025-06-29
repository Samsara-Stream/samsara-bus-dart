/// Chat application data models
class User {
  final String id;
  final String username;
  final DateTime joinedAt;

  User({
    required this.id,
    required this.username,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        username: json['username'] as String,
        joinedAt: DateTime.parse(json['joinedAt'] as String),
      );

  @override
  String toString() => 'User(id: $id, username: $username)';
}

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

  @override
  String toString() =>
      '[${timestamp.hour}:${timestamp.minute}:${timestamp.second}] $username: $content';
}

class SendMessageRequest {
  final String userId;
  final String content;

  SendMessageRequest({
    required this.userId,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'content': content,
      };

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      SendMessageRequest(
        userId: json['userId'] as String,
        content: json['content'] as String,
      );
}
