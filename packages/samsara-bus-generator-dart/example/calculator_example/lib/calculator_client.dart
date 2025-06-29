import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

part 'calculator_client.g.dart';

/// Calculator Client Interface
@ExchangeClient('calculator.request', 'calculator.response')
abstract class CalculatorClient {
  @ExchangeMethod()
  Future<int> add(int a, int b);

  @ExchangeMethod()
  Future<int> subtract(int a, int b);

  @ExchangeMethod()
  Future<int> multiply(int a, int b);

  @ExchangeMethod(timeout: Duration(seconds: 10))
  Future<double> divide(int a, int b);
}
