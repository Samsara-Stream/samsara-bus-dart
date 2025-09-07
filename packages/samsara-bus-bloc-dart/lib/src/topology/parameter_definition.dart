/// Defines a parameter that can be used in a topology.
class ParameterDefinition<T> {
  /// The name of the parameter.
  final String name;

  /// The validator function for the parameter type.
  final bool Function(dynamic) validator;

  const ParameterDefinition({
    required this.name,
    required this.validator,
  });
}
