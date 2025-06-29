/// Stock quote information
class StockQuote {
  final String symbol;
  final double price;
  final double changePercent;
  final DateTime timestamp;

  StockQuote({
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'price': price,
        'changePercent': changePercent,
        'timestamp': timestamp.toIso8601String(),
      };

  factory StockQuote.fromJson(Map<String, dynamic> json) => StockQuote(
        symbol: json['symbol'] as String,
        price: json['price'] as double,
        changePercent: json['changePercent'] as double,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  @override
  String toString() =>
      '$symbol: \$${price.toStringAsFixed(2)} (${changePercent > 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%)';
}

/// Types of trade orders
enum OrderType {
  market,
  limit,
  stop,
}

/// Trade direction
enum TradeSide {
  buy,
  sell,
}

/// Request to execute a trade
class TradeRequest {
  final String symbol;
  final int quantity;
  final OrderType orderType;
  final TradeSide side;
  final double? limitPrice;

  TradeRequest({
    required this.symbol,
    required this.quantity,
    required this.orderType,
    required this.side,
    this.limitPrice,
  });

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity,
        'orderType': orderType.toString().split('.').last,
        'side': side.toString().split('.').last,
        'limitPrice': limitPrice,
      };

  factory TradeRequest.fromJson(Map<String, dynamic> json) => TradeRequest(
        symbol: json['symbol'] as String,
        quantity: json['quantity'] as int,
        orderType: OrderType.values.firstWhere(
            (e) => e.toString().split('.').last == json['orderType']),
        side: TradeSide.values
            .firstWhere((e) => e.toString().split('.').last == json['side']),
        limitPrice: json['limitPrice'] as double?,
      );

  @override
  String toString() =>
      '${side.name.toUpperCase()} $quantity $symbol @ ${orderType.name.toUpperCase()}${limitPrice != null ? ' \$${limitPrice!.toStringAsFixed(2)}' : ''}';
}

/// Result of a trade execution
class TradeResult {
  final bool success;
  final String orderId;
  final double? executionPrice;
  final String? errorMessage;

  TradeResult({
    required this.success,
    required this.orderId,
    this.executionPrice,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'orderId': orderId,
        'executionPrice': executionPrice,
        'errorMessage': errorMessage,
      };

  factory TradeResult.fromJson(Map<String, dynamic> json) => TradeResult(
        success: json['success'] as bool,
        orderId: json['orderId'] as String,
        executionPrice: json['executionPrice'] as double?,
        errorMessage: json['errorMessage'] as String?,
      );

  @override
  String toString() => success
      ? 'SUCCESS - Order $orderId executed at \$${executionPrice?.toStringAsFixed(2) ?? 'N/A'}'
      : 'FAILED - Order $orderId: $errorMessage';
}
