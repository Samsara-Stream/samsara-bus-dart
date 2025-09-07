/// A Bloc extension for Samsara Bus with topology support.
///
/// This library provides extensions to the Bloc pattern that allow blocs to:
/// - Communicate with other components through SamsaraBus topics
/// - Define topologies that combine UI events and bus messages
/// - Use stream operators to process and transform events
/// - Handle complex event flows with multiple sources
library samsara_bus_bloc;

export 'src/bus_bloc.dart';
export 'src/topology_processor.dart';
export 'src/topology/topology_builder.dart';
export 'src/topology/topology_instance.dart';
export 'src/topology/processor_definition.dart';
export 'src/topology/topic_definition.dart';
export 'src/topology/parameter_definition.dart';
export 'src/topology/combiner.dart';
export 'src/models/bus_event.dart';
export 'src/topology/ui_stream_definition.dart';
export 'src/models/topology_event.dart';
