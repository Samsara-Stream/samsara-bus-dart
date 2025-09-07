import 'dart:async';

/// Defines a UI stream source in a topology.
class UIStreamDefinition<T> {
  /// The name used to reference this stream within the topology.
  final String name;

  /// The UI stream controller that can be used to emit events from UI.
  final StreamController<T> controller;

  /// The actual stream that will be used in the topology.
  Stream<T> get stream => controller.stream;

  UIStreamDefinition({
    required this.name,
    StreamController<T>? controller,
  }) : controller = controller ?? StreamController<T>.broadcast();

  /// Emits a value to this UI stream.
  void emit(T value) {
    if (!controller.isClosed) {
      controller.add(value);
    }
  }

  /// Closes the stream controller.
  void close() {
    controller.close();
  }
}
