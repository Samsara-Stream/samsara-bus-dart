# Trading Example

This example demonstrates how to use the SamsaraBus generator to create a sophisticated stock trading system using the Exchange Pattern.

## Features

- Real-time stock quote retrieval
- Multiple quote fetching for portfolio analysis
- Trade execution with different order types
- Trade history tracking
- Comprehensive error handling
- Concurrent operation support
- Generated client and service code

## Project Structure

```
trading_example/
├── lib/
│   ├── models.dart                        # Data models (StockQuote, TradeRequest, etc.)
│   ├── market_data_client.dart           # Market data client interface
│   ├── market_data_service.dart          # Market data service interface
│   ├── market_data_service_impl.dart     # Market data implementation
│   ├── trading_client.dart              # Trading client interface
│   ├── trading_service.dart             # Trading service interface
│   └── trading_service_impl.dart        # Trading implementation
├── bin/
│   └── main.dart                         # Example application
├── build.yaml                           # Build configuration
├── pubspec.yaml                          # Dependencies
└── .gitignore                            # Ignores generated files
```

## Generated Files

After running `dart run build_runner build`, the following files are generated:

- `lib/market_data_client.g.dart` - Market data client implementation
- `lib/market_data_service.g.dart` - Market data service implementation
- `lib/trading_client.g.dart` - Trading client implementation
- `lib/trading_service.g.dart` - Trading service implementation

## Running the Example

1. Install dependencies:
   ```bash
   dart pub get
   ```

2. Generate the code:
   ```bash
   dart run build_runner build
   ```

3. Run the example:
   ```bash
   dart run bin/main.dart
   ```

## Expected Output

```
Trading System using SamsaraBus Exchange Pattern
================================================
All services started successfully

=== Demo 1: Market Data ===
Fetching quote for AAPL: $188.51
Apple (AAPL): AAPL: $188.51 (+0.54%)
Fetching quote for GOOG: $177.77
Google (GOOG): GOOG: $177.77 (-0.55%)

=== Demo 2: Multiple Quotes ===
Fetching quotes for 3 symbols
Fetching quote for AAPL: $187.81
Fetching quote for GOOG: $179.31
Fetching quote for MSFT: $428.10
AAPL: $187.81 (+0.16%)
GOOG: $179.31 (+0.32%)
MSFT: $428.10 (+0.67%)

=== Demo 3: Trading ===
Executing trade: BUY 10 AAPL @ MARKET
Trade result: SUCCESS - Order ORD-1750562069114 executed at $151.33
Trade 1: SUCCESS - Order ORD-1750562069114 executed at $151.33
Executing trade: SELL 5 GOOG @ LIMIT $180.00
Trade result: SUCCESS - Order ORD-1750562069117 executed at $148.61
Trade 2: SUCCESS - Order ORD-1750562069117 executed at $148.61

=== Demo 4: Trade History ===
Recent trades:
  SUCCESS - Order ORD-1750562069114 executed at $151.33
  SUCCESS - Order ORD-1750562069117 executed at $148.61

=== Demo 5: Error Handling ===
Caught expected error: Exception: Exception: Invalid stock symbol: INVALID

=== Demo 6: Concurrent Operations ===
Concurrent results received: 3 operations completed

Shutting down services...
Example completed.
```

## Key Features

- **Multi-Service Architecture**: Separate services for market data and trading operations
- **Advanced Data Models**: Complex data structures with proper serialization
- **Order Types**: Support for market, limit, and stop orders
- **Trade Simulation**: Realistic trading simulation with slippage and success rates
- **Custom Timeouts**: Trading operations have longer timeouts due to their critical nature
- **Concurrent Operations**: Demonstrates how multiple services can work together

## How It Works

1. **Market Data Service**: Provides real-time stock quotes with simulated price movements
2. **Trading Service**: Handles trade execution with realistic success/failure scenarios
3. **Client Interfaces**: Clean separation of concerns with dedicated clients for each service
4. **Error Handling**: Comprehensive error handling for invalid symbols and trade failures
5. **Code Generation**: All serialization, deserialization, and routing handled automatically

## Data Models

- `StockQuote`: Real-time stock price with change percentage
- `TradeRequest`: Order details including symbol, quantity, type, and side
- `TradeResult`: Execution result with order ID and price
- `OrderType`: Market, limit, and stop order types
- `TradeSide`: Buy and sell operations

This example showcases how SamsaraBus can handle complex financial data and operations with type safety and reliability.
