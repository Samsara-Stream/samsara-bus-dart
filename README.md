# Samsara Bus Dart

A comprehensive RxDart-based message/event bus ecosystem for Dart applications, providing type-safe communication patterns, exchange mechanisms, and code generation tools.

## Overview

Samsara Bus Dart is a monorepo containing a suite of packages that work together to provide a powerful, flexible, and type-safe messaging system for Dart applications. Built on top of RxDart, it enables decoupled communication between different parts of your application through various patterns including publish-subscribe, request-response, and more.

## Packages

This monorepo contains three main packages:

### 📦 [samsara-bus-dart](./packages/samsara-bus-dart/)

The core message bus implementation that provides:

- **Type-safe Topics**: Register topics with specific message types and stream behaviors
- **Flexible Stream Types**: Choose between PublishSubject, BehaviorSubject, or ReplaySubject
- **Topic Connections**: Connect topics with transformation functions
- **Stream Injection**: Inject external streams into topics
- **Message Correlation**: Track related messages across different topics
- **Global & Local Bus Options**: Use singleton or local instances as needed

### 🔄 [samsara-bus-exchange-dart](./packages/samsara-bus-exchange-dart/)

Exchange pattern annotations and helpers that add request-response capabilities:

- **Annotation-based code generation** for Exchange clients and services
- **Type-safe request/response** communication
- **Timeout support** with configurable defaults and per-method overrides
- **Error handling** across service boundaries
- **Concurrent request** support
- **Automatic serialization/deserialization** of data

### ⚙️ [samsara-bus-generator-dart](./packages/samsara-bus-generator-dart/)

Code generator that creates implementations from annotated interfaces:

- **Automatic code generation** from annotated interfaces
- **Type-safe client proxies** that handle serialization/deserialization
- **Service wrappers** that integrate with the Exchange Pattern
- **Support for all Dart primitive types** and custom serializable objects
- **Build-time generation** with minimal runtime overhead

## Getting Started

For detailed usage instructions, see the individual package READMEs. Here's a quick overview:

1. **Basic messaging**: Start with `samsara-bus-dart` for publish-subscribe patterns
2. **Request-response**: Add `samsara-bus-exchange-dart` for RPC-style communication
3. **Code generation**: Use `samsara-bus-generator-dart` to eliminate boilerplate

## Use Cases

Samsara Bus Dart is particularly useful for:

- **Decoupling components** in complex applications
- **Event-driven architectures**
- **Reactive programming patterns**
- **Cross-component communication**
- **Message transformation and correlation**
- **Microservice-style communication** within monoliths
- **Plugin architectures** with type-safe interfaces

## Contributing

We welcome contributions! Please follow the guidelines below to set up your development environment and contribute to the project.

### Prerequisites

Before you start, make sure you have the following installed:

- **Dart SDK** (>=3.0.0 <4.0.0)
- **Git**
- **Homebrew** (macOS) or equivalent package manager

### Development Setup

#### 1. Clone the Repository

```bash
git clone https://github.com/Samsara-Stream/samsara-bus-dart.git
cd samsara-bus-dart
```

#### 2. Install Development Tools

##### Install Melos (Monorepo Management)

Melos is used to manage this monorepo, allowing you to run commands across all packages:

```bash
dart pub global activate melos
```

##### Install Lefthook (Git Hooks)

Lefthook manages git hooks for code quality checks:

```bash
# On macOS
brew install lefthook

# On Linux
curl -1sLf 'https://dl.cloudsmith.io/public/evilmartians/lefthook/setup.deb.sh' | sudo -E bash
sudo apt install lefthook

# On Windows
scoop install lefthook
```

#### 3. Bootstrap the Workspace

Run the following commands to set up the development environment:

```bash
# Install git hooks
lefthook install

# Bootstrap all packages (installs dependencies and links packages)
melos bootstrap
```

**Note**: The bootstrap process automatically generates code for examples and test fixtures. For manual code generation or build instructions, see [BUILD.md](./BUILD.md).

### Development Workflow

#### Available Melos Commands

Melos provides several commands to work with the monorepo:

```bash
# Bootstrap all packages (run after checkout or dependency changes)
melos bootstrap

# Run tests across all packages
melos test

# Format code across all packages
melos format

# Analyze code across all packages  
melos analyze

# Clean all packages (removes build artifacts)
melos clean

# List all packages
melos list

# Get dependencies for all packages
melos get
```

#### Working with Individual Packages

You can also work with individual packages:

```bash
# Navigate to a specific package
cd packages/samsara-bus-dart

# Run package-specific commands
dart pub get
dart test
dart analyze
dart format .
```

#### Code Quality Checks

The project uses lefthook to automatically run code quality checks before commits:

- **Formatting**: Ensures consistent code style using `dart format`
- **Analysis**: Checks for potential issues using `dart analyze`

These checks run automatically when you commit. You can also run them manually:

```bash
# Run all pre-commit hooks manually
lefthook run pre-commit

# Or run individual checks
dart format . --set-exit-if-changed
dart analyze
```

### Testing

#### Running Tests

```bash
# Run tests for all packages
melos test

# Run tests for a specific package
cd packages/samsara-bus-dart
dart test

# Run tests with coverage
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
```

#### Test Structure

Each package has its own test suite:

- `packages/samsara-bus-dart/test/` - Core bus functionality tests
- `packages/samsara-bus-exchange-dart/test/` - Exchange pattern tests
- `packages/samsara-bus-generator-dart/test/` - Code generator tests

### Code Generation

The generator package includes examples that demonstrate code generation:

```bash
# Navigate to an example
cd packages/samsara-bus-generator-dart/example/calculator_example

# Run code generation
dart run build_runner build

# Watch for changes (development mode)
dart run build_runner watch
```

### Making Changes

1. **Create a feature branch** from `main`
2. **Make your changes** following the existing code style
3. **Add tests** for new functionality
4. **Run quality checks**: `melos analyze && melos format && melos test`
5. **Commit your changes** (lefthook will run pre-commit checks)
6. **Create a pull request** with a clear description

### Publishing

This monorepo uses Melos for versioning and publishing:

```bash
# Version packages (interactive)
melos version

# Publish to pub.dev (maintainers only)
melos publish
```

### Debugging Tips

- Use `melos list` to see all packages and their status
- Use `melos clean && melos bootstrap` if you encounter dependency issues
- Check individual package `pubspec.yaml` files for package-specific dependencies
- Use `dart pub deps` in individual packages to troubleshoot dependency conflicts

### Getting Help

- **Issues**: Report bugs or request features via [GitHub Issues](https://github.com/Samsara-Stream/samsara-bus-dart/issues)
- **Discussions**: Join conversations in [GitHub Discussions](https://github.com/Samsara-Stream/samsara-bus-dart/discussions)
- **Documentation**: Check individual package READMEs for detailed API documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built on top of [RxDart](https://pub.dev/packages/rxdart) for reactive programming support
- Uses [Melos](https://pub.dev/packages/melos) for monorepo management
- Code generation powered by [build_runner](https://pub.dev/packages/build_runner) and [source_gen](https://pub.dev/packages/source_gen)
