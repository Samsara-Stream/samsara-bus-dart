import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'package:source_gen/source_gen.dart';

/// Generator for creating Exchange client implementations
class ExchangeClientGenerator extends GeneratorForAnnotation<ExchangeClient> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'ExchangeClient annotation can only be applied to classes',
        element: element,
      );
    }

    if (!element.isAbstract) {
      throw InvalidGenerationSourceError(
        'ExchangeClient annotated classes must be abstract',
        element: element,
      );
    }

    final className = element.name;
    final generatedClassName = '${className}\$Generated';

    final requestTopic = annotation.read('requestTopic').stringValue;
    final responseTopic = annotation.read('responseTopic').stringValue;

    // Generate the class with proper header
    final buffer = StringBuffer();

    buffer.writeln(
        'class $generatedClassName extends ExchangeClientBase implements $className {');
    buffer.writeln('  $generatedClassName(SamsaraBus bus)');
    buffer
        .writeln('      : super(bus, \'$requestTopic\', \'$responseTopic\');');
    buffer.writeln();

    // Generate methods
    for (final method in element.methods) {
      if (method.isAbstract) {
        _generateClientMethod(buffer, method);
      }
    }

    buffer.writeln('  void dispose() {');
    buffer.writeln('    super.dispose();');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  void _generateClientMethod(StringBuffer buffer, MethodElement method) {
    final annotation = _getExchangeMethodAnnotation(method);
    final operationName = annotation?.read('operation').isNull == false
        ? annotation!.read('operation').stringValue
        : method.name;

    final returnType = _dartTypeToString(method.returnType);

    // Generate method signature
    buffer.write('  @override\n');
    buffer.write('  $returnType ${method.name}(');

    final paramList = <String>[];
    for (final param in method.parameters) {
      final typeName = _dartTypeToString(param.type);
      paramList.add('$typeName ${param.name}');
    }
    buffer.write(paramList.join(', '));
    buffer.writeln(') async {');

    // Generate parameter serialization
    final serializedParams = <String>[];
    for (final param in method.parameters) {
      final paramName = param.name;
      final paramType = _dartTypeToString(param.type);

      if (_isPrimitiveType(paramType) || _isPrimitiveListType(paramType)) {
        serializedParams.add(paramName);
      } else {
        serializedParams.add('$paramName.toJson()');
      }
    }

    // Generate method body
    if (method.returnType.isDartAsyncFuture) {
      // Extract the generic type from Future<T>
      final futureType = method.returnType as InterfaceType;
      final innerType = futureType.typeArguments.isNotEmpty
          ? _dartTypeToString(futureType.typeArguments.first)
          : 'dynamic';

      // Handle void return type
      if (innerType == 'void') {
        buffer.writeln('    await makeRequest<void>(\'$operationName\', {');
        buffer.writeln('      \'params\': [${serializedParams.join(', ')}],');
        buffer.writeln('    });');
        buffer.writeln('  }');
        buffer.writeln();
        return;
      }

      // Use the correct generic type for makeRequest
      // For primitive types, use the type directly
      // For complex types, use Map<String, dynamic> and deserialize
      String requestType;

      if (innerType == 'dynamic' ||
          _isPrimitiveType(innerType) ||
          _isBuiltInType(innerType)) {
        requestType = innerType;
      } else if (innerType.startsWith('List<')) {
        final listType = innerType.substring(5, innerType.length - 1);
        if (_isPrimitiveType(listType) || _isBuiltInType(listType)) {
          requestType = innerType;
        } else {
          requestType = 'List<dynamic>';
        }
      } else {
        requestType = 'Map<String, dynamic>';
      }

      buffer.writeln(
          '    final result = await makeRequest<$requestType>(\'$operationName\', {');
      buffer.writeln('      \'params\': [${serializedParams.join(', ')}],');
      buffer.writeln('    });');

      if (innerType == 'dynamic' ||
          _isPrimitiveType(innerType) ||
          _isBuiltInType(innerType)) {
        // For primitive types and built-in types, return the result directly
        buffer.writeln('    return result;');
      } else {
        // Handle custom types with fromJson
        if (innerType.startsWith('List<')) {
          final listType = innerType.substring(5, innerType.length - 1);
          if (_isPrimitiveType(listType) || _isBuiltInType(listType)) {
            buffer.writeln('    return result;');
          } else {
            buffer.writeln(
                '    return (result as List).map((item) => $listType.fromJson(item)).toList();');
          }
        } else {
          buffer.writeln('    return $innerType.fromJson(result);');
        }
      }
    }

    buffer.writeln('  }');
    buffer.writeln();
  }

  ConstantReader? _getExchangeMethodAnnotation(MethodElement method) {
    for (final metadata in method.metadata) {
      final obj = metadata.computeConstantValue();
      if (obj?.type?.element?.name == 'ExchangeMethod') {
        return ConstantReader(obj);
      }
    }
    return null;
  }

  String _dartTypeToString(DartType type) {
    return type.getDisplayString(withNullability: true);
  }

  bool _isPrimitiveType(String typeName) {
    return ['int', 'double', 'String', 'bool', 'num', 'dynamic']
        .contains(typeName);
  }

  bool _isBuiltInType(String typeName) {
    // Handle built-in types that don't have fromJson constructors
    return typeName.startsWith('Map<') ||
        typeName.startsWith('Set<') ||
        typeName == 'Object' ||
        typeName == 'DateTime';
  }

  bool _isPrimitiveListType(String typeName) {
    if (!typeName.startsWith('List<') || !typeName.endsWith('>')) {
      return false;
    }
    final elementType = typeName.substring(5, typeName.length - 1);
    return _isPrimitiveType(elementType);
  }
}
