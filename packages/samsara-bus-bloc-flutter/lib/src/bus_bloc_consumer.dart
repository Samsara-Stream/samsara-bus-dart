import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

import 'bus_bloc_builder.dart';
import 'bus_bloc_listener.dart';

/// A specialized BlocConsumer for BusBloc instances.
class BusBlocConsumer<B extends BusBloc<E, S>, E, S>
    extends BlocConsumer<B, S> {
  /// Creates a BusBlocConsumer that both listens to and builds from BusBloc state.
  const BusBlocConsumer({
    super.key,
    super.bloc,
    required super.listener,
    required super.builder,
    super.listenWhen,
    super.buildWhen,
  });
}

/// A consumer that can handle both state changes and bus events.
class BusEventConsumer<B extends BusBloc<E, S>, E, S> extends StatelessWidget {
  /// The BusBloc instance.
  final B? bloc;

  /// Listener function called when state changes.
  final void Function(BuildContext context, S state)? stateListener;

  /// Listener function called when bus events are received.
  final void Function(BuildContext context, BusEvent event)? busEventListener;

  /// Listener function called when topology events are received.
  final void Function(BuildContext context, TopologyEvent event)?
      topologyEventListener;

  /// Builder function that receives the current state and any recent bus events.
  final Widget Function(
      BuildContext context, S state, List<BusEvent> recentBusEvents) builder;

  /// Optional condition to determine when to call the state listener.
  final bool Function(S previous, S current)? listenWhen;

  /// Optional condition to determine when to rebuild.
  final bool Function(S previous, S current)? buildWhen;

  /// How long to keep bus events in the recent events list.
  final Duration eventRetentionDuration;

  const BusEventConsumer({
    super.key,
    this.bloc,
    this.stateListener,
    this.busEventListener,
    this.topologyEventListener,
    required this.builder,
    this.listenWhen,
    this.buildWhen,
    this.eventRetentionDuration = const Duration(seconds: 5),
  });

  @override
  Widget build(BuildContext context) {
    return BusEventListener<B, E, S>(
      bloc: bloc,
      stateListener: stateListener,
      busEventListener: busEventListener,
      topologyEventListener: topologyEventListener,
      listenWhen: listenWhen,
      child: BusEventBuilder<B, E, S>(
        bloc: bloc,
        builder: builder,
        buildWhen: buildWhen,
        eventRetentionDuration: eventRetentionDuration,
      ),
    );
  }
}
