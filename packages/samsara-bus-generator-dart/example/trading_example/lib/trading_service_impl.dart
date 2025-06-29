import 'dart:math';
import 'trading_service.dart';
import 'models.dart';

/// Concrete implementation of TradingService
class TradingServiceImpl implements TradingService {
  final List<TradeResult> _tradeHistory = [];

  @override
  TradeResult executeTrade(TradeRequest request) {
    print('Executing trade: $request');

    // In a real app, this would connect to a broker
    final random = Random();
    final success = random.nextDouble() > 0.1; // 90% chance of success
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    TradeResult result;
    if (!success) {
      result = TradeResult(
        success: false,
        orderId: orderId,
        errorMessage: 'Trade execution failed',
      );
    } else {
      // Get a reasonable execution price (with some slippage)
      final basePrice = 150.0; // Mock base price
      final slippage = (random.nextDouble() * 0.01) *
          (request.side == TradeSide.buy ? 1 : -1);
      final executionPrice = basePrice * (1 + slippage);

      result = TradeResult(
        success: true,
        orderId: orderId,
        executionPrice: executionPrice,
      );
    }

    _tradeHistory.add(result);
    print('Trade result: $result');
    return result;
  }

  @override
  List<TradeResult> getTradeHistory(int limit) {
    final historyCount = _tradeHistory.length;
    final startIndex = historyCount > limit ? historyCount - limit : 0;
    return _tradeHistory.sublist(startIndex);
  }
}
