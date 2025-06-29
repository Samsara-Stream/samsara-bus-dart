import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';

import '../lib/calculator_client.dart';
import '../lib/calculator_service.dart';
import '../lib/calculator_service_impl.dart';

void main() async {
  print('Calculator Example using SamsaraBus Exchange Pattern');
  print('===================================================');

  final bus = DefaultSamsaraBus();

  // Register topics for our calculator service
  bus.registerTopic<Map<String, dynamic>>(
      'calculator.request', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'calculator.response', TopicType.publishSubject);

  // Create the service implementation
  final serviceImpl = CalculatorServiceImpl();

  // Start the generated service
  final service = CalculatorService$Generated(bus, serviceImpl);
  await service.start();

  print('Calculator service started successfully');

  // Create a client for our calculator service
  final client = CalculatorClient$Generated(bus);

  try {
    // Demo 1: Basic arithmetic operations
    print('\n=== Demo 1: Basic Operations ===');

    final sum = await client.add(10, 5);
    print('10 + 5 = $sum');

    final difference = await client.subtract(10, 5);
    print('10 - 5 = $difference');

    final product = await client.multiply(10, 5);
    print('10 * 5 = $product');

    final quotient = await client.divide(10, 5);
    print('10 / 5 = $quotient');

    // Demo 2: Error handling
    print('\n=== Demo 2: Error Handling ===');
    try {
      await client.divide(10, 0);
    } catch (e) {
      print('Caught expected error: $e');
    }

    // Demo 3: Multiple concurrent requests
    print('\n=== Demo 3: Concurrent Operations ===');
    final futures = <Future<num>>[
      client.add(1, 2),
      client.multiply(3, 4),
      client.subtract(10, 3),
      client.add(100, 200),
    ];

    final results = await Future.wait(futures);
    print('Concurrent results: $results');
  } finally {
    // Clean up
    print('\nShutting down...');
    await service.stop();
    client.dispose();
    await bus.close();
    print('Example completed.');
  }
}
