import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'models.dart';

part 'market_data_service.g.dart';

/// Market Data Service Interface
@ExchangeService('marketdata.request', 'marketdata.response')
abstract class MarketDataService {
  @ServiceMethod()
  StockQuote getQuote(String symbol);

  @ServiceMethod()
  List<StockQuote> getMultipleQuotes(List<String> symbols);
}
