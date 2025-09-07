import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

/// A specialized BlocProvider for BusBloc instances.
class BusBlocProvider<B extends BusBloc<E, S>, E, S> extends BlocProvider<B> {
  /// Creates a BusBlocProvider that automatically manages the BusBloc lifecycle.
  const BusBlocProvider({
    super.key,
    required super.create,
    super.child,
    super.lazy,
  });

  /// Creates a BusBlocProvider that provides an existing BusBloc instance.
  const BusBlocProvider.value({
    super.key,
    required super.value,
    super.child,
  }) : super.value();

  /// Gets the BusBloc instance from the widget tree.
  static B of<B extends BusBloc<E, S>, E, S>(BuildContext context) {
    return BlocProvider.of<B>(context);
  }
}
