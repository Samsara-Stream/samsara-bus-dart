import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'models.dart';

part 'chat_client.g.dart';

/// Chat Client Interface
@ExchangeClient('chat.request', 'chat.response')
abstract class ChatClient {
  @ExchangeMethod()
  Future<User> registerUser(String username);

  @ExchangeMethod()
  Future<ChatMessage> sendMessage(SendMessageRequest request);

  @ExchangeMethod()
  Future<List<ChatMessage>> getMessageHistory(int limit);

  @ExchangeMethod()
  Future<List<User>> getActiveUsers();
}
