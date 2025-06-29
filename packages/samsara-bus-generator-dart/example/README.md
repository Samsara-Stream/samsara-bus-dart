# SamsaraBus Generator Examples

This directory contains complete example projects demonstrating how to use the SamsaraBus code generator to create Exchange Pattern implementations.

## Examples Overview

### [Calculator Example](calculator_example/)
A simple arithmetic service demonstrating the basics of code generation.

**Features:**
- Basic arithmetic operations (add, subtract, multiply, divide)
- Error handling for division by zero  
- Concurrent operation support
- Custom timeout configuration

**Best for:** Learning the fundamentals of SamsaraBus code generation.

### [Chat Example](chat_example/)
A real-time chat application showcasing more complex interactions.

**Features:**
- User registration and management
- Real-time message broadcasting
- Message history retrieval
- Active user tracking
- Error handling for duplicate usernames

**Best for:** Understanding how to combine Exchange Pattern with publish-subscribe messaging.

### [Trading Example](trading_example/)
An advanced stock trading system with multiple services.

**Features:**
- Multi-service architecture (Market Data + Trading)
- Complex data models with serialization
- Different order types (Market, Limit, Stop)
- Trade history and portfolio management
- Concurrent operations across services
- Advanced error handling

**Best for:** Seeing how SamsaraBus scales to complex, multi-service applications.

## Getting Started

Each example is a complete Dart project that can be run independently:

```bash
# Navigate to any example
cd calculator_example

# Install dependencies
dart pub get

# Generate the code (creates *.g.dart files)
dart run build_runner build

# Run the example
dart run bin/main.dart
```

## Project Structure

Each example follows the same structure:

```
example_name/
├── lib/
│   ├── *.dart                 # Abstract interfaces with annotations
│   ├── *_impl.dart           # Concrete implementations
│   └── *.g.dart             # Generated code (created by build_runner)
├── bin/
│   └── main.dart             # Runnable example application
├── build.yaml               # Build configuration
├── pubspec.yaml             # Dependencies
├── .gitignore               # Excludes generated files
└── README.md                # Example-specific documentation
```

## Key Files

- **Abstract Interfaces**: Classes annotated with `@ExchangeClient` and `@ExchangeService`
- **Implementations**: Concrete classes implementing the business logic
- **Generated Code**: `.g.dart` files created by `build_runner` (automatically generated)
- **Main Application**: Complete working examples showing usage

## Code Generation Workflow

1. **Define Interfaces**: Create abstract classes with Exchange annotations
2. **Implement Services**: Write concrete implementations of your business logic
3. **Generate Code**: Run `dart run build_runner build` to create client/service wrappers
4. **Use Generated Code**: Import and use the `$Generated` classes in your application

## Generated File Naming

Generated files follow the standard Dart pattern:
- `calculator_service.dart` → `calculator_service.g.dart`
- `chat_client.dart` → `chat_client.g.dart`

The `.g.dart` files are automatically excluded from version control via `.gitignore`.

## Next Steps

1. **Start Simple**: Begin with the Calculator Example to understand the basics
2. **Add Complexity**: Move to the Chat Example to see real-time features
3. **Scale Up**: Explore the Trading Example for multi-service architectures
4. **Create Your Own**: Use these examples as templates for your own projects

## Tips

- Always run `dart pub get` before generating code
- Use `dart run build_runner build --delete-conflicting-outputs` if you encounter conflicts
- Check the generated `.g.dart` files to understand what the generator creates
- Each example's README contains specific output examples and feature explanations
