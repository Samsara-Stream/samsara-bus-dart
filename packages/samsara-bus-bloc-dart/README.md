# Samsara Bus Bloc Extension

A Bloc extension for Samsara Bus that allows blocs to communicate with other components through bus topics and define complex event processing topologies.

## Features

- **Bus Integration**: Blocs can emit and listen to messages on SamsaraBus topics
- **Topology Support**: Define complex stream processing topologies that combine UI events and bus messages
- **Stream Operators**: Use RxDart operators to transform and combine streams
- **Type Safety**: Full type safety for events, states, and message types
- **Flutter Integration**: Flutter-specific widgets and helpers

## Basic Usage

### Creating a BusBloc

```dart
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

// Define your events and states
sealed class CounterEvent {}
class Increment extends CounterEvent {}
class Decrement extends CounterEvent {}
class BusIncrement extends CounterEvent {
  final int amount;
  BusIncrement(this.amount);
}

class CounterState {
  final int count;
  const CounterState(this.count);
}

// Create your BusBloc
class CounterBloc extends BusBloc<CounterEvent, CounterState> {
  CounterBloc(SamsaraBus bus) : super(bus, const CounterState(0)) {
    // Handle regular UI events
    on<Increment>((event, emit) => emit(CounterState(state.count + 1)));
    on<Decrement>((event, emit) => emit(CounterState(state.count - 1)));
    on<BusIncrement>((event, emit) => emit(CounterState(state.count + event.amount)));

    // Listen to bus topic and convert to bloc events
    onBusTopic<int>('increment_topic', (busEvent) => BusIncrement(busEvent.data));
  }
}
```

### Using Topologies

```dart
// Define a topology that combines multiple sources
final topology = topology('counter_topology')
    .topic('ui_events', 'ui_topic')
    .topic('external_events', 'external_topic')
    .proc(processor(
      id: 'combiner',
      inputs: ['ui_events', 'external_events'],
      combiner: TopologyCombiner.combineLatest,
      fn: (inputs) {
        final uiValue = inputs[0] as int;
        final externalValue = inputs[1] as int;
        return uiValue + externalValue;
      },
    ))
    .output('combiner')
    .build();

// Use the topology in your bloc
class AdvancedCounterBloc extends BusBloc<CounterEvent, CounterState> {
  AdvancedCounterBloc(SamsaraBus bus) : super(bus, const CounterState(0)) {
    on<BusIncrement>((event, emit) => emit(CounterState(state.count + event.amount)));

    // Subscribe to topology results
    onTopology<int>(
      topology,
      {}, // parameters
      (topologyEvent) => BusIncrement(topologyEvent.data),
    );
  }
}
```

## Flutter Integration

```dart
import 'package:flutter/material.dart';
import 'package:samsara_bus_bloc_flutter/samsara_bus_bloc_flutter.dart';

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BusBlocProvider(
      create: (context) => CounterBloc(GlobalSamsaraBus.instance),
      child: BusBlocBuilder<CounterBloc, CounterEvent, CounterState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text('Counter')),
            body: Center(
              child: Text('Count: ${state.count}'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.read<CounterBloc>().add(Increment()),
              child: Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
```

## API Reference

### BusBloc<Event, State>

The main class that extends `Bloc` with bus capabilities.

#### Methods

- `onBusTopic<T>(String topicName, Event Function(BusMessageEvent<T>) eventMapper)` - Subscribe to a bus topic
- `onTopology<T>(TopologyInstance topology, Map<String, dynamic> parameters, Event Function(TopologyResultEvent<T>) eventMapper)` - Subscribe to a topology
- `emitToBus<T>(String topicName, T message, {String? correlationId})` - Emit a message to a bus topic

### Topology API

- `topology(String name)` - Create a new topology builder
- `processor({required String id, required List<String> inputs, required Function fn, TopologyCombiner? combiner})` - Create a processor definition

### Stream Combiners

- `TopologyCombiner.combineLatest` - Combine streams using combineLatest
- `TopologyCombiner.zip` - Combine streams using zip  
- `TopologyCombiner.merge` - Merge streams
- `TopologyCombiner.withLatestFrom` - Use withLatestFrom for combining

## License

This project is licensed under the MIT License.
