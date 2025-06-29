import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'models.dart';

part 'market_data_client.g.dart';

/// Market Data Client Interface
@ExchangeClient('marketdata.request', 'marketdata.response')
abstract class MarketDataClient {
  @ExchangeMethod()
  Future<StockQuote> getQuote(String symbol);

  @ExchangeMethod()
  Future<List<StockQuote>> getMultipleQuotes(List<String> symbols);
}
