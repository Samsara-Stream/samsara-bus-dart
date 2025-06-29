import 'calculator_service.dart';

/// Concrete implementation of CalculatorService
class CalculatorServiceImpl implements CalculatorService {
  @override
  int add(int a, int b) {
    print('Computing $a + $b');
    return a + b;
  }

  @override
  int subtract(int a, int b) {
    print('Computing $a - $b');
    return a - b;
  }

  @override
  int multiply(int a, int b) {
    print('Computing $a * $b');
    return a * b;
  }

  @override
  double divide(int a, int b) {
    print('Computing $a / $b');
    if (b == 0) {
      throw Exception('Division by zero is not allowed');
    }
    return a / b;
  }
}
