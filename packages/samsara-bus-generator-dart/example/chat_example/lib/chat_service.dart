import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'models.dart';

part 'chat_service.g.dart';

/// Chat Service Interface
@ExchangeService('chat.request', 'chat.response')
abstract class ChatService {
  @ServiceMethod()
  User registerUser(String username);

  @ServiceMethod()
  ChatMessage sendMessage(SendMessageRequest request);

  @ServiceMethod()
  List<ChatMessage> getMessageHistory(int limit);

  @ServiceMethod()
  List<User> getActiveUsers();
}
