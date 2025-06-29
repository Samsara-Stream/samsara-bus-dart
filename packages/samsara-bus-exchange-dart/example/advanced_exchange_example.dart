import 'dart:async';
import 'dart:math';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';

/// Advanced example showing a more complex application of the Exchange Pattern.
/// This example simulates a stock trading system with services and clients.
///
/// In a real application, the code generation would create the implementations
/// for the classes marked with @ExchangeClient and @ExchangeService.
void main() async {
  print('Advanced Exchange Pattern Example - Stock Trading System');
  print('======================================================');

  final bus = DefaultSamsaraBus();

  // Register topics for our various services
  _registerTopics(bus);

  // Start the services
  final marketDataService = MarketDataService$Generated(bus);
  final tradingService = TradingService$Generated(bus);
  final portfolioService = PortfolioService$Generated(bus);

  await marketDataService.start();
  await tradingService.start();
  await portfolioService.start();

  print('All services started successfully');

  // Create clients for our services
  final marketDataClient = MarketDataClient$Generated(bus);
  final tradingClient = TradingClient$Generated(bus);
  final portfolioClient = PortfolioClient$Generated(bus);

  try {
    // Demo 1: Get quotes for some stocks
    print('\n=== Demo 1: Market Data ===');
    final appleQuote = await marketDataClient.getQuote('AAPL');
    print(
        'Apple (AAPL) quote: \$${appleQuote.price.toStringAsFixed(2)} (${appleQuote.changePercent > 0 ? '+' : ''}${appleQuote.changePercent.toStringAsFixed(2)}%)');

    final googleQuote = await marketDataClient.getQuote('GOOG');
    print(
        'Google (GOOG) quote: \$${googleQuote.price.toStringAsFixed(2)} (${googleQuote.changePercent > 0 ? '+' : ''}${googleQuote.changePercent.toStringAsFixed(2)}%)');

    // Demo 2: Execute a trade
    print('\n=== Demo 2: Trading ===');
    final tradeRequest = TradeRequest(
      symbol: 'AAPL',
      quantity: 10,
      orderType: OrderType.market,
      side: TradeSide.buy,
    );

    final tradeResult = await tradingClient.executeTrade(tradeRequest);

    print('Trade executed: ${tradeResult.success ? 'SUCCESS' : 'FAILED'}');
    print('Order ID: ${tradeResult.orderId}');
    print(
        'Execution price: \$${tradeResult.executionPrice?.toStringAsFixed(2) ?? 'N/A'}');

    // Demo 3: Check portfolio
    print('\n=== Demo 3: Portfolio Management ===');
    final portfolio = await portfolioClient.getPortfolio('user123');

    print('Portfolio value: \$${portfolio.totalValue.toStringAsFixed(2)}');
    print('Holdings:');
    for (final position in portfolio.positions) {
      print(
          ' - ${position.symbol}: ${position.quantity} shares at \$${position.averagePrice.toStringAsFixed(2)} (Current: \$${position.currentPrice.toStringAsFixed(2)})');
    }

    // Demo 4: Error handling
    print('\n=== Demo 4: Error Handling ===');
    try {
      await marketDataClient.getQuote('INVALID');
    } catch (e) {
      print('Caught expected error: $e');
    }
  } finally {
    // Clean up
    print('\nShutting down services...');
    await marketDataService.stop();
    await tradingService.stop();
    await portfolioService.stop();

    marketDataClient.dispose();
    tradingClient.dispose();
    portfolioClient.dispose();

    await bus.close();
    print('Example completed.');
  }
}

void _registerTopics(SamsaraBus bus) {
  // Market data topics
  bus.registerTopic<Map<String, dynamic>>(
      'marketdata.request', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'marketdata.response', TopicType.publishSubject);

  // Trading topics
  bus.registerTopic<Map<String, dynamic>>(
      'trading.request', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'trading.response', TopicType.publishSubject);

  // Portfolio topics
  bus.registerTopic<Map<String, dynamic>>(
      'portfolio.request', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'portfolio.response', TopicType.publishSubject);
}

