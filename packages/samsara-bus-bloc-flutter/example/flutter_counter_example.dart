import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';
import 'package:samsara_bus_bloc_flutter/samsara_bus_bloc_flutter.dart';

// Events
abstract class CounterEvent {}

class Increment extends CounterEvent {}

class Decrement extends CounterEvent {}

class BusIncrement extends CounterEvent {
  final int amount;
  BusIncrement(this.amount);
}

// State
class CounterState {
  final int count;
  final String lastAction;

  const CounterState(this.count, {this.lastAction = ''});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CounterState &&
          other.count == count &&
          other.lastAction == lastAction;

  @override
  int get hashCode => count.hashCode ^ lastAction.hashCode;
}

// Bloc
class CounterBloc extends BusBloc<CounterEvent, CounterState> {
  CounterBloc(SamsaraBus bus) : super(bus, const CounterState(0)) {
    on<Increment>((event, emit) =>
        emit(CounterState(state.count + 1, lastAction: 'UI Increment')));

    on<Decrement>((event, emit) =>
        emit(CounterState(state.count - 1, lastAction: 'UI Decrement')));

    on<BusIncrement>((event, emit) => emit(CounterState(
        state.count + event.amount,
        lastAction: 'Bus Increment +${event.amount}')));

    // Listen to bus topic for external increments
    onBusTopic<int>(
        'external_increments', (busEvent) => BusIncrement(busEvent.data));
  }
}

class CounterApp extends StatelessWidget {
  final SamsaraBus bus;

  const CounterApp({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samsara Bus Bloc Counter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BusBlocProvider(
        create: (context) => CounterBloc(bus),
        child: const CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Samsara Bus Bloc Counter'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Counter display
          BusBlocBuilder<CounterBloc, CounterEvent, CounterState>(
            builder: (context, state) {
              return Column(
                children: [
                  Text(
                    'Count: ${state.count}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last action: ${state.lastAction}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 32),

          // UI Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                onPressed: () => context.read<CounterBloc>().add(Decrement()),
                tooltip: 'Decrement',
                child: const Icon(Icons.remove),
              ),
              FloatingActionButton(
                onPressed: () => context.read<CounterBloc>().add(Increment()),
                tooltip: 'Increment',
                child: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Bus Controls
          Column(
            children: [
              Text(
                'Bus Controls',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final bloc = context.read<CounterBloc>();
                      bloc.emitToBus('external_increments', 5);
                    },
                    child: const Text('Bus +5'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final bloc = context.read<CounterBloc>();
                      bloc.emitToBus('external_increments', 10);
                    },
                    child: const Text('Bus +10'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void main() {
  // Create and configure the bus
  final bus = DefaultSamsaraBus();
  bus.registerTopic<int>('external_increments', TopicType.publishSubject);

  runApp(CounterApp(bus: bus));
}
