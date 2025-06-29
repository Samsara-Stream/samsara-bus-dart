# Build Instructions

## Code Generation

This monorepo contains examples and test fixtures that use code generation. After running `melos bootstrap`, you need to generate the required `.g.dart` files.

### Automatic Generation (Recommended)

The code generation is automatically triggered after `melos bootstrap` completes. If you need to manually trigger it:

```bash
melos run build
```

### Manual Generation

If you prefer to generate code manually for specific examples:

```bash
# Calculator example
cd packages/samsara-bus-generator-dart/example/calculator_example
dart run build_runner build --delete-conflicting-outputs

# Chat example  
cd packages/samsara-bus-generator-dart/example/chat_example
dart run build_runner build --delete-conflicting-outputs

# Trading example
cd packages/samsara-bus-generator-dart/example/trading_example
dart run build_runner build --delete-conflicting-outputs

# Generator package (for test fixtures)
cd packages/samsara-bus-generator-dart
dart run build_runner build --delete-conflicting-outputs
```

### Watch Mode

To automatically regenerate code when files change:

```bash
melos run build:watch
```

### Cleaning Generated Files

To remove all generated files:

```bash
melos run clean:build
```

## Available Melos Scripts

- `melos run build` - Generate code for all examples and test fixtures
- `melos run build:watch` - Watch calculator example for changes
- `melos run clean:build` - Clean all generated files
- `melos run format` - Format all Dart code
- `melos run analyze` - Analyze all Dart code
- `melos run test` - Run all tests
