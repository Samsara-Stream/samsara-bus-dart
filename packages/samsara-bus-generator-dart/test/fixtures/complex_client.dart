import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

part 'complex_client.g.dart';

/// User data model
class User {
  final String id;
  final String name;
  final String email;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        isActive: json['isActive'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'isActive': isActive,
      };
}

/// Search filter
class UserFilter {
  final String? nameContains;
  final bool? isActive;
  final int? limit;

  const UserFilter({
    this.nameContains,
    this.isActive,
    this.limit,
  });

  factory UserFilter.fromJson(Map<String, dynamic> json) => UserFilter(
        nameContains: json['nameContains'] as String?,
        isActive: json['isActive'] as bool?,
        limit: json['limit'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'nameContains': nameContains,
        'isActive': isActive,
        'limit': limit,
      };
}

/// Complex client for testing advanced functionality
@ExchangeClient('user.request', 'user.response')
abstract class ComplexClient {
  @ExchangeMethod()
  Future<User> getUser(String id);

  @ExchangeMethod()
  Future<List<User>> getUsers(UserFilter filter);

  @ExchangeMethod()
  Future<List<String>> getUserIds();

  @ExchangeMethod()
  Future<void> updateUser(User user);

  @ExchangeMethod(operation: 'custom_search')
  Future<List<User>> searchUsers(String query, int limit);

  @ExchangeMethod()
  Future<Map<String, dynamic>> getUserStats(List<String> userIds);
}
