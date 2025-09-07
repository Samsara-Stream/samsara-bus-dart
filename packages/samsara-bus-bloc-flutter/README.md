# Samsara Bus Bloc Flutter

Flutter widgets and helpers for the Samsara Bus Bloc extension.

## Features

- **BusBlocProvider**: Specialized provider for BusBloc instances
- **BusBlocBuilder**: Builder widget that rebuilds on state changes
- **BusBlocListener**: Listener widget for handling state changes
- **BusBlocConsumer**: Combines builder and listener functionality
- **BusEventBuilder**: Builder that provides access to recent bus events
- **BusEventListener**: Listener for both state and bus events
- **BusEventConsumer**: Combines event-aware building and listening

## Usage

### Basic Setup

```dart
import 'package:flutter/material.dart';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';
import 'package:samsara_bus_bloc_flutter/samsara_bus_bloc_flutter.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bus = DefaultSamsaraBus();
    
    return MaterialApp(
      home: BusBlocProvider(
        create: (context) => MyBloc(bus),
        child: MyHomePage(),
      ),
    );
  }
}
```

### Using BusBlocBuilder

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BusBlocBuilder<MyBloc, MyEvent, MyState>(
        builder: (context, state) {
          return Text('Count: ${state.count}');
        },
      ),
    );
  }
}
```

### Using BusEventBuilder

```dart
class EventAwareWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BusEventBuilder<MyBloc, MyEvent, MyState>(
      builder: (context, state, recentBusEvents) {
        return Column(
          children: [
            Text('Count: ${state.count}'),
            Text('Recent events: ${recentBusEvents.length}'),
            ...recentBusEvents.map((event) => 
              Text('Event: ${event.topicName}')
            ),
          ],
        );
      },
    );
  }
}
```

### Using BusEventConsumer

```dart
class FullFeaturedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BusEventConsumer<MyBloc, MyEvent, MyState>(
      stateListener: (context, state) {
        if (state.showSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('State changed!')),
          );
        }
      },
      busEventListener: (context, event) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bus event: ${event.topicName}')),
        );
      },
      builder: (context, state, recentBusEvents) {
        return Column(
          children: [
            Text('Count: ${state.count}'),
            Text('Events: ${recentBusEvents.length}'),
          ],
        );
      },
    );
  }
}
```

## Dependencies

This package depends on:
- `flutter`
- `flutter_bloc`
- `samsara_bus_dart`
- `samsara_bus_bloc_dart`

## License

This project is licensed under the MIT License.
