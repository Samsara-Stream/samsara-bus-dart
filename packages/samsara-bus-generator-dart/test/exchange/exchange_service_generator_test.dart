import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:samsara_bus_generator_dart/exchange/exchange_service_generator.dart';
import 'package:test/test.dart';

void main() {
  group('ExchangeServiceGenerator', () {
    late ExchangeServiceGenerator generator;

    setUp(() {
      generator = ExchangeServiceGenerator();
    });

    test('should generate service for simple interface', () async {
      const input = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeService('test.request', 'test.response')
abstract class TestService {
  @ServiceMethod()
  String getMessage();
  
  @ServiceMethod()
  int getNumber(String input);
  
  @ServiceMethod()
  void performAction();
}
''';

      await testBuilder(
        PartBuilder([generator], '.g.dart'),
        {
          'pkg|lib/test_service.dart': input,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('should generate service with complex types', () async {
      const input = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

class User {
  final String name;
  final int age;
  
  User({required this.name, required this.age});
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'],
    age: json['age'],
  );
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'age': age,
  };
}

@ExchangeService('user.request', 'user.response')
abstract class UserService {
  @ServiceMethod()
  User getUser(String id);
  
  @ServiceMethod()
  List<User> getUsers();
  
  @ServiceMethod()
  void updateUser(User user);
}
''';

      await testBuilder(
        PartBuilder([generator], '.g.dart'),
        {
          'pkg|lib/user_service.dart': input,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('should generate service with primitive list types', () async {
      const input = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeService('data.request', 'data.response')
abstract class DataService {
  @ServiceMethod()
  List<int> getNumbers();
  
  @ServiceMethod()
  List<String> processNumbers(List<int> numbers);
}
''';

      await testBuilder(
        PartBuilder([generator], '.g.dart'),
        {
          'pkg|lib/data_service.dart': input,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('should handle custom operation names', () async {
      const input = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeService('calc.request', 'calc.response')
abstract class CalculatorService {
  @ServiceMethod(operation: 'add_numbers')
  int add(int a, int b);
  
  @ServiceMethod(operation: 'multiply_values')
  int multiply(int a, int b);
}
''';

      await testBuilder(
        PartBuilder([generator], '.g.dart'),
        {
          'pkg|lib/calculator_service.dart': input,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('should generate service with mixed parameter types', () async {
      const input = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

class RequestData {
  final String query;
  final Map<String, String> filters;
  
  RequestData({required this.query, required this.filters});
  
  factory RequestData.fromJson(Map<String, dynamic> json) => RequestData(
    query: json['query'],
    filters: Map<String, String>.from(json['filters']),
  );
  
  Map<String, dynamic> toJson() => {
    'query': query,
    'filters': filters,
  };
}

@ExchangeService('search.request', 'search.response')
abstract class SearchService {
  @ServiceMethod()
  List<String> search(RequestData request, int limit, bool sortAsc);
  
  @ServiceMethod()
  Map<String, int> getStatistics(List<String> categories);
}
''';

      await testBuilder(
        PartBuilder([generator], '.g.dart'),
        {
          'pkg|lib/search_service.dart': input,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });
  });
}
