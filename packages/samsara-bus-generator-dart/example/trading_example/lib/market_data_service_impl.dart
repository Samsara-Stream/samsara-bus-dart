import 'dart:math';
import 'market_data_service.dart';
import 'models.dart';

/// Concrete implementation of MarketDataService
class MarketDataServiceImpl implements MarketDataService {
  // Mock stock prices
  static final _stockPrices = {
    'AAPL': 187.5,
    'GOOG': 178.75,
    'MSFT': 425.25,
    'AMZN': 183.5,
    'META': 475.6,
  };

  @override
  StockQuote getQuote(String symbol) {
    // In a real app, this would fetch from an exchange
    if (!_stockPrices.containsKey(symbol)) {
      throw Exception('Invalid stock symbol: $symbol');
    }

    final basePrice = _stockPrices[symbol]!;
    final random = Random();
    final change = random.nextDouble() * 2 - 1; // Between -1% and +1%
    final price = basePrice * (1 + change / 100);

    print('Fetching quote for $symbol: \$${price.toStringAsFixed(2)}');

    return StockQuote(
      symbol: symbol,
      price: price,
      changePercent: change,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<StockQuote> getMultipleQuotes(List<String> symbols) {
    print('Fetching quotes for ${symbols.length} symbols');
    return symbols.map((symbol) => getQuote(symbol)).toList();
  }
}
