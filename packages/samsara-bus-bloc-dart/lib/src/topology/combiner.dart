import 'package:rxdart/rxdart.dart';

/// Defines how multiple streams are combined in a topology processor.
enum TopologyCombiner {
  /// Combines streams using combineLatest
  combineLatest,

  /// Combines streams using zip
  zip,

  /// Merges streams
  merge,

  /// Uses withLatestFrom for combining streams
  withLatestFrom,
}

/// Extension methods for TopologyCombiner to provide actual stream combination logic.
extension TopologyCombinerExtension on TopologyCombiner {
  /// Combines the given streams according to the combiner type.
  Stream<List<dynamic>> combine(List<Stream<dynamic>> streams) {
    if (streams.isEmpty) {
      return Stream.empty();
    }
    if (streams.length == 1) {
      return streams.first.map((value) => [value]);
    }

    switch (this) {
      case TopologyCombiner.combineLatest:
        return Rx.combineLatestList(streams);
      case TopologyCombiner.zip:
        return Rx.zipList(streams);
      case TopologyCombiner.merge:
        return Rx.merge(streams).map((value) => [value]);
      case TopologyCombiner.withLatestFrom:
        if (streams.length < 2) {
          throw ArgumentError(
              'withLatestFrom requires at least 2 streams, got ${streams.length}');
        }
        var primaryStream = streams.first;
        var otherStreams = streams.skip(1).toList();
        return primaryStream.withLatestFrom(
          otherStreams.length == 1
              ? otherStreams.first
              : Rx.combineLatestList(otherStreams),
          (first, others) => otherStreams.length == 1
              ? [first, others]
              : [first, ...others as List],
        );
    }
  }
}
