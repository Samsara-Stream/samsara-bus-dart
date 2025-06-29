import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

part 'simple_service.g.dart';

/// Simple service for testing basic functionality
@ExchangeService('test.request', 'test.response')
abstract class SimpleService {
  @ServiceMethod()
  String getMessage();

  @ServiceMethod()
  int getNumber(String input);

  @ServiceMethod()
  bool checkStatus(int id, String type);
}
