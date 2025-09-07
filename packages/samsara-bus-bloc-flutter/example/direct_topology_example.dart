import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';
import 'package:samsara_bus_bloc_flutter/samsara_bus_bloc_flutter.dart';

// Example showing direct topology listening in Flutter widgets

class DirectTopologyApp extends StatelessWidget {
  final SamsaraBus bus;

  const DirectTopologyApp({super.key, required this.bus});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Direct Topology Example',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: DirectTopologyPage(bus: bus),
    );
  }
}

class DirectTopologyPage extends StatefulWidget {
  final SamsaraBus bus;

  const DirectTopologyPage({super.key, required this.bus});

  @override
  State<DirectTopologyPage> createState() => _DirectTopologyPageState();
}

class _DirectTopologyPageState extends State<DirectTopologyPage> {
  late final TopologyInstance _dataProcessingTopology;
  late final TopologyInstance _uiInteractionTopology;
  int _clickCount = 0;

  @override
  void initState() {
    super.initState();
    _setupTopologies();
  }

  void _setupTopologies() {
    // Topology 1: Process sensor data from bus
    _dataProcessingTopology = topology('data_processing')
        .param<double>('threshold', (t) => t.number())
        .topic('sensor_data', 'sensors')
        .topic('calibration_data', 'calibration')
        .proc(processor(
          id: 'data_processor',
          inputs: ['sensor_data', 'calibration_data'],
          combiner: TopologyCombiner.combineLatest,
          fn: (inputs) {
            final sensorValue = inputs[0] as double? ?? 0.0;
            final calibrationOffset = inputs[1] as double? ?? 0.0;
            final processed = sensorValue + calibrationOffset;

            return {
              'raw': sensorValue,
              'calibrated': processed,
              'status': processed > 50.0 ? 'HIGH' : 'NORMAL',
              'timestamp': DateTime.now().millisecondsSinceEpoch,
            };
          },
        ))
        .output('data_processor')
        .build();

    // Topology 2: Combine UI interactions with external events
    _uiInteractionTopology = topology('ui_interactions')
        .uiStream<String>('button_clicks')
        .topic('external_events', 'external')
        .proc(processor(
          id: 'interaction_processor',
          inputs: ['button_clicks', 'external_events'],
          combiner: TopologyCombiner.combineLatest,
          fn: (inputs) {
            final buttonAction = inputs[0] as String? ?? 'none';
            final externalEvent = inputs[1] as String? ?? 'none';

            if (buttonAction == 'none' || externalEvent == 'none') {
              return skip;
            }

            return {
              'action': buttonAction,
              'external': externalEvent,
              'combined': '$buttonAction + $externalEvent',
              'score': buttonAction.length + externalEvent.length,
            };
          },
        ))
        .output('interaction_processor')
        .build();
  }

  void _emitButtonClick(String action) {
    setState(() {
      _clickCount++;
    });

    // Emit to UI stream in topology
    final topologyProcessor = TopologyProcessor(widget.bus);
    topologyProcessor.emitToUIStream(
        _uiInteractionTopology, 'button_clicks', action);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct Topology Listening'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sensor data processing section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sensor Data Processing',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    TopologyStreamBuilder<Map<String, dynamic>>(
                      bus: widget.bus,
                      topology: _dataProcessingTopology,
                      parameters: {'threshold': 50.0},
                      builder: (context, data, hasData) {
                        if (!hasData) {
                          return const Text('Waiting for sensor data...');
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Raw Value: ${data!['raw']}'),
                            Text('Calibrated: ${data['calibrated']}'),
                            Text(
                              'Status: ${data['status']}',
                              style: TextStyle(
                                color: data['status'] == 'HIGH'
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Timestamp: ${data['timestamp']}'),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            widget.bus.emit('sensors', 25.5);
                            widget.bus.emit('calibration', 5.0);
                          },
                          child: const Text('Send Low Data'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            widget.bus.emit('sensors', 75.3);
                            widget.bus.emit('calibration', 2.5);
                          },
                          child: const Text('Send High Data'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // UI interaction section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UI + External Events',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Button clicks: $_clickCount'),
                    const SizedBox(height: 16),

                    // Topology consumer that both listens and builds
                    TopologyConsumer<Map<String, dynamic>>(
                      bus: widget.bus,
                      topology: _uiInteractionTopology,
                      listener: (context, data) {
                        // Show snackbar when topology processes new data
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Processed: ${data['combined']}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      builder: (context, data, hasData) {
                        if (!hasData) {
                          return const Text(
                              'Perform actions to see results...');
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Action: ${data!['action']}'),
                            Text('External: ${data['external']}'),
                            Text('Combined: ${data['combined']}'),
                            Text('Score: ${data['score']}'),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () => _emitButtonClick('SAVE'),
                          child: const Text('Save'),
                        ),
                        ElevatedButton(
                          onPressed: () => _emitButtonClick('LOAD'),
                          child: const Text('Load'),
                        ),
                        ElevatedButton(
                          onPressed: () => _emitButtonClick('DELETE'),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.bus.emit('external', 'system_update');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Send External Event'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Pure topology listener (no UI rebuild)
            TopologyListener<Map<String, dynamic>>(
              bus: widget.bus,
              topology: _dataProcessingTopology,
              parameters: {'threshold': 50.0},
              listener: (context, data) {
                // Log high values
                if (data['status'] == 'HIGH') {
                  print('🚨 HIGH VALUE DETECTED: ${data['calibrated']}');
                }
              },
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Background Monitoring Active\n'
                    '(Check console for high value alerts)',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  // Create and configure the bus
  final bus = DefaultSamsaraBus();
  bus.registerTopic<double>('sensors', TopicType.publishSubject);
  bus.registerTopic<double>('calibration', TopicType.behaviorSubject);
  bus.registerTopic<String>('external', TopicType.publishSubject);

  runApp(DirectTopologyApp(bus: bus));
}
