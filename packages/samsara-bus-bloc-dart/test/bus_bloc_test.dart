import 'package:test/test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

// Test events and state
abstract class TestEvent {}

class AddEvent extends TestEvent {
  final int value;
  AddEvent(this.value);
}

class BusAddEvent extends TestEvent {
  final int amount;
  BusAddEvent(this.amount);
}

class TestState {
  final int count;
  const TestState(this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TestState && other.count == count;

  @override
  int get hashCode => count.hashCode;
}

// Test bloc
class TestBloc extends BusBloc<TestEvent, TestState> {
  TestBloc(SamsaraBus bus) : super(bus, const TestState(0)) {
    on<AddEvent>((event, emit) => emit(TestState(state.count + event.value)));
    on<BusAddEvent>(
        (event, emit) => emit(TestState(state.count + event.amount)));

    onBusTopic<int>('test_topic', (busEvent) => BusAddEvent(busEvent.data));
  }
}

void main() {
  group('BusBloc Tests', () {
    late SamsaraBus bus;
    late TestBloc bloc;

    setUp(() {
      bus = DefaultSamsaraBus();
      bus.registerTopic<int>('test_topic', TopicType.publishSubject);
      bloc = TestBloc(bus);
    });

    tearDown(() async {
      await bloc.close();
      await bus.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, equals(const TestState(0)));
    });

    blocTest<TestBloc, TestState>(
      'emits correct states when UI events are added',
      build: () => bloc,
      act: (bloc) {
        bloc.add(AddEvent(5));
        bloc.add(AddEvent(3));
      },
      expect: () => [
        const TestState(5),
        const TestState(8),
      ],
    );

    blocTest<TestBloc, TestState>(
      'emits correct states when bus messages are received',
      build: () => bloc,
      act: (bloc) async {
        // Give some time for subscription to be set up
        await Future.delayed(Duration(milliseconds: 10));
        bus.emit('test_topic', 7);
        bus.emit('test_topic', 2);
        // Give some time for events to be processed
        await Future.delayed(Duration(milliseconds: 10));
      },
      expect: () => [
        const TestState(7),
        const TestState(9),
      ],
    );

    test('can emit to bus topics', () async {
      bus.registerTopic<String>('output_topic', TopicType.publishSubject);

      final outputMessages = <String>[];
      bus.getStream<String>('output_topic').listen(outputMessages.add);

      bloc.emitToBus('output_topic', 'hello');
      bloc.emitToBus('output_topic', 'world');

      await Future.delayed(Duration(milliseconds: 10));

      expect(outputMessages, equals(['hello', 'world']));
    });
  });

  group('Topology Tests', () {
    late SamsaraBus bus;

    setUp(() {
      bus = DefaultSamsaraBus();
      bus.registerTopic<int>('topic1', TopicType.publishSubject);
      bus.registerTopic<int>('topic2', TopicType.publishSubject);
    });

    tearDown(() async {
      await bus.close();
    });

    test('topology builder creates correct instance', () {
      final testTopology = topology('test_topology')
          .param<int>('multiplier', (t) => t.number())
          .topic('source1', 'topic1')
          .topic('source2', 'topic2')
          .proc(processor(
            id: 'adder',
            inputs: ['source1', 'source2'],
            combiner: TopologyCombiner.combineLatest,
            fn: (inputs) => (inputs[0] as int) + (inputs[1] as int),
          ))
          .output('adder')
          .build();

      expect(testTopology.name, equals('test_topology'));
      expect(testTopology.paramTypes, hasLength(1));
      expect(testTopology.topics, hasLength(2));
      expect(testTopology.processors, hasLength(1));
      expect(testTopology.outputNode, equals('adder'));
    });

    test('processor definition skip symbol works', () {
      final proc = processor(
        id: 'filter',
        inputs: ['input'],
        fn: (inputs) {
          final value = inputs[0] as int;
          return value > 5 ? value : skip;
        },
      );

      expect(proc.id, equals('filter'));
      expect(proc.inputs, equals(['input']));

      // Test that the function returns skip for values <= 5
      expect(proc.fn([3]), equals(skip));
      expect(proc.fn([7]), equals(7));
    });
  });

  group('TypeValidator Tests', () {
    const validator = TypeValidator();

    test('string validator works correctly', () {
      final stringValidator = validator.string();
      expect(stringValidator('hello'), isTrue);
      expect(stringValidator(123), isFalse);
      expect(stringValidator(null), isFalse);
    });

    test('number validator works correctly', () {
      final numberValidator = validator.number();
      expect(numberValidator(123), isTrue);
      expect(numberValidator(12.5), isTrue);
      expect(numberValidator('123'), isFalse);
      expect(numberValidator(null), isFalse);
    });

    test('boolean validator works correctly', () {
      final boolValidator = validator.boolean();
      expect(boolValidator(true), isTrue);
      expect(boolValidator(false), isTrue);
      expect(boolValidator(1), isFalse);
      expect(boolValidator('true'), isFalse);
    });
  });
}
