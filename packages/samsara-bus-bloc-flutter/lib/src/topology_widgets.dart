import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

/// A widget that listens directly to a topology and rebuilds when the topology emits new data.
class TopologyStreamBuilder<T> extends StatefulWidget {
  /// The SamsaraBus instance to use.
  final SamsaraBus bus;

  /// The topology to listen to.
  final TopologyInstance topology;

  /// Parameters to pass to the topology.
  final Map<String, dynamic> parameters;

  /// Builder function that receives the current data from the topology.
  final Widget Function(BuildContext context, T? data, bool hasData) builder;

  /// Optional initial data.
  final T? initialData;

  const TopologyStreamBuilder({
    super.key,
    required this.bus,
    required this.topology,
    this.parameters = const {},
    required this.builder,
    this.initialData,
  });

  @override
  State<TopologyStreamBuilder<T>> createState() =>
      _TopologyStreamBuilderState<T>();
}

class _TopologyStreamBuilderState<T> extends State<TopologyStreamBuilder<T>> {
  late TopologyProcessor _processor;
  T? _currentData;
  bool _hasData = false;
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _currentData = widget.initialData;
    _hasData = widget.initialData != null;
    _processor = TopologyProcessor(widget.bus);
    _setupTopologyStream();
  }

  void _setupTopologyStream() {
    try {
      final stream = _processor.process<T>(widget.topology, widget.parameters);
      _subscription = stream.listen((data) {
        if (mounted) {
          setState(() {
            _currentData = data;
            _hasData = true;
          });
        }
      });
    } catch (e) {
      throw StateError('Failed to setup topology stream: $e');
    }
  }

  @override
  void didUpdateWidget(TopologyStreamBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart stream if topology or parameters changed
    if (oldWidget.topology != widget.topology ||
        oldWidget.parameters != widget.parameters ||
        oldWidget.bus != widget.bus) {
      _subscription?.cancel();
      _processor.close();
      _processor = TopologyProcessor(widget.bus);
      _setupTopologyStream();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _processor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _currentData, _hasData);
  }
}

/// A widget that listens to a topology and calls a listener function when data changes.
class TopologyListener<T> extends StatefulWidget {
  /// The SamsaraBus instance to use.
  final SamsaraBus bus;

  /// The topology to listen to.
  final TopologyInstance topology;

  /// Parameters to pass to the topology.
  final Map<String, dynamic> parameters;

  /// Listener function called when topology emits new data.
  final void Function(BuildContext context, T data) listener;

  /// The child widget.
  final Widget child;

  const TopologyListener({
    super.key,
    required this.bus,
    required this.topology,
    this.parameters = const {},
    required this.listener,
    required this.child,
  });

  @override
  State<TopologyListener<T>> createState() => _TopologyListenerState<T>();
}

class _TopologyListenerState<T> extends State<TopologyListener<T>> {
  late TopologyProcessor _processor;
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _processor = TopologyProcessor(widget.bus);
    _setupTopologyStream();
  }

  void _setupTopologyStream() {
    try {
      final stream = _processor.process<T>(widget.topology, widget.parameters);
      _subscription = stream.listen((data) {
        if (mounted) {
          widget.listener(context, data);
        }
      });
    } catch (e) {
      throw StateError('Failed to setup topology stream: $e');
    }
  }

  @override
  void didUpdateWidget(TopologyListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart stream if topology or parameters changed
    if (oldWidget.topology != widget.topology ||
        oldWidget.parameters != widget.parameters ||
        oldWidget.bus != widget.bus) {
      _subscription?.cancel();
      _processor.close();
      _processor = TopologyProcessor(widget.bus);
      _setupTopologyStream();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _processor.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// A widget that combines TopologyBuilder and TopologyListener functionality.
class TopologyConsumer<T> extends StatelessWidget {
  /// The SamsaraBus instance to use.
  final SamsaraBus bus;

  /// The topology to listen to.
  final TopologyInstance topology;

  /// Parameters to pass to the topology.
  final Map<String, dynamic> parameters;

  /// Listener function called when topology emits new data.
  final void Function(BuildContext context, T data)? listener;

  /// Builder function that receives the current data from the topology.
  final Widget Function(BuildContext context, T? data, bool hasData) builder;

  /// Optional initial data.
  final T? initialData;

  const TopologyConsumer({
    super.key,
    required this.bus,
    required this.topology,
    this.parameters = const {},
    this.listener,
    required this.builder,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = TopologyStreamBuilder<T>(
      bus: bus,
      topology: topology,
      parameters: parameters,
      builder: builder,
      initialData: initialData,
    );

    if (listener != null) {
      result = TopologyListener<T>(
        bus: bus,
        topology: topology,
        parameters: parameters,
        listener: listener!,
        child: result,
      );
    }

    return result;
  }
}
