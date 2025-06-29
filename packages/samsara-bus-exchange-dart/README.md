# Samsara Bus Exchange Dart

Exchange pattern annotations and helpers for Samsara Bus Dart. This package provides annotations and base classes for implementing the Request/Response (Exchange) pattern over the Samsara Bus message system.

This package is part of the [Samsara Bus Dart monorepo](https://github.com/Samsara-Stream/samsara-bus-dart).

## Features

- **Annotation-based code generation** for Exchange clients and services
- **Type-safe** request/response communication
- **Timeout support** with configurable defaults and per-method overrides
- **Error handling** across service boundaries
- **Concurrent request** support
- **Automatic serialization/deserialization** of request and response data

## Installation

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  samsara_bus_dart: ^1.0.0
  samsara_bus_exchange_dart: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.6
  samsara_bus_generator_dart: ^1.0.0  # Required for code generation
```

You'll also need a `build.yaml` file in your project root:

```yaml
targets:
  $default:
    builders:
      samsara_bus_generator_dart:
        enabled: true
```

## Quick Start

### 1. Define a Service Interface

Create a service interface using the `@ExchangeService` annotation:

```dart
// lib/calculator_service.dart
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

part 'calculator_service.g.dart';

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
```

### 2. Create a Service Implementation

Implement your service logic:

```dart
// lib/calculator_service_impl.dart
import 'calculator_service.dart';

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
```

### 3. Define a Client Interface

Create a client interface using the `@ExchangeClient` annotation:

```dart
// lib/calculator_client.dart
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

part 'calculator_client.g.dart';

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
```

### 4. Generate Code

Run the code generator to create the implementation classes:

```bash
dart run build_runner build
```

This will generate:
- `calculator_service.g.dart` - Contains `CalculatorService$Generated`
- `calculator_client.g.dart` - Contains `CalculatorClient$Generated`

### 5. Use the Generated Code

```dart
// bin/main.dart
import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';

import '../lib/calculator_client.dart';
import '../lib/calculator_service.dart';
import '../lib/calculator_service_impl.dart';

void main() async {
  final bus = DefaultSamsaraBus();

  // Register topics for the calculator service
  bus.registerTopic<Map<String, dynamic>>(
      'calculator.request', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'calculator.response', TopicType.publishSubject);

  // Start the service
  final serviceImpl = CalculatorServiceImpl();
  final service = CalculatorService$Generated(bus, serviceImpl);
  await service.start();

  // Create a client
  final client = CalculatorClient$Generated(bus);

  try {
    // Make requests
    final sum = await client.add(10, 5);
    print('10 + 5 = $sum'); // Output: 10 + 5 = 15

    final quotient = await client.divide(10, 5);
    print('10 / 5 = $quotient'); // Output: 10 / 5 = 2.0

    // Handle errors
    try {
      await client.divide(10, 0);
    } catch (e) {
      print('Error: $e'); // Output: Error: Exception: Division by zero is not allowed
    }
  } finally {
    // Clean up
    await service.stop();
    client.dispose();
    await bus.close();
  }
}
```

## Annotations Reference

### @ExchangeService

Marks an abstract class as a service that receives requests and sends responses.

```dart
@ExchangeService(requestTopic, responseTopic)
abstract class MyService {
  // Service methods...
}
```

**Parameters:**
- `requestTopic`: Topic name for receiving requests
- `responseTopic`: Topic name for sending responses

### @ServiceMethod

Marks a method in an `@ExchangeService` class as a request handler.

```dart
@ServiceMethod()
ReturnType methodName(Type1 param1, Type2 param2);

// Optional: Custom operation name
@ServiceMethod(operation: 'customName')
ReturnType methodName(Type1 param1, Type2 param2);
```

**Parameters:**
- `operation` (optional): Custom operation name (defaults to method name)

### @ExchangeClient

Marks an abstract class as a client that sends requests and receives responses.

```dart
@ExchangeClient(requestTopic, responseTopic)
abstract class MyClient {
  // Client methods...
}

// With default timeout
@ExchangeClient(requestTopic, responseTopic, 
    defaultTimeout: Duration(seconds: 5))
abstract class MyClient {
  // Client methods...
}
```

**Parameters:**
- `requestTopic`: Topic name for sending requests
- `responseTopic`: Topic name for receiving responses
- `defaultTimeout` (optional): Default timeout for all requests

### @ExchangeMethod

Marks a method in an `@ExchangeClient` class as a request method.

```dart
@ExchangeMethod()
Future<ReturnType> methodName(Type1 param1, Type2 param2);

// With custom timeout
@ExchangeMethod(timeout: Duration(seconds: 10))
Future<ReturnType> methodName(Type1 param1, Type2 param2);

// With custom operation name
@ExchangeMethod(operation: 'customName')
Future<ReturnType> methodName(Type1 param1, Type2 param2);
```

**Parameters:**
- `operation` (optional): Custom operation name (defaults to method name)
- `timeout` (optional): Method-specific timeout override

## Advanced Features

### Error Handling

Services can throw exceptions that will be propagated to the client:

```dart
// Service implementation
@override
double divide(int a, int b) {
  if (b == 0) {
    throw Exception('Division by zero is not allowed');
  }
  return a / b;
}

// Client usage
try {
  final result = await client.divide(10, 0);
} catch (e) {
  print('Service error: $e');
}
```

### Timeouts

Configure timeouts at the client or method level:

```dart
// Client-level default timeout
@ExchangeClient('my.request', 'my.response',
    defaultTimeout: Duration(seconds: 5))
abstract class MyClient {
  
  // Uses default timeout (5 seconds)
  @ExchangeMethod()
  Future<String> quickOperation();
  
  // Method-specific timeout override (30 seconds)
  @ExchangeMethod(timeout: Duration(seconds: 30))
  Future<String> slowOperation();
}
```

### Concurrent Requests

The generated clients support concurrent requests:

```dart
final futures = <Future<int>>[
  client.add(1, 2),
  client.multiply(3, 4),
  client.subtract(10, 3),
  client.add(100, 200),
];

final results = await Future.wait(futures);
print('Concurrent results: $results');
```

## Code Generation Workflow

1. **Write your interfaces** with annotations
2. **Run the generator**: `dart run build_runner build`
3. **Use the generated classes** in your application
4. **Re-run when you change interfaces**: `dart run build_runner build --delete-conflicting-outputs`

For development with automatic rebuilding:
```bash
dart run build_runner watch
```

## Best Practices

1. **Use meaningful topic names** that reflect your service boundaries
2. **Keep service interfaces focused** - one service per logical domain
3. **Handle errors appropriately** in your service implementations
4. **Set reasonable timeouts** based on your service's expected response times
5. **Use the generated code** - don't implement the exchange pattern manually
6. **Dispose clients properly** to avoid memory leaks

## Topic Naming Conventions

Consider using a consistent naming scheme for your topics:

```dart
// Domain-based naming
@ExchangeService('user.request', 'user.response')
@ExchangeService('order.request', 'order.response')
@ExchangeService('payment.request', 'payment.response')

// Service-based naming  
@ExchangeService('userService.request', 'userService.response')
@ExchangeService('orderService.request', 'orderService.response')
```

## Examples

For a complete working example, see the [calculator example](https://github.com/Samsara-Stream/samsara-bus-dart/tree/main/packages/samsara-bus-generator-dart/examples/calculator_example) in the samsara-bus-generator-dart package.
