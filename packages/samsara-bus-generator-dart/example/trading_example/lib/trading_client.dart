import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'models.dart';

part 'trading_client.g.dart';

/// Trading Client Interface
@ExchangeClient('trading.request', 'trading.response')
abstract class TradingClient {
  @ExchangeMethod(timeout: Duration(seconds: 10))
  Future<TradeResult> executeTrade(TradeRequest request);

  @ExchangeMethod()
  Future<List<TradeResult>> getTradeHistory(int limit);
}
