import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

part 'simple_client.g.dart';

/// Simple client for testing basic functionality
@ExchangeClient('test.request', 'test.response')
abstract class SimpleClient {
  @ExchangeMethod()
  Future<String> getMessage();

  @ExchangeMethod()
  Future<int> getNumber(String input);

  @ExchangeMethod()
  Future<bool> checkStatus(int id, String type);
}
