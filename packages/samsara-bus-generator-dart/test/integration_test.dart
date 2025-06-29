import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:samsara_bus_generator_dart/exchange/exchange_client_generator.dart';
import 'package:samsara_bus_generator_dart/exchange/exchange_service_generator.dart';
import 'package:test/test.dart';

void main() {
  group('Exchange Generator Integration Tests', () {
    test('should generate both client and service for the same interface',
        () async {
      const clientInput = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeClient('calculator.request', 'calculator.response')
abstract class CalculatorClient {
  @ExchangeMethod()
  Future<int> add(int a, int b);
  
  @ExchangeMethod()
  Future<int> subtract(int a, int b);
  
  @ExchangeMethod()
  Future<double> divide(int a, int b);
}
''';

      const serviceInput = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeService('calculator.request', 'calculator.response')
abstract class CalculatorService {
  @ServiceMethod()
  int add(int a, int b);
  
  @ServiceMethod()
  int subtract(int a, int b);
  
  @ServiceMethod()
  double divide(int a, int b);
}
''';

      // Test client generation
      await testBuilder(
        PartBuilder([ExchangeClientGenerator()], '.g.dart'),
        {
          'pkg|lib/calculator_client.dart': clientInput,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );

      // Test service generation
      await testBuilder(
        PartBuilder([ExchangeServiceGenerator()], '.g.dart'),
        {
          'pkg|lib/calculator_service.dart': serviceInput,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('should generate code with complex data models', () async {
      const sharedModels = '''
class Task {
  final String id;
  final String title;
  final bool completed;
  final DateTime? dueDate;
  
  Task({
    required this.id,
    required this.title,
    required this.completed,
    this.dueDate,
  });
  
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    completed: json['completed'],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'completed': completed,
    'dueDate': dueDate?.toIso8601String(),
  };
}

class TaskFilter {
  final bool? completed;
  final DateTime? dueBefore;
  final String? titleContains;
  
  TaskFilter({this.completed, this.dueBefore, this.titleContains});
  
  factory TaskFilter.fromJson(Map<String, dynamic> json) => TaskFilter(
    completed: json['completed'],
    dueBefore: json['dueBefore'] != null ? DateTime.parse(json['dueBefore']) : null,
    titleContains: json['titleContains'],
  );
  
  Map<String, dynamic> toJson() => {
    'completed': completed,
    'dueBefore': dueBefore?.toIso8601String(),
    'titleContains': titleContains,
  };
}
''';

      const clientInput = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

$sharedModels

@ExchangeClient('tasks.request', 'tasks.response')
abstract class TaskClient {
  @ExchangeMethod()
  Future<List<Task>> getTasks(TaskFilter filter);
  
  @ExchangeMethod()
  Future<Task> createTask(Task task);
  
  @ExchangeMethod()
  Future<Task> updateTask(String id, Task task);
  
  @ExchangeMethod()
  Future<void> deleteTask(String id);
  
  @ExchangeMethod()
  Future<List<String>> getTaskIds();
}
''';

      const serviceInput = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

$sharedModels

@ExchangeService('tasks.request', 'tasks.response')
abstract class TaskService {
  @ServiceMethod()
  List<Task> getTasks(TaskFilter filter);
  
  @ServiceMethod()
  Task createTask(Task task);
  
  @ServiceMethod()
  Task updateTask(String id, Task task);
  
  @ServiceMethod()
  void deleteTask(String id);
  
  @ServiceMethod()
  List<String> getTaskIds();
}
''';

      // Test complex client generation
      await testBuilder(
        PartBuilder([ExchangeClientGenerator()], '.g.dart'),
        {
          'pkg|lib/task_client.dart': clientInput,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );

      // Test complex service generation
      await testBuilder(
        PartBuilder([ExchangeServiceGenerator()], '.g.dart'),
        {
          'pkg|lib/task_service.dart': serviceInput,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('should handle edge cases and special types', () async {
      const clientInput = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeClient('edge.request', 'edge.response')
abstract class EdgeCaseClient {
  @ExchangeMethod()
  Future<dynamic> getDynamic();
  
  @ExchangeMethod()
  Future<Map<String, dynamic>> getMap();
  
  @ExchangeMethod()
  Future<List<dynamic>> getDynamicList();
  
  @ExchangeMethod()
  Future<List<Map<String, dynamic>>> getMapList();
  
  @ExchangeMethod()
  Future<void> noReturn(String input);
}
''';

      const serviceInput = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeService('edge.request', 'edge.response')
abstract class EdgeCaseService {
  @ServiceMethod()
  dynamic getDynamic();
  
  @ServiceMethod()
  Map<String, dynamic> getMap();
  
  @ServiceMethod()
  List<dynamic> getDynamicList();
  
  @ServiceMethod()
  List<Map<String, dynamic>> getMapList();
  
  @ServiceMethod()
  void noReturn(String input);
}
''';

      // Test edge case client generation
      await testBuilder(
        PartBuilder([ExchangeClientGenerator()], '.g.dart'),
        {
          'pkg|lib/edge_case_client.dart': clientInput,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );

      // Test edge case service generation
      await testBuilder(
        PartBuilder([ExchangeServiceGenerator()], '.g.dart'),
        {
          'pkg|lib/edge_case_service.dart': serviceInput,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });
  });
}
