import 'package:build_test/build_test.dart';
import 'package:source_gen/source_gen.dart';
import 'package:samsara_bus_generator_dart/exchange/exchange_client_generator.dart';
import 'package:test/test.dart';

void main() {
  group('ExchangeClientGenerator', () {
    late ExchangeClientGenerator generator;

    setUp(() {
      generator = ExchangeClientGenerator();
    });

    test('should generate client for simple interface', () async {
      const input = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeClient('test.request', 'test.response')
abstract class TestClient {
  @ExchangeMethod()
  Future<String> getMessage();
  
  @ExchangeMethod()
  Future<int> getNumber(String input);
}
''';

      await testBuilder(
        PartBuilder([generator], '.g.dart'),
        {
          'pkg|lib/test_client.dart': input,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('should generate client with complex types', () async {
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

@ExchangeClient('user.request', 'user.response')
abstract class UserClient {
  @ExchangeMethod()
  Future<User> getUser(String id);
  
  @ExchangeMethod()
  Future<List<User>> getUsers();
  
  @ExchangeMethod()
  Future<void> updateUser(User user);
}
''';

      await testBuilder(
        PartBuilder([generator], '.g.dart'),
        {
          'pkg|lib/user_client.dart': input,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('should generate client with primitive list types', () async {
      const input = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeClient('data.request', 'data.response')
abstract class DataClient {
  @ExchangeMethod()
  Future<List<int>> getNumbers();
  
  @ExchangeMethod()
  Future<List<String>> getStrings(List<int> ids);
}
''';

      await testBuilder(
        PartBuilder([generator], '.g.dart'),
        {
          'pkg|lib/data_client.dart': input,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });

    test('should handle custom operation names', () async {
      const input = '''
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

@ExchangeClient('calc.request', 'calc.response')
abstract class CalculatorClient {
  @ExchangeMethod(operation: 'add_numbers')
  Future<int> add(int a, int b);
  
  @ExchangeMethod(operation: 'multiply_values')
  Future<int> multiply(int a, int b);
}
''';

      await testBuilder(
        PartBuilder([generator], '.g.dart'),
        {
          'pkg|lib/calculator_client.dart': input,
        },
        reader: await PackageAssetReader.currentIsolate(),
      );
    });
  });
}
