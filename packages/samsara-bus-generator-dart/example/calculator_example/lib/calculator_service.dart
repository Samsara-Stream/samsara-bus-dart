import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

part 'calculator_service.g.dart';

/// Calculator Service Interface
@ExchangeService('calculator.request', 'calculator.response')
abstract class CalculatorService {
  @ServiceMethod()
  int add(int a, int b);

  @ServiceMethod()
  int subtract(int a, int b);

  @ServiceMethod()
  int multiply(int a, int b);

  @ServiceMethod()
  double divide(int a, int b);
}
