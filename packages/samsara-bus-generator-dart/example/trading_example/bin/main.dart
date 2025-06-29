import 'dart:async';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';

import '../lib/market_data_client.dart';
import '../lib/market_data_service.dart';
import '../lib/market_data_service_impl.dart';
import '../lib/trading_client.dart';
import '../lib/trading_service.dart';
import '../lib/trading_service_impl.dart';
import '../lib/models.dart';

void main() async {
  print('Trading System using SamsaraBus Exchange Pattern');
  print('================================================');

  final bus = DefaultSamsaraBus();

  // Register topics for our services
  bus.registerTopic<Map<String, dynamic>>(
      'marketdata.request', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'marketdata.response', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'trading.request', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'trading.response', TopicType.publishSubject);

  // Create service implementations
  final marketDataImpl = MarketDataServiceImpl();
  final tradingImpl = TradingServiceImpl();

  // Start the generated services
  final marketDataService = MarketDataService$Generated(bus, marketDataImpl);
  final tradingService = TradingService$Generated(bus, tradingImpl);

  await marketDataService.start();
  await tradingService.start();

  print('All services started successfully');

  // Create clients for our services
  final marketDataClient = MarketDataClient$Generated(bus);
  final tradingClient = TradingClient$Generated(bus);

  try {
    // Demo 1: Get quotes for some stocks
    print('\n=== Demo 1: Market Data ===');
    final appleQuote = await marketDataClient.getQuote('AAPL');
    print('Apple (AAPL): $appleQuote');

    final googleQuote = await marketDataClient.getQuote('GOOG');
    print('Google (GOOG): $googleQuote');

    // Demo 2: Get multiple quotes
    print('\n=== Demo 2: Multiple Quotes ===');
    final quotes =
        await marketDataClient.getMultipleQuotes(['AAPL', 'GOOG', 'MSFT']);
    for (final quote in quotes) {
      print('$quote');
    }

    // Demo 3: Execute trades
    print('\n=== Demo 3: Trading ===');
    final tradeRequest1 = TradeRequest(
      symbol: 'AAPL',
      quantity: 10,
      orderType: OrderType.market,
      side: TradeSide.buy,
    );

    final tradeResult1 = await tradingClient.executeTrade(tradeRequest1);
    print('Trade 1: $tradeResult1');

    final tradeRequest2 = TradeRequest(
      symbol: 'GOOG',
      quantity: 5,
      orderType: OrderType.limit,
      side: TradeSide.sell,
      limitPrice: 180.0,
    );

    final tradeResult2 = await tradingClient.executeTrade(tradeRequest2);
    print('Trade 2: $tradeResult2');

    // Demo 4: Trade history
    print('\n=== Demo 4: Trade History ===');
    final history = await tradingClient.getTradeHistory(10);
    print('Recent trades:');
    for (final trade in history) {
      print('  $trade');
    }

    // Demo 5: Error handling
    print('\n=== Demo 5: Error Handling ===');
    try {
      await marketDataClient.getQuote('INVALID');
    } catch (e) {
      print('Caught expected error: $e');
    }

    // Demo 6: Concurrent requests
    print('\n=== Demo 6: Concurrent Operations ===');
    final futures = <Future>[
      marketDataClient.getQuote('AAPL'),
      marketDataClient.getQuote('GOOG'),
      tradingClient.executeTrade(TradeRequest(
        symbol: 'MSFT',
        quantity: 3,
        orderType: OrderType.market,
        side: TradeSide.buy,
      )),
    ];

    final results = await Future.wait(futures);
    print(
        'Concurrent results received: ${results.length} operations completed');
  } finally {
    // Clean up
    print('\nShutting down services...');
    await marketDataService.stop();
    await tradingService.stop();

    marketDataClient.dispose();
    tradingClient.dispose();

    await bus.close();
    print('Example completed.');
  }
}
