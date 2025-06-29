import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'package:source_gen/source_gen.dart';

/// Generator for creating Exchange service implementations
class ExchangeServiceGenerator extends GeneratorForAnnotation<ExchangeService> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'ExchangeService annotation can only be applied to classes',
        element: element,
      );
    }

    if (!element.isAbstract) {
      throw InvalidGenerationSourceError(
        'ExchangeService annotated classes must be abstract',
        element: element,
      );
    }

    final className = element.name;
    final generatedClassName = '${className}\$Generated';

    final requestTopic = annotation.read('requestTopic').stringValue;
    final responseTopic = annotation.read('responseTopic').stringValue;

    // Generate the class with proper header
    final buffer = StringBuffer();

    buffer.writeln('class $generatedClassName extends ExchangeServiceBase {');
    buffer.writeln('  final $className _implementation;');
    buffer.writeln();
    buffer
        .writeln('  $generatedClassName(SamsaraBus bus, this._implementation)');
    buffer
        .writeln('      : super(bus, \'$requestTopic\', \'$responseTopic\');');
    buffer.writeln();

    // Generate handleOperation method
    _generateHandleOperationMethod(buffer, element);

    buffer.writeln('}');

    return buffer.toString();
  }

  void _generateHandleOperationMethod(
      StringBuffer buffer, ClassElement element) {
    buffer.writeln('  @override');
    buffer.writeln(
        '  Future<dynamic> handleOperation(String operation, Map<String, dynamic> params) async {');
    buffer
        .writeln('    final paramsList = params[\'params\'] as List<dynamic>;');
    buffer.writeln();
    buffer.writeln('    switch (operation) {');

    for (final method in element.methods) {
      if (method.isAbstract) {
        final annotation = _getServiceMethodAnnotation(method);
        final operationName = annotation?.read('operation').isNull == false
            ? annotation!.read('operation').stringValue
            : method.name;

        final parameters = method.parameters.map((p) => p.name).toList();
        final parameterCasts = <String>[];

        for (int i = 0; i < parameters.length; i++) {
          final param = method.parameters[i];
          final typeName = _dartTypeToString(param.type);
          if (typeName.startsWith('List<')) {
            final listType = typeName.substring(5, typeName.length - 1);
            if (_isPrimitiveType(listType)) {
              parameterCasts.add('List<$listType>.from(paramsList[$i])');
            } else {
              parameterCasts.add(
                  '(paramsList[$i] as List).map((item) => $listType.fromJson(item)).toList()');
            }
          } else if (_isPrimitiveType(typeName)) {
            parameterCasts.add('paramsList[$i] as $typeName');
          } else {
            parameterCasts.add('$typeName.fromJson(paramsList[$i])');
          }
        }

        final methodCall =
            '_implementation.${method.name}(${parameterCasts.join(', ')})';

        buffer.writeln('      case \'$operationName\':');

        final returnType = _dartTypeToString(method.returnType);
        if (returnType == 'void') {
          buffer.writeln('        $methodCall;');
          buffer.writeln('        return null;');
        } else if (_isPrimitiveType(returnType)) {
          buffer.writeln('        return $methodCall;');
        } else if (returnType.startsWith('List<')) {
          final listType = returnType.substring(5, returnType.length - 1);
          if (_isPrimitiveType(listType)) {
            buffer.writeln('        return $methodCall;');
          } else {
            buffer.writeln(
                '        return $methodCall.map((item) => item.toJson()).toList();');
          }
        } else {
          buffer.writeln('        return $methodCall.toJson();');
        }
      }
    }

    buffer.writeln('      default:');
    buffer.writeln(
        '        throw Exception(\'Unknown operation: \$operation\');');
    buffer.writeln('    }');
    buffer.writeln('  }');
  }

  ConstantReader? _getServiceMethodAnnotation(MethodElement method) {
    for (final metadata in method.metadata) {
      final obj = metadata.computeConstantValue();
      if (obj?.type?.element?.name == 'ServiceMethod') {
        return ConstantReader(obj);
      }
    }
    return null;
  }

  String _dartTypeToString(DartType type) {
    return type.getDisplayString(withNullability: true);
  }

  bool _isPrimitiveType(String typeName) {
    return ['int', 'double', 'String', 'bool', 'num', 'dynamic', 'void']
        .contains(typeName);
  }
}
