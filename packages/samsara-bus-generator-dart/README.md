# Samsara Bus Generator Dart

Code generator for SamsaraBus Exchange Pattern annotations. This package provides build-time code generation for creating type-safe client and service implementations from annotated interfaces.

This package is part of the [Samsara Bus Dart monorepo](https://github.com/Samsara-Stream/samsara-bus-dart).

## Overview

The Samsara Bus Generator automatically generates client proxies and service wrappers from interfaces annotated with `@ExchangeClient` and `@ExchangeService`. This eliminates boilerplate code and ensures type-safe communication across the Samsara Bus message system.

## Features

- **Automatic code generation** from annotated interfaces
- **Type-safe client proxies** that handle serialization/deserialization
- **Service wrappers** that integrate with the Exchange Pattern
- **Support for all Dart primitive types** and custom serializable objects
- **Timeout handling** with configurable defaults and per-method overrides
- **Error propagation** across service boundaries
- **Concurrent request support**

## Installation

Add this package as a dev dependency along with the required runtime dependencies:

```yaml
dependencies:
  samsara_bus_dart: ^1.0.0
  samsara_bus_exchange_dart: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.6
  samsara_bus_generator_dart: ^1.0.0  # This package
```

Create a `build.yaml` file in your project root:

```yaml
targets:
  $default:
    builders:
      samsara_bus_generator_dart:
        enabled: true
```

## Usage

### 1. Define Annotated Interfaces

Create interfaces using `@ExchangeService` and `@ExchangeClient` annotations:

```dart
// lib/calculator_service.dart
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeService('calculator')
abstract class CalculatorService {
  @ServiceMethod()
  Future<double> add(double a, double b);
  
  @ServiceMethod(timeout: Duration(seconds: 5))
  Future<double> divide(double a, double b);
}

@ExchangeClient('calculator')
abstract class CalculatorClient {
  @ExchangeMethod()
  Future<double> add(double a, double b);
  
  @ExchangeMethod()
  Future<double> divide(double a, double b);
}
```

### 2. Generate Code

Run the build process to generate implementation code:

```bash
dart run build_runner build
```

This creates `.g.dart` files containing the generated implementations.

### 3. Use Generated Code

```dart
// lib/main.dart
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'calculator_service.dart';

void main() async {
  final bus = SamsaraBus();
  
  // Use generated service wrapper
  final service = $GeneratedCalculatorService(MyCalculatorImpl(), bus);
  
  // Use generated client proxy
  final client = $GeneratedCalculatorClient(bus);
  
  final result = await client.add(5.0, 3.0);
  print('Result: $result'); // Result: 8.0
}
```

## What Gets Generated

For each annotated interface, the generator creates:

- **Client Implementation**: A `$Generated{ClassName}` that handles message serialization, routing, and response handling
- **Service Wrapper**: A `$Generated{ClassName}` that receives messages, deserializes parameters, calls your implementation, and sends responses
- **Type Safety**: Compile-time validation of method signatures and parameter types

## Examples

This package includes three comprehensive examples demonstrating different use cases:

### Calculator Example
A simple arithmetic service showing basic code generation concepts.

```bash
cd example/calculator_example
dart pub get
dart run build_runner build
dart run bin/main.dart
```

### Chat Example  
A real-time chat application demonstrating more complex interactions with user management and message broadcasting.

```bash
cd example/chat_example
dart pub get
dart run build_runner build
dart run bin/main.dart
```

### Trading Example
An advanced multi-service stock trading system showcasing complex data models and concurrent operations.

```bash
cd example/trading_example
dart pub get
dart run build_runner build
dart run bin/main.dart
```

## Project Structure

Generated code follows these conventions:

```
your_project/
├── lib/
│   ├── my_service.dart           # Your annotated interfaces
│   ├── my_service_impl.dart      # Your implementations
│   └── my_service.g.dart         # Generated code (do not edit)
├── build.yaml                   # Build configuration
└── pubspec.yaml                 # Dependencies
```

## Tips

- **Always run** `dart pub get` before generating code
- **Use** `--delete-conflicting-outputs` flag if you encounter build conflicts:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- **Add** `*.g.dart` to your `.gitignore` to exclude generated files from version control
- **Check** the generated `.g.dart` files to understand what the generator creates
- **Re-run** code generation after modifying annotated interfaces

## Advanced Configuration

The generator supports various configuration options through annotations:

```dart
@ExchangeService('my-service')
class MyService {
  @ServiceMethod(timeout: Duration(seconds: 30))
  Future<String> heavyOperation(String input);
  
  @ServiceMethod(timeout: Duration(milliseconds: 500))
  Future<String> fastOperation(String input);
}
```

## Error Handling

Generated code automatically handles:
- **Serialization errors**: Invalid parameter types
- **Network errors**: Bus communication failures  
- **Timeout errors**: Method-specific or default timeouts
- **Service errors**: Exceptions thrown by service implementations

## Documentation

For detailed examples and usage patterns, see the [samsara-bus-exchange-dart README](../samsara-bus-exchange-dart/README.md) which provides comprehensive documentation of the Exchange Pattern annotations and usage.

## Contributing

This package is part of the Samsara Bus Dart project. Please see the main repository for contribution guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
