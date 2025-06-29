import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:test/test.dart';

void main() {
  late SamsaraBus bus;

  setUp(() {
    bus = DefaultSamsaraBus();
  });

  tearDown(() async {
    await bus.close();
  });

  group('Topic registration and retrieval', () {
    test('Should register and retrieve a topic', () {
      final topic = bus.registerTopic<String>('test', TopicType.publishSubject);
      expect(topic, isNotNull);
      expect(topic.name, equals('test'));

      final retrieved = bus.getTopic<String>('test');
      expect(retrieved, equals(topic));
    });

    test('Should throw when registering duplicate topic', () {
      bus.registerTopic<String>('test', TopicType.publishSubject);
      expect(() => bus.registerTopic<int>('test', TopicType.publishSubject),
          throwsException);
    });

    test('Should throw when topic does not exist', () {
      expect(() => bus.getTopic<String>('nonexistent'), throwsException);
    });

    test('Should throw when topic exists with wrong type', () {
      bus.registerTopic<String>('test', TopicType.publishSubject);
      expect(() => bus.getTopic<int>('test'), throwsException);
    });
  });

  group('Message emission and reception', () {
    test('Should emit and receive messages', () async {
      bus.registerTopic<String>('test', TopicType.publishSubject);

      final messages = <String>[];

      final subscription = bus.getStream<String>('test').listen((message) {
        messages.add(message);
      });

      bus.emit<String>('test', 'Hello');
      bus.emit<String>('test', 'World', correlationId: 'test-id');

      // Allow time for the messages to be delivered
      await Future.delayed(Duration(milliseconds: 100));

      expect(messages, equals(['Hello', 'World']));

      await subscription.cancel();
    });
  });

  group('Topic connections', () {
    test('Should connect topics and transform messages', () async {
      bus.registerTopic<String>('source', TopicType.publishSubject);
      bus.registerTopic<int>('destination', TopicType.publishSubject);

      final results = <int>[];
      final subscription = bus.getStream<int>('destination').listen((value) {
        results.add(value);
      });

      // Connect topics with a transformation
      bus.connectTopics<String, int>(
        'source',
        'destination',
        (message) => message.length,
      );

      // Emit to source topic
      bus.emit<String>('source', 'Hello');
      bus.emit<String>('source', 'World');

      // Allow time for the messages to be delivered
      await Future.delayed(Duration(milliseconds: 100));

      expect(results, equals([5, 5])); // Both "Hello" and "World" have length 5

      await subscription.cancel();
    });
  });

  group('Stream injection', () {
    test('Should inject external streams into topics', () async {
      bus.registerTopic<String>('test', TopicType.publishSubject);

      final controller = StreamController<int>();
      final results = <String>[];

      final subscription = bus.getStream<String>('test').listen((value) {
        results.add(value);
      });

      // Inject the stream with a transformation
      bus.injectStream<int, String>(
        'test',
        controller.stream,
        (value) => 'Number: $value',
      );

      // Add to the external stream
      controller.add(1);
      controller.add(2);
      controller.add(3);

      // Allow time for the messages to be delivered
      await Future.delayed(Duration(milliseconds: 100));

      expect(results, equals(['Number: 1', 'Number: 2', 'Number: 3']));

      await subscription.cancel();
      await controller.close();
    });
  });

  group('Message envelope', () {
    test('Should map message envelope with new payload', () {
      final envelope = MessageEnvelope<String>(
        payload: 'test',
        correlationId: 'test-id',
      );

      final mapped = envelope.map<int>((payload) => payload.length);

      expect(mapped.payload, equals(4));
      expect(mapped.correlationId, equals('test-id'));
      expect(mapped.timestamp, equals(envelope.timestamp));
    });
  });
}
