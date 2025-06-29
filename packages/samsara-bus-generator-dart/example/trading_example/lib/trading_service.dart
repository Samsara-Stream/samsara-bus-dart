import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_exchange_dart/samsara_bus_exchange_dart.dart';
import 'models.dart';

part 'trading_service.g.dart';

/// Trading Service Interface
@ExchangeService('trading.request', 'trading.response')
abstract class TradingService {
  @ServiceMethod()
  TradeResult executeTrade(TradeRequest request);

  @ServiceMethod()
  List<TradeResult> getTradeHistory(int limit);
}
