import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

/// A specialized BlocListener for BusBloc instances.
class BusBlocListener<B extends BusBloc<E, S>, E, S>
    extends BlocListener<B, S> {
  /// Creates a BusBlocListener that listens to BusBloc state changes.
  const BusBlocListener({
    super.key,
    super.bloc,
    required super.listener,
    super.listenWhen,
    super.child,
  });
}

/// A listener that can handle both state changes and bus events.
class BusEventListener<B extends BusBloc<E, S>, E, S> extends StatefulWidget {
  /// The BusBloc instance to listen to.
  final B? bloc;

  /// Listener function called when state changes.
  final void Function(BuildContext context, S state)? stateListener;

  /// Listener function called when bus events are received.
  final void Function(BuildContext context, BusEvent event)? busEventListener;

  /// Listener function called when topology events are received.
  final void Function(BuildContext context, TopologyEvent event)?
      topologyEventListener;

  /// Optional condition to determine when to call the state listener.
  final bool Function(S previous, S current)? listenWhen;

  /// The child widget.
  final Widget? child;

  const BusEventListener({
    super.key,
    this.bloc,
    this.stateListener,
    this.busEventListener,
    this.topologyEventListener,
    this.listenWhen,
    this.child,
  });

  @override
  State<BusEventListener<B, E, S>> createState() =>
      _BusEventListenerState<B, E, S>();
}

class _BusEventListenerState<B extends BusBloc<E, S>, E, S>
    extends State<BusEventListener<B, E, S>> {
  late B _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc ?? context.read<B>();
  }

  @override
  void didUpdateWidget(BusEventListener<B, E, S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldBloc = oldWidget.bloc ?? _bloc;
    final currentBloc = widget.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result = widget.child ?? const SizedBox();

    if (widget.stateListener != null) {
      result = BlocListener<B, S>(
        bloc: _bloc,
        listener: widget.stateListener!,
        listenWhen: widget.listenWhen,
        child: result,
      );
    }

    return result;
  }
}
