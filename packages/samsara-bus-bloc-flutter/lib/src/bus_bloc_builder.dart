import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

/// A specialized BlocBuilder for BusBloc instances.
class BusBlocBuilder<B extends BusBloc<E, S>, E, S> extends BlocBuilder<B, S> {
  /// Creates a BusBlocBuilder that rebuilds when the BusBloc state changes.
  const BusBlocBuilder({
    super.key,
    super.bloc,
    required super.builder,
    super.buildWhen,
  });
}

/// A builder that can listen to both bus events and state changes.
class BusEventBuilder<B extends BusBloc<E, S>, E, S> extends StatefulWidget {
  /// The BusBloc instance to listen to.
  final B? bloc;

  /// Builder function that receives the current state and any recent bus events.
  final Widget Function(
      BuildContext context, S state, List<BusEvent> recentBusEvents) builder;

  /// Optional condition to determine when to rebuild.
  final bool Function(S previous, S current)? buildWhen;

  /// How long to keep bus events in the recent events list.
  final Duration eventRetentionDuration;

  const BusEventBuilder({
    super.key,
    this.bloc,
    required this.builder,
    this.buildWhen,
    this.eventRetentionDuration = const Duration(seconds: 5),
  });

  @override
  State<BusEventBuilder<B, E, S>> createState() =>
      _BusEventBuilderState<B, E, S>();
}

class _BusEventBuilderState<B extends BusBloc<E, S>, E, S>
    extends State<BusEventBuilder<B, E, S>> {
  final List<BusEvent> _recentBusEvents = [];
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
  }

  @override
  void didUpdateWidget(BusEventBuilder<B, E, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? _bloc;
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
    }
  }

  void _addBusEvent(BusEvent event) {
    setState(() {
      _recentBusEvents.add(event);
      // Remove old events
      final cutoff = DateTime.now().subtract(widget.eventRetentionDuration);
      _recentBusEvents.removeWhere((e) => e.timestamp.isBefore(cutoff));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      bloc: _bloc,
      buildWhen: widget.buildWhen,
      builder: (context, state) {
        // Clean up old events
        final cutoff = DateTime.now().subtract(widget.eventRetentionDuration);
        _recentBusEvents.removeWhere((e) => e.timestamp.isBefore(cutoff));

        return widget.builder(
            context, state, List.unmodifiable(_recentBusEvents));
      },
    );
  }
}