// ========== Data Models ==========

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
}

/// Position in a portfolio
class Position {
  final String symbol;
  final int quantity;
  final double averagePrice;
  final double currentPrice;

  Position({
    required this.symbol,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
  });

  double get marketValue => quantity * currentPrice;
  double get profitLoss => quantity * (currentPrice - averagePrice);
  double get profitLossPercent => ((currentPrice / averagePrice) - 1) * 100;

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity,
        'averagePrice': averagePrice,
        'currentPrice': currentPrice,
      };

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        symbol: json['symbol'] as String,
        quantity: json['quantity'] as int,
        averagePrice: json['averagePrice'] as double,
        currentPrice: json['currentPrice'] as double,
      );
}

/// Portfolio containing multiple positions
class Portfolio {
  final String userId;
  final List<Position> positions;
  final double cash;

  Portfolio({
    required this.userId,
    required this.positions,
    required this.cash,
  });

  double get totalValue => positions.fold(
        cash,
        (sum, position) => sum + position.marketValue,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'positions': positions.map((p) => p.toJson()).toList(),
        'cash': cash,
      };

  factory Portfolio.fromJson(Map<String, dynamic> json) => Portfolio(
        userId: json['userId'] as String,
        positions: (json['positions'] as List)
            .map((p) => Position.fromJson(p as Map<String, dynamic>))
            .toList(),
        cash: json['cash'] as double,
      );
}

// ========== Service Interfaces ==========

/// Market Data Service Interface
@ExchangeService('marketdata.request', 'marketdata.response')
abstract class MarketDataService {
  @ServiceMethod()
  StockQuote getQuote(String symbol);

  // Mock stock prices
  static final _stockPrices = {
    'AAPL': 187.5,
    'GOOG': 178.75,
    'MSFT': 425.25,
    'AMZN': 183.5,
    'META': 475.6,
  };
}

/// Concrete implementation of MarketDataService
class MarketDataServiceImpl implements MarketDataService {
  @override
  StockQuote getQuote(String symbol) {
    // In a real app, this would fetch from an exchange
    if (!MarketDataService._stockPrices.containsKey(symbol)) {
      throw Exception('Invalid stock symbol: $symbol');
    }

    final basePrice = MarketDataService._stockPrices[symbol]!;
    final random = Random();
    final change = random.nextDouble() * 2 - 1; // Between -1% and +1%
    final price = basePrice * (1 + change / 100);

    return StockQuote(
      symbol: symbol,
      price: price,
      changePercent: change,
      timestamp: DateTime.now(),
    );
  }
}

/// Trading Service Interface
@ExchangeService('trading.request', 'trading.response')
abstract class TradingService {
  @ServiceMethod()
  TradeResult executeTrade(TradeRequest request);
}

/// Concrete implementation of TradingService
class TradingServiceImpl implements TradingService {
  @override
  TradeResult executeTrade(TradeRequest request) {
    // In a real app, this would connect to a broker
    final random = Random();
    final success = random.nextDouble() > 0.1; // 90% chance of success
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    if (!success) {
      return TradeResult(
        success: false,
        orderId: orderId,
        errorMessage: 'Trade execution failed',
      );
    }

    // Get a reasonable execution price (with some slippage)
    final basePrice = MarketDataService._stockPrices[request.symbol] ?? 100.0;
    final slippage =
        (random.nextDouble() * 0.01) * (request.side == TradeSide.buy ? 1 : -1);
    final executionPrice = basePrice * (1 + slippage);

    return TradeResult(
      success: true,
      orderId: orderId,
      executionPrice: executionPrice,
    );
  }
}

/// Portfolio Service Interface
@ExchangeService('portfolio.request', 'portfolio.response')
abstract class PortfolioService {
  @ServiceMethod()
  Portfolio getPortfolio(String userId);
}

