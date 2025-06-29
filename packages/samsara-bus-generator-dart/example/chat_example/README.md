# Chat Example

This example demonstrates how to use the SamsaraBus generator to create a chat application using the Exchange Pattern.

## Features

- User registration with unique usernames
- Real-time message broadcasting
- Message history retrieval
- Active user management
- Error handling for invalid operations
- Generated client and service code

## Project Structure

```
chat_example/
├── lib/
│   ├── models.dart                 # Data models (User, ChatMessage, etc.)
│   ├── chat_client.dart           # Abstract client interface
│   ├── chat_service.dart          # Abstract service interface
│   └── chat_service_impl.dart     # Concrete service implementation
├── bin/
│   └── main.dart                  # Example application
├── build.yaml                    # Build configuration
├── pubspec.yaml                   # Dependencies
└── .gitignore                     # Ignores generated files
```

## Generated Files

After running `dart run build_runner build`, the following files are generated:

- `lib/chat_client.g.dart` - Client implementation
- `lib/chat_service.g.dart` - Service implementation

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
Chat Application using SamsaraBus Exchange Pattern
================================================
Chat service started successfully

=== Demo 1: User Registration ===
User registered: Alice (9083176a-8f34-40d7-9ba6-23e9a1776cbf)
Registered: Alice (ID: 9083176a-8f34-40d7-9ba6-23e9a1776cbf)
User registered: Bob (5434894b-dd49-4d20-ae44-5f6e80a23de3)
Registered: Bob (ID: 5434894b-dd49-4d20-ae44-5f6e80a23de3)

=== Demo 2: Chat Session ===
Message sent: Alice: Hello everyone!
[BROADCAST] [10:14:6] Alice: Hello everyone!
Message sent: Bob: Hi Alice! How are you?
[BROADCAST] [10:14:6] Bob: Hi Alice! How are you?
Message sent: Alice: I'm doing great! Thanks for asking.
[BROADCAST] [10:14:6] Alice: I'm doing great! Thanks for asking.

=== Demo 3: Message History ===
Recent messages:
  [10:14:6] Alice: Hello everyone!
  [10:14:6] Bob: Hi Alice! How are you?
  [10:14:6] Alice: I'm doing great! Thanks for asking.

=== Demo 4: Active Users ===
Active users:
  Alice (joined: 2025-06-22 10:14:06.377092)
  Bob (joined: 2025-06-22 10:14:06.385093)

=== Demo 5: Error Handling ===
Caught expected error: Exception: Exception: Username "Alice" is already taken
Caught expected error: Exception: Exception: User not found: invalid-user-id

Shutting down...
Example completed.
```

## Key Features

- **Real-time Broadcasting**: Messages are broadcast to all subscribers via the `chat.messages` topic
- **User Management**: Users are registered with unique IDs and usernames
- **Message History**: Previous messages can be retrieved with configurable limits
- **Error Handling**: Comprehensive error handling for duplicate usernames and invalid users
- **Clean Architecture**: Clear separation between service logic and transport layer

## How It Works

1. **Service Definition**: `ChatService` defines the business operations
2. **Client Definition**: `ChatClient` provides the client-side interface
3. **Implementation**: `ChatServiceImpl` contains the actual chat logic
4. **Broadcasting**: Messages are sent via both request-response and publish-subscribe patterns
5. **Code Generation**: Generated classes handle all the message serialization and routing
