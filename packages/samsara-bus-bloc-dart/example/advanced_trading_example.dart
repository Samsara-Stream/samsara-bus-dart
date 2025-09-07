import 'package:bloc/bloc.dart';
import 'package:samsara_bus_dart/samsara_bus_dart.dart';
import 'package:samsara_bus_bloc_dart/samsara_bus_bloc_dart.dart';

// Advanced trading example showing complex topology usage

// Events
abstract class TradingEvent {}

class PlaceOrder extends TradingEvent {
  final String symbol;
  final double price;
  final int quantity;
  PlaceOrder(this.symbol, this.price, this.quantity);
}

class MarketUpdate extends TradingEvent {
  final Map<String, double> prices;
  MarketUpdate(this.prices);
}

class RiskAlert extends TradingEvent {
  final String message;
  final String severity;
  RiskAlert(this.message, this.severity);
}

class ExecuteSignal extends TradingEvent {
  final String signal;
  final Map<String, dynamic> data;
  ExecuteSignal(this.signal, this.data);
}

// State
class TradingState {
  final Map<String, double> portfolio;
  final Map<String, double> currentPrices;
  final List<String> alerts;
  final double totalValue;

  const TradingState({
    this.portfolio = const {},
    this.currentPrices = const {},
    this.alerts = const [],
    this.totalValue = 0.0,
  });

  TradingState copyWith({
    Map<String, double>? portfolio,
    Map<String, double>? currentPrices,
    List<String>? alerts,
    double? totalValue,
  }) {
    return TradingState(
      portfolio: portfolio ?? this.portfolio,
      currentPrices: currentPrices ?? this.currentPrices,
      alerts: alerts ?? this.alerts,
      totalValue: totalValue ?? this.totalValue,
    );
  }
}

// Advanced trading bloc with multiple topologies
class TradingBloc extends BusBloc<TradingEvent, TradingState> {
  TradingBloc(SamsaraBus bus) : super(bus, const TradingState()) {
    on<PlaceOrder>(_onPlaceOrder);
    on<MarketUpdate>(_onMarketUpdate);
    on<RiskAlert>(_onRiskAlert);
    on<ExecuteSignal>(_onExecuteSignal);

    // Set up topologies
    _setupPriceAnalysisTopology();
    _setupRiskManagementTopology();
    _setupTradingSignalTopology();
  }

