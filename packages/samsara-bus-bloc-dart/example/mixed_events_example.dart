import 'package:bloc/bloc.dart';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

// Example showing how to combine UI events and bus events in a topology

// Events
abstract class MixedEvent {}

class UIButtonPress extends MixedEvent {
  final String buttonName;
  UIButtonPress(this.buttonName);
}

class BusNotification extends MixedEvent {
  final String message;
  BusNotification(this.message);
}

class CombinedResult extends MixedEvent {
  final String uiAction;
  final String busMessage;
  final String combinedMessage;
  CombinedResult(this.uiAction, this.busMessage, this.combinedMessage);
}

// State
class AppState {
  final String lastUIAction;
  final String lastBusMessage;
  final String status;
  final List<String> history;

  const AppState({
    this.lastUIAction = '',
    this.lastBusMessage = '',
    this.status = 'waiting',
    this.history = const [],
  });

  AppState copyWith({
    String? lastUIAction,
    String? lastBusMessage,
    String? status,
    List<String>? history,
  }) {
    return AppState(
      lastUIAction: lastUIAction ?? this.lastUIAction,
      lastBusMessage: lastBusMessage ?? this.lastBusMessage,
      status: status ?? this.status,
      history: history ?? this.history,
    );
  }
}

// Bloc that uses topology to combine UI and bus events
class MixedEventBloc extends BusBloc<MixedEvent, AppState> {
  late final TopologyInstance _mixedTopology;

  MixedEventBloc(SamsaraBus bus) : super(bus, const AppState()) {
    on<UIButtonPress>(_onUIButtonPress);
    on<BusNotification>(_onBusNotification);
    on<CombinedResult>(_onCombinedResult);

    // Create a topology that combines UI and bus events
    _mixedTopology = _createMixedEventsTopology();

    // Listen to the topology results
    onTopology<Map<String, dynamic>>(
      _mixedTopology,
      {'combine_threshold': 2},
      (topologyEvent) {
        final data = topologyEvent.data;
        return CombinedResult(
          data['ui_action'] as String,
          data['bus_message'] as String,
          data['combined'] as String,
        );
      },
    );
  }

  void _onUIButtonPress(UIButtonPress event, Emitter<AppState> emit) {
    emit(state.copyWith(lastUIAction: event.buttonName));

    // Emit to UI stream in topology
    emitToUIStream(_mixedTopology, 'ui_events', event.buttonName);
  }

  void _onBusNotification(BusNotification event, Emitter<AppState> emit) {
    emit(state.copyWith(lastBusMessage: event.message));
  }

  void _onCombinedResult(CombinedResult event, Emitter<AppState> emit) {
    final newHistory = [...state.history, event.combinedMessage];
    emit(state.copyWith(
      status: 'processed',
      history: newHistory,
    ));
  }

  TopologyInstance _createMixedEventsTopology() {
    return topology('mixed_events')
        .param<int>('combine_threshold', (t) => t.number())
        // UI stream for button presses
        .uiStream<String>('ui_events')
        // Bus topic for external notifications
        .topic('bus_notifications', 'notifications_topic')
        // Processor that combines UI and bus events
        .proc(processor(
          id: 'event_combiner',
          inputs: ['ui_events', 'bus_notifications'],
          combiner: TopologyCombiner.combineLatest,
          fn: (inputs) {
            final uiAction = inputs[0] as String? ?? 'no_ui_action';
            final busMessage = inputs[1] as String? ?? 'no_bus_message';

            // Skip if either input is empty/default
            if (uiAction == 'no_ui_action' || busMessage == 'no_bus_message') {
              return skip;
            }

            final combined =
                'UI: $uiAction + Bus: $busMessage = Combined Action!';

            return {
              'ui_action': uiAction,
              'bus_message': busMessage,
              'combined': combined,
              'timestamp': DateTime.now().toIso8601String(),
            };
          },
        ))
        .output('event_combiner')
        .build();
  }

  // Helper method for external code to trigger UI events
  void pressButton(String buttonName) {
    add(UIButtonPress(buttonName));
  }
}

void main() async {
  print('=== Mixed UI + Bus Events Topology Example ===');

  // Create bus and register topics
  final bus = DefaultSamsaraBus();
  bus.registerTopic<String>('notifications_topic', TopicType.behaviorSubject);

  // Create bloc
  final bloc = MixedEventBloc(bus);

  // Listen to state changes
  bloc.stream.listen((state) {
    print('\n--- State Update ---');
    print('Last UI Action: ${state.lastUIAction}');
    print('Last Bus Message: ${state.lastBusMessage}');
    print('Status: ${state.status}');
    if (state.history.isNotEmpty) {
      print('History: ${state.history.last}');
    }
  });

  await Future.delayed(Duration(milliseconds: 100));

  print('\n--- Testing Mixed Events ---');

  // Test 1: UI event only (should not trigger combination yet)
  print('\n1. Pressing button...');
  bloc.pressButton('save_button');

  await Future.delayed(Duration(milliseconds: 50));

  // Test 2: Bus event only (should not trigger combination yet)
  print('\n2. Sending bus notification...');
  bus.emit('notifications_topic', 'file_uploaded');

  await Future.delayed(Duration(milliseconds: 50));

  // Test 3: Another UI event (should combine with existing bus event)
  print('\n3. Pressing another button...');
  bloc.pressButton('refresh_button');

  await Future.delayed(Duration(milliseconds: 50));

  // Test 4: Another bus event (should combine with latest UI event)
  print('\n4. Sending another notification...');
  bus.emit('notifications_topic', 'data_synced');

  await Future.delayed(Duration(milliseconds: 100));

  // Clean up
  await bloc.close();
  await bus.close();

  print('\n=== Mixed events example completed ===');
}