/// Concrete implementation of PortfolioService
class PortfolioServiceImpl implements PortfolioService {
  @override
  Portfolio getPortfolio(String userId) {
    // In a real app, this would fetch from a database
    final positions = <Position>[];
    final random = Random();

    // Create some random positions
    for (final entry in MarketDataService._stockPrices.entries) {
      if (random.nextBool()) {
        final symbol = entry.key;
        final currentPrice =
            entry.value * (1 + (random.nextDouble() * 0.1 - 0.05));
        final avgPrice = currentPrice * (1 + (random.nextDouble() * 0.2 - 0.1));
        final quantity = random.nextInt(100) + 1;

        positions.add(Position(
          symbol: symbol,
          quantity: quantity,
          averagePrice: avgPrice,
          currentPrice: currentPrice,
        ));
      }
    }

    return Portfolio(
      userId: userId,
      positions: positions,
      cash: 10000 + random.nextDouble() * 5000,
    );
  }
}

// ========== Client Interfaces ==========

/// Market Data Client Interface
@ExchangeClient('marketdata.request', 'marketdata.response')
abstract class MarketDataClient {
  @ExchangeMethod()
  Future<StockQuote> getQuote(String symbol);
}

/// Trading Client Interface
@ExchangeClient('trading.request', 'trading.response')
abstract class TradingClient {
  @ExchangeMethod(timeout: Duration(seconds: 10))
  Future<TradeResult> executeTrade(TradeRequest request);
}

/// Portfolio Client Interface
@ExchangeClient('portfolio.request', 'portfolio.response')
abstract class PortfolioClient {
  @ExchangeMethod()
  Future<Portfolio> getPortfolio(String userId);
}

// ========== Generated Service Implementations ==========
// In a real application, these would be generated by build_runner

class MarketDataService$Generated implements MarketDataService {
  final SamsaraBus _bus;
  late StreamSubscription _subscription;
  final MarketDataService _implementation = MarketDataServiceImpl();

  MarketDataService$Generated(this._bus);

  Future<void> start() async {
    _subscription = _bus
        .getStream<Map<String, dynamic>>('marketdata.request')
        .listen(_handleRequest);
  }

  Future<void> stop() async {
    await _subscription.cancel();
  }

  Future<void> _handleRequest(Map<String, dynamic> request) async {
    final operation = request['operation'] as String?;
    final params = request['params'] as Map<String, dynamic>?;
    final correlationId = request['correlationId'] as String?;

    if (operation == null || params == null || correlationId == null) {
      return;
    }

    Map<String, dynamic> response;

    try {
      if (operation == 'getQuote') {
        final paramsList = params['params'] as List<dynamic>;
        final symbol = paramsList[0] as String;
        final result = _implementation.getQuote(symbol);
        response = {
          'correlationId': correlationId,
          'result': result.toJson(),
          'success': true,
        };
      } else {
        throw Exception('Unknown operation: $operation');
      }
    } catch (e) {
      response = {
        'correlationId': correlationId,
        'error': e.toString(),
        'success': false,
      };
    }

    _bus.emit<Map<String, dynamic>>('marketdata.response', response);
  }

  @override
  StockQuote getQuote(String symbol) => _implementation.getQuote(symbol);
}

class TradingService$Generated implements TradingService {
  final SamsaraBus _bus;
  late StreamSubscription _subscription;
  final TradingService _implementation = TradingServiceImpl();

  TradingService$Generated(this._bus);

  Future<void> start() async {
    _subscription = _bus
        .getStream<Map<String, dynamic>>('trading.request')
        .listen(_handleRequest);
  }

  Future<void> stop() async {
    await _subscription.cancel();
  }

