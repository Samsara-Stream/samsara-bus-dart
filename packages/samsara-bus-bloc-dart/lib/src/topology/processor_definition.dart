import 'combiner.dart';

/// A special symbol used to skip emitting an event from a processor.
const Symbol skip = Symbol('SKIP');

/// Defines a stream processor in a topology.
class ProcessorDefinition<TOutput> {
  /// Unique identifier for this processor.
  final String id;

  /// The names of inputs this processor depends on.
  final List<String> inputs;

  /// How to combine multiple input streams.
  final TopologyCombiner? combiner;

  /// The processing function that transforms inputs to output.
  /// Returns [skip] to skip emitting an event.
  final dynamic Function(List<dynamic>) fn;

  const ProcessorDefinition({
    required this.id,
    required this.inputs,
    required this.fn,
    this.combiner,
  });
}
