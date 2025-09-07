import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

// Define events
abstract class CounterEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class Reset extends CounterEvent {}

class BusIncrement extends CounterEvent {
  final int amount;
  BusIncrement(this.amount);
}

// Define state
class CounterState {
  final int count;
  final DateTime lastUpdated;

  const CounterState(this.count, this.lastUpdated);

  @override
  String toString() => 'CounterState(count: $count, lastUpdated: $lastUpdated)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterState &&
          other.count == count &&
          other.lastUpdated == lastUpdated;

  @override
  int get hashCode => count.hashCode ^ lastUpdated.hashCode;
}

// Simple counter bloc that listens to bus topics
class CounterBloc extends BusBloc<CounterEvent, CounterState> {
  CounterBloc(SamsaraBus bus) : super(bus, CounterState(0, DateTime.now())) {
    // Handle regular UI events
    on<Increment>(
        (event, emit) => emit(CounterState(state.count + 1, DateTime.now())));
    on<Decrement>(
        (event, emit) => emit(CounterState(state.count - 1, DateTime.now())));
    on<Reset>((event, emit) => emit(CounterState(0, DateTime.now())));
    on<BusIncrement>((event, emit) =>
        emit(CounterState(state.count + event.amount, DateTime.now())));

    // Listen to bus topic for increment commands
    onBusTopic<int>('increment_commands', (busEvent) {
      print('Received increment command from bus: ${busEvent.data}');
      return BusIncrement(busEvent.data);
    });
  }
}

// Advanced counter bloc using topologies
class AdvancedCounterBloc extends BusBloc<CounterEvent, CounterState> {
  AdvancedCounterBloc(SamsaraBus bus)
      : super(bus, CounterState(0, DateTime.now())) {
    on<BusIncrement>((event, emit) {
      print('Processing combined increment: ${event.amount}');
      emit(CounterState(state.count + event.amount, DateTime.now()));
    });

    // Create a topology that combines UI and external events
    final topology = _createCombinedEventsTopology();

    // Subscribe to topology results
    onTopology<int>(
      topology,
      {'multiplier': 2}, // parameters
      (topologyEvent) {
        print('Topology result: ${topologyEvent.data}');
        return BusIncrement(topologyEvent.data);
      },
    );
  }

  TopologyInstance _createCombinedEventsTopology() {
    return topology('combined_events')
        .param<int>('multiplier', (t) => t.number())
        .topic('ui_increments', 'ui_increment_topic')
        .topic('external_increments', 'external_increment_topic')
        .proc(processor(
          id: 'combiner',
          inputs: ['ui_increments', 'external_increments'],
          combiner: TopologyCombiner.combineLatest,
          fn: (inputs) {
            final uiValue = inputs[0] as int? ?? 0;
            final externalValue = inputs[1] as int? ?? 0;
            final combined = uiValue + externalValue;
            print(
                'Combining: UI=$uiValue + External=$externalValue = $combined');
            return combined;
          },
        ))
        .proc(processor(
          id: 'multiplier',
          inputs: ['combiner'],
          fn: (inputs) {
            final value = inputs[0] as int;
            final multiplier = 2; // Would normally get from parameters
            final result = value * multiplier;
            print('Multiplying: $value * $multiplier = $result');
            return result;
          },
        ))
        .output('multiplier')
        .build();
  }
}

void main() async {
  print('=== Samsara Bus Bloc Example ===');

  // Create a bus instance
  final bus = DefaultSamsaraBus();

  // Register topics
  bus.registerTopic<int>('increment_commands', TopicType.publishSubject);
  bus.registerTopic<int>('ui_increment_topic', TopicType.publishSubject);
  bus.registerTopic<int>('external_increment_topic', TopicType.publishSubject);

  print('\n--- Simple Counter Bloc Example ---');

  // Create simple counter bloc
  final counterBloc = CounterBloc(bus);

  // Listen to state changes
  counterBloc.stream.listen((state) {
    print('Counter state: ${state.count} (updated: ${state.lastUpdated})');
  });

  // Test UI events
  print('Adding UI events...');
  counterBloc.add(Increment());
  counterBloc.add(Increment());
  counterBloc.add(Decrement());

  // Test bus events
  print('Sending bus messages...');
  bus.emit('increment_commands', 5);
  bus.emit('increment_commands', 3);

  await Future.delayed(Duration(milliseconds: 100));

  print('\n--- Advanced Counter Bloc Example ---');

  // Create advanced counter bloc with topology
  final advancedBloc = AdvancedCounterBloc(bus);

  // Listen to state changes
  advancedBloc.stream.listen((state) {
    print(
        'Advanced counter state: ${state.count} (updated: ${state.lastUpdated})');
  });

  await Future.delayed(Duration(milliseconds: 100));

  // Send messages to topology topics
  print('Sending messages to topology topics...');
  bus.emit('ui_increment_topic', 2);
  bus.emit('external_increment_topic', 3);

  await Future.delayed(Duration(milliseconds: 100));

  // Update one of the topics
  bus.emit('ui_increment_topic', 5);

  await Future.delayed(Duration(milliseconds: 100));

  // Clean up
  await counterBloc.close();
  await advancedBloc.close();
  await bus.close();

  print('\nExample completed!');
}
