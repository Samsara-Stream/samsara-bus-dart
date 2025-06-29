import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:samsara_bus_generator_dart/builder.dart';
import 'package:test/test.dart';

void main() {
  group('SamsaraBusExchangeGenerator Builder', () {
    test('should create a PartBuilder with correct output extension', () {
      final builder = samsaraBusExchangeGenerator(BuilderOptions.empty);

      expect(builder, isA<PartBuilder>());

      // PartBuilder creates files with .g.dart extension
      // We can test that the builder is configured correctly
      expect(builder.toString(), contains('.g.dart'));
    });

    test('should create builder with empty options', () {
      expect(() => samsaraBusExchangeGenerator(BuilderOptions.empty),
          returnsNormally);
    });

    test('should create builder with custom options', () {
      final options = BuilderOptions({'custom': 'value'});
      expect(() => samsaraBusExchangeGenerator(options), returnsNormally);
    });
  });
}