  Future<void> _handleRequest(Map<String, dynamic> request) async {
    final operation = request['operation'] as String?;
    final params = request['params'] as Map<String, dynamic>?;
    final correlationId = request['correlationId'] as String?;

    if (operation == null || params == null || correlationId == null) {
      return;
    }

    Map<String, dynamic> response;

    try {
      if (operation == 'executeTrade') {
        final paramsList = params['params'] as List<dynamic>;
        final tradeRequest =
            TradeRequest.fromJson(paramsList[0] as Map<String, dynamic>);
        final result = _implementation.executeTrade(tradeRequest);
        response = {
          'correlationId': correlationId,
          'result': result.toJson(),
          'success': true,
        };
      } else {
        throw Exception('Unknown operation: $operation');
      }
    } catch (e) {
      response = {
        'correlationId': correlationId,
        'error': e.toString(),
        'success': false,
      };
    }

    _bus.emit<Map<String, dynamic>>('trading.response', response);
  }

  @override
  TradeResult executeTrade(TradeRequest request) =>
      _implementation.executeTrade(request);
}

class PortfolioService$Generated implements PortfolioService {
  final SamsaraBus _bus;
  late StreamSubscription _subscription;
  final PortfolioService _implementation = PortfolioServiceImpl();

  PortfolioService$Generated(this._bus);

  Future<void> start() async {
    _subscription = _bus
        .getStream<Map<String, dynamic>>('portfolio.request')
        .listen(_handleRequest);
  }

  Future<void> stop() async {
    await _subscription.cancel();
  }

  Future<void> _handleRequest(Map<String, dynamic> request) async {
    final operation = request['operation'] as String?;
    final params = request['params'] as Map<String, dynamic>?;
    final correlationId = request['correlationId'] as String?;

    if (operation == null || params == null || correlationId == null) {
      return;
    }

    Map<String, dynamic> response;

    try {
      if (operation == 'getPortfolio') {
        final paramsList = params['params'] as List<dynamic>;
        final userId = paramsList[0] as String;
        final result = _implementation.getPortfolio(userId);
        response = {
          'correlationId': correlationId,
          'result': result.toJson(),
          'success': true,
        };
      } else {
        throw Exception('Unknown operation: $operation');
      }
    } catch (e) {
      response = {
        'correlationId': correlationId,
        'error': e.toString(),
        'success': false,
      };
    }

    _bus.emit<Map<String, dynamic>>('portfolio.response', response);
  }

  @override
  Portfolio getPortfolio(String userId) => _implementation.getPortfolio(userId);
}

// ========== Generated Client Implementations ==========
// In a real application, these would be generated by build_runner

class MarketDataClient$Generated extends ExchangeClientBase
    implements MarketDataClient {
  MarketDataClient$Generated(SamsaraBus bus)
      : super(bus, 'marketdata.request', 'marketdata.response');

  @override
  Future<StockQuote> getQuote(String symbol) async {
    final result = await makeRequest<Map<String, dynamic>>('getQuote', {
      'params': [symbol],
    });
    return StockQuote.fromJson(result);
  }
}

class TradingClient$Generated extends ExchangeClientBase
    implements TradingClient {
  TradingClient$Generated(SamsaraBus bus)
      : super(
          bus,
          'trading.request',
          'trading.response',
          defaultTimeout: Duration(seconds: 10),
        );

  @override
  Future<TradeResult> executeTrade(TradeRequest request) async {
    final result = await makeRequest<Map<String, dynamic>>('executeTrade', {
      'params': [request.toJson()],
    });
    return TradeResult.fromJson(result);
  }
}

class PortfolioClient$Generated extends ExchangeClientBase
    implements PortfolioClient {
  PortfolioClient$Generated(SamsaraBus bus)
      : super(bus, 'portfolio.request', 'portfolio.response');

  @override
  Future<Portfolio> getPortfolio(String userId) async {
    final result = await makeRequest<Map<String, dynamic>>('getPortfolio', {
      'params': [userId],
    });
    return Portfolio.fromJson(result);
  }
}
