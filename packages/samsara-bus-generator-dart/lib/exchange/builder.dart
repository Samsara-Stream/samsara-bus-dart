import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'exchange_client_generator.dart';
import 'exchange_service_generator.dart';

/// Builder for generating SamsaraBus Exchange clients and services
Builder samsaraBusExchangeGenerator(BuilderOptions options) => PartBuilder([
      ExchangeClientGenerator(),
      ExchangeServiceGenerator(),
    ], '.g.dart');
