# Calculator Example

This example demonstrates how to use the SamsaraBus generator to create a simple calculator service using the Exchange Pattern.

## Features

- Basic arithmetic operations (add, subtract, multiply, divide)
- Error handling for division by zero
- Concurrent operation support
- Generated client and service code

## Project Structure

```
calculator_example/
├── lib/
│   ├── calculator_client.dart      # Abstract client interface
│   ├── calculator_service.dart     # Abstract service interface
│   └── calculator_service_impl.dart # Concrete service implementation
├── bin/
│   └── main.dart                   # Example application
├── build.yaml                     # Build configuration
├── pubspec.yaml                    # Dependencies
└── .gitignore                      # Ignores generated files
```

## Generated Files

After running `dart run build_runner build`, the following files are generated:

- `lib/calculator_client.g.dart` - Client implementation
- `lib/calculator_service.g.dart` - Service implementation

## Running the Example

1. Install dependencies:
   ```bash
   dart pub get
   ```

2. Generate the code:
   ```bash
   dart run build_runner build
   ```

3. Run the example:
   ```bash
   dart run bin/main.dart
   ```

## Expected Output

```
Calculator Example using SamsaraBus Exchange Pattern
===================================================
Calculator service started successfully

=== Demo 1: Basic Operations ===
Computing 10 + 5
10 + 5 = 15
Computing 10 - 5
10 - 5 = 5
Computing 10 * 5
10 * 5 = 50
Computing 10 / 5
10 / 5 = 2.0

=== Demo 2: Error Handling ===
Computing 10 / 0
Caught expected error: Exception: Division by zero is not allowed

=== Demo 3: Concurrent Operations ===
Computing 1 + 2
Computing 3 * 4
Computing 10 - 3
Computing 100 + 200
Concurrent results: [3, 12, 7, 300]

Shutting down...
Example completed.
```

## How It Works

1. **Service Definition**: `CalculatorService` is an abstract class annotated with `@ExchangeService`
2. **Client Definition**: `CalculatorClient` is an abstract class annotated with `@ExchangeClient`
3. **Implementation**: `CalculatorServiceImpl` provides the concrete business logic
4. **Code Generation**: The generator creates `CalculatorService$Generated` and `CalculatorClient$Generated`
5. **Runtime**: The service listens for requests, processes them, and sends responses back to clients

## Key Annotations

- `@ExchangeService('calculator.request', 'calculator.response')` - Marks the service class
- `@ExchangeClient('calculator.request', 'calculator.response')` - Marks the client class  
- `@ServiceMethod()` - Marks methods that handle requests
- `@ExchangeMethod()` - Marks methods that make requests
- `@ExchangeMethod(timeout: Duration(seconds: 10))` - Custom timeout for specific methods