  void _onPlaceOrder(PlaceOrder event, Emitter<TradingState> emit) {
    final newPortfolio = Map<String, double>.from(state.portfolio);
    newPortfolio[event.symbol] =
        (newPortfolio[event.symbol] ?? 0) + event.quantity;

    final totalValue = _calculateTotalValue(newPortfolio, state.currentPrices);

    emit(state.copyWith(
      portfolio: newPortfolio,
      totalValue: totalValue,
    ));

    // Emit to audit topic
    emitToBus('trade_audit', {
      'action': 'order_placed',
      'symbol': event.symbol,
      'price': event.price,
      'quantity': event.quantity,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _onMarketUpdate(MarketUpdate event, Emitter<TradingState> emit) {
    final totalValue = _calculateTotalValue(state.portfolio, event.prices);

    emit(state.copyWith(
      currentPrices: event.prices,
      totalValue: totalValue,
    ));
  }

  void _onRiskAlert(RiskAlert event, Emitter<TradingState> emit) {
    final newAlerts = [...state.alerts, '${event.severity}: ${event.message}'];
    emit(state.copyWith(alerts: newAlerts));
  }

  void _onExecuteSignal(ExecuteSignal event, Emitter<TradingState> emit) {
    print('Executing trading signal: ${event.signal}');
    print('Signal data: ${event.data}');

    // Emit signal execution to bus
    emitToBus('signal_execution', {
      'signal': event.signal,
      'data': event.data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _setupPriceAnalysisTopology() {
    final priceTopology = topology('price_analysis')
        .param<double>('volatility_threshold', (t) => t.number())
        .param<int>('analysis_window', (t) => t.number())
        .topic('raw_prices', 'market_data')
        .topic('volume_data', 'volume_feed')
        .proc(processor(
          id: 'price_smoother',
          inputs: ['raw_prices'],
          fn: (inputs) {
            final prices = inputs[0] as Map<String, double>;
            // Simple moving average logic
            return prices.map(
                (symbol, price) => MapEntry(symbol, price * 0.9 + price * 0.1));
          },
        ))
        .proc(processor(
          id: 'volatility_calculator',
          inputs: ['raw_prices', 'price_smoother'],
          combiner: TopologyCombiner.combineLatest,
          fn: (inputs) {
            final rawPrices = inputs[0] as Map<String, double>;
            final smoothPrices = inputs[1] as Map<String, double>;

            final volatility = <String, double>{};
            for (final symbol in rawPrices.keys) {
              final raw = rawPrices[symbol] ?? 0;
              final smooth = smoothPrices[symbol] ?? 0;
              volatility[symbol] = (raw - smooth).abs() / smooth;
            }
            return volatility;
          },
        ))
        .proc(processor(
          id: 'market_analyzer',
          inputs: ['price_smoother', 'volatility_calculator', 'volume_data'],
          combiner: TopologyCombiner.combineLatest,
          fn: (inputs) {
            final prices = inputs[0] as Map<String, double>;
            final volatility = inputs[1] as Map<String, double>;
            final volume = inputs[2] as Map<String, int>;

            return {
              'prices': prices,
              'volatility': volatility,
              'volume': volume,
              'analysis_timestamp': DateTime.now().toIso8601String(),
            };
          },
        ))
        .output('market_analyzer')
        .build();

    onTopology<Map<String, dynamic>>(
      priceTopology,
      {'volatility_threshold': 0.05, 'analysis_window': 20},
      (topologyEvent) =>
          MarketUpdate((topologyEvent.data['prices'] as Map<String, double>)),
    );
  }

  void _setupRiskManagementTopology() {
    final riskTopology = topology('risk_management')
        .param<double>('max_position_size', (t) => t.number())
        .param<double>('max_portfolio_risk', (t) => t.number())
        .topic('portfolio_updates', 'portfolio_changes')
        .topic('market_conditions', 'market_analysis')
        .proc(processor(
          id: 'position_risk_checker',
          inputs: ['portfolio_updates'],
          fn: (inputs) {
            final portfolio = inputs[0] as Map<String, double>;
            final riskyPositions = <String>[];

            for (final entry in portfolio.entries) {
              if (entry.value.abs() > 1000) {
                // Max position size
                riskyPositions.add(entry.key);
              }
            }

            return riskyPositions.isEmpty ? skip : riskyPositions;
          },
        ))
        .proc(processor(
          id: 'portfolio_risk_checker',
          inputs: ['portfolio_updates', 'market_conditions'],
          combiner: TopologyCombiner.combineLatest,
          fn: (inputs) {
            final portfolio = inputs[0] as Map<String, double>;
            final marketData = inputs[1] as Map<String, dynamic>;

            // Calculate portfolio risk
            double totalRisk = 0.0;
            final volatility = marketData['volatility'] as Map<String, double>;

            for (final entry in portfolio.entries) {
              final vol = volatility[entry.key] ?? 0.0;
              totalRisk += entry.value.abs() * vol;
            }

            if (totalRisk > 5000) {
              // Max portfolio risk
              return {
                'risk_level': 'HIGH',
                'total_risk': totalRisk,
                'message': 'Portfolio risk exceeds threshold',
              };
            }

            return skip;
          },
        ))
        .proc(processor(
          id: 'risk_aggregator',
          inputs: ['position_risk_checker', 'portfolio_risk_checker'],
          combiner: TopologyCombiner.merge,
          fn: (inputs) {
            final riskData = inputs[0];

            if (riskData is List<String>) {
              return {
                'type': 'POSITION_RISK',
                'symbols': riskData,
                'message': 'High position risk in: ${riskData.join(', ')}',
              };
            } else if (riskData is Map<String, dynamic>) {
              return {
                'type': 'PORTFOLIO_RISK',
                'data': riskData,
                'message': riskData['message'],
              };
            }

            return skip;
          },
        ))
        .output('risk_aggregator')
        .build();

    onTopology<Map<String, dynamic>>(
      riskTopology,
      {'max_position_size': 1000.0, 'max_portfolio_risk': 5000.0},
      (topologyEvent) => RiskAlert(
        topologyEvent.data['message'] as String,
        topologyEvent.data['type'] as String,
      ),
    );
  }

  void _setupTradingSignalTopology() {
    final signalTopology = topology('trading_signals')
        .param<double>('signal_threshold', (t) => t.number())
        .topic('technical_indicators', 'indicators')
        .topic('fundamental_data', 'fundamentals')
        .topic('sentiment_data', 'market_sentiment')
        .proc(processor(
          id: 'technical_signal',
          inputs: ['technical_indicators'],
          fn: (inputs) {
            final indicators = inputs[0] as Map<String, dynamic>;
            final rsi = indicators['RSI'] as double? ?? 50;
            final macd = indicators['MACD'] as double? ?? 0;

            if (rsi < 30 && macd > 0) {
              return {'signal': 'BUY', 'strength': 0.8, 'source': 'technical'};
            } else if (rsi > 70 && macd < 0) {
              return {'signal': 'SELL', 'strength': 0.8, 'source': 'technical'};
            }

            return skip;
          },
        ))
        .proc(processor(
          id: 'fundamental_signal',
          inputs: ['fundamental_data'],
          fn: (inputs) {
            final fundamentals = inputs[0] as Map<String, dynamic>;
            final peRatio = fundamentals['PE'] as double? ?? 15;
            final growth = fundamentals['growth'] as double? ?? 0;

            if (peRatio < 15 && growth > 0.1) {
              return {
                'signal': 'BUY',
                'strength': 0.6,
                'source': 'fundamental'
              };
            } else if (peRatio > 25 && growth < 0) {
              return {
                'signal': 'SELL',
                'strength': 0.6,
                'source': 'fundamental'
              };
            }

            return skip;
          },
        ))
        .proc(processor(
          id: 'sentiment_signal',
          inputs: ['sentiment_data'],
          fn: (inputs) {
            final sentiment = inputs[0] as Map<String, dynamic>;
            final score = sentiment['score'] as double? ?? 0;

            if (score > 0.7) {
              return {'signal': 'BUY', 'strength': 0.4, 'source': 'sentiment'};
            } else if (score < -0.7) {
              return {'signal': 'SELL', 'strength': 0.4, 'source': 'sentiment'};
            }

            return skip;
          },
        ))
        .proc(processor(
          id: 'signal_combiner',
          inputs: [
            'technical_signal',
            'fundamental_signal',
            'sentiment_signal'
          ],
          combiner: TopologyCombiner.merge,
          fn: (inputs) {
            final signal = inputs[0] as Map<String, dynamic>;

            // In a real implementation, we would accumulate signals over time
            // and combine them with proper weighting
            return {
              'final_signal': signal['signal'],
              'confidence': signal['strength'],
              'sources': [signal['source']],
              'timestamp': DateTime.now().toIso8601String(),
            };
          },
        ))
        .output('signal_combiner')
        .build();

    onTopology<Map<String, dynamic>>(
      signalTopology,
      {'signal_threshold': 0.7},
      (topologyEvent) {
        final confidence = topologyEvent.data['confidence'] as double;
        if (confidence >= 0.7) {
          return ExecuteSignal(
            topologyEvent.data['final_signal'] as String,
            topologyEvent.data,
          );
        }
        return ExecuteSignal('HOLD', topologyEvent.data);
      },
    );
  }

  double _calculateTotalValue(
      Map<String, double> portfolio, Map<String, double> prices) {
    double total = 0.0;
    for (final entry in portfolio.entries) {
      final price = prices[entry.key] ?? 0.0;
      total += entry.value * price;
    }
    return total;
  }
}

void main() async {
  print('=== Advanced Trading Bot Example ===');

  // Create bus and register topics
  final bus = DefaultSamsaraBus();

  // Market data topics
  bus.registerTopic<Map<String, double>>(
      'market_data', TopicType.behaviorSubject);
  bus.registerTopic<Map<String, int>>('volume_feed', TopicType.publishSubject);

  // Portfolio and risk topics
  bus.registerTopic<Map<String, double>>(
      'portfolio_changes', TopicType.behaviorSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'market_analysis', TopicType.publishSubject);

  // Signal topics
  bus.registerTopic<Map<String, dynamic>>(
      'indicators', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'fundamentals', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'market_sentiment', TopicType.publishSubject);

  // Audit topics
  bus.registerTopic<Map<String, dynamic>>(
      'trade_audit', TopicType.publishSubject);
  bus.registerTopic<Map<String, dynamic>>(
      'signal_execution', TopicType.publishSubject);

  // Create trading bloc
  final tradingBloc = TradingBloc(bus);

  // Listen to state changes
  tradingBloc.stream.listen((state) {
    print('\n--- Portfolio Update ---');
    print('Total Value: \$${state.totalValue.toStringAsFixed(2)}');
    print('Holdings: $state.portfolio');
    print('Current Prices: $state.currentPrices');
    if (state.alerts.isNotEmpty) {
      print('Alerts: ${state.alerts.last}');
    }
  });

  // Listen to audit trail
  bus.getStream<Map<String, dynamic>>('trade_audit').listen((audit) {
    print('AUDIT: ${audit}');
  });

  bus.getStream<Map<String, dynamic>>('signal_execution').listen((execution) {
    print('SIGNAL EXECUTION: ${execution}');
  });

  await Future.delayed(Duration(milliseconds: 100));

  print('\n--- Simulating Market Activity ---');

  // Simulate market data
  bus.emit('market_data', {
    'AAPL': 150.0,
    'GOOGL': 2800.0,
    'TSLA': 800.0,
  });

  bus.emit('volume_feed', {
    'AAPL': 1000000,
    'GOOGL': 500000,
    'TSLA': 2000000,
  });

  await Future.delayed(Duration(milliseconds: 50));

  // Simulate trading
  print('\n--- Placing Orders ---');
  tradingBloc.add(PlaceOrder('AAPL', 150.0, 10));
  tradingBloc.add(PlaceOrder('GOOGL', 2800.0, 2));

  await Future.delayed(Duration(milliseconds: 50));

  // Update portfolio tracking
  bus.emit('portfolio_changes', {
    'AAPL': 10.0,
    'GOOGL': 2.0,
  });

  await Future.delayed(Duration(milliseconds: 50));

  // Simulate price movement and volatility
  bus.emit('market_data', {
    'AAPL': 148.0,
    'GOOGL': 2850.0,
    'TSLA': 750.0,
  });

  await Future.delayed(Duration(milliseconds: 50));

  // Send trading signals
  print('\n--- Generating Trading Signals ---');

  bus.emit('indicators', {
    'RSI': 25.0, // Oversold
    'MACD': 5.0, // Positive momentum
  });

  bus.emit('fundamentals', {
    'PE': 12.0, // Low PE ratio
    'growth': 0.15, // Good growth
  });

  bus.emit('market_sentiment', {
    'score': 0.8, // Very positive sentiment
  });

  await Future.delayed(Duration(milliseconds: 100));

  // Simulate risk scenario
  print('\n--- Testing Risk Management ---');

  // Large position that should trigger risk alert
  tradingBloc.add(PlaceOrder('TSLA', 750.0, 20)); // Large position

  bus.emit('portfolio_changes', {
    'AAPL': 10.0,
    'GOOGL': 2.0,
    'TSLA': 20.0, // This should trigger position risk
  });

  await Future.delayed(Duration(milliseconds: 100));

  // Clean up
  await tradingBloc.close();
  await bus.close();

  print('\n=== Trading simulation completed ===');
}
