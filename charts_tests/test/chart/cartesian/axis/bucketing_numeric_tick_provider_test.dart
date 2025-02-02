// @dart=2.9

// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


import 'package:meta/meta.dart' show required;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:charts/charts.dart';

class MockNumericScale extends Mock implements NumericScaleElement {}

/// A fake draw strategy that reports collision and alternate ticks
///
/// Reports collision when the tick count is greater than or equal to
/// [collidesAfterTickCount].
///
/// Reports alternate rendering after tick count is greater than or equal to
/// [alternateRenderingAfterTickCount].
class FakeDrawStrategy extends BaseTickDrawStrategy<num> {
  final int collidesAfterTickCount;
  final int alternateRenderingAfterTickCount;

  FakeDrawStrategy(
      this.collidesAfterTickCount, this.alternateRenderingAfterTickCount)
      : super(null, FakeGraphicsFactory());

  @override
  CollisionReport<num> collides(List<TickElement<num>> ticks, _) {
    final ticksCollide = ticks.length >= collidesAfterTickCount;
    final alternateTicksUsed = ticks.length >= alternateRenderingAfterTickCount;

    return CollisionReport(
        ticksCollide: ticksCollide,
        ticks: ticks,
        alternateTicksUsed: alternateTicksUsed);
  }

  @override
  void draw(ChartCanvas canvas, TickElement<num> tick,
      {@required AxisOrientation orientation,
      @required Rect axisBounds,
      @required Rect drawAreaBounds,
      @required bool isFirst,
      @required bool isLast,
      bool collision = false}) {}
}

/// A fake [GraphicsFactory] that returns [MockTextStyle] and [MockTextElement].
class FakeGraphicsFactory extends GraphicsFactory {
  @override
  TextStyle createTextPaint() => TextStyle();

  @override
  TextElement createTextElement(String text) => MockTextElement(text);

  @override
  LineStyle createLinePaint() => LineStyle();
}

class MockTextElement extends Mock implements TextElement {
  @override
  String text;

  MockTextElement(this.text);
}

class MockChartContext extends Mock implements ChartContext {}

/// A celsius to fahrenheit converter for testing axis with unit converter.
class CelsiusToFahrenheitConverter implements UnitConverter<num, num> {
  const CelsiusToFahrenheitConverter();

  @override
  num convert(num value) => (value * 1.8) + 32.0;

  @override
  num invert(num value) => (value - 32.0) / 1.8;
}

void main() {
  FakeGraphicsFactory graphicsFactory;
  MockNumericScale scale;
  BucketingNumericTickProviderElement tickProvider;
  TickFormatterElement<num> formatter;
  ChartContext context;

  setUp(() {
    graphicsFactory = FakeGraphicsFactory();
    scale = MockNumericScale();
    tickProvider = BucketingNumericTickProviderElement();
    formatter = NumericTickFormatterElement();
    context = MockChartContext();
  });

  group('threshold', () {
    test('tick generated correctly with no ticks between it and zero', () {
      tickProvider
        ..dataIsInWholeNumbers = false
        ..threshold = 0.1
        ..showBucket = true
        ..setFixedTickCount(21)
        ..allowedSteps = [1.0, 2.5, 5.0];
      final drawStrategy = FakeDrawStrategy(10, 10);
      when(scale.viewportDomain).thenReturn(NumericExtents(0.1, 0.7));
      when(scale.rangeWidth).thenReturn(1000);
      when(scale[0.1]).thenReturn(90.0);
      when(scale[0]).thenReturn(100.0);

      final ticks = tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: formatter,
          formatterValueCache: <num, String>{},
          tickDrawStrategy: drawStrategy,
          orientation: null);

      // Verify.
      // We expect to have 20 ticks, because the expected tick at 0.05 should be
      // removed from the list.
      expect(ticks, hasLength(20));

      // Verify that we still have a 0 tick with an empty label.
      expect(ticks[0].labelOffset, isNull);
      expect(ticks[0].location, equals(100.0));
      expect(ticks[0].value, equals(0.0));
      expect(ticks[0].textElement.text, equals(''));

      // Verify that we have a threshold tick.
      expect(ticks[1].labelOffset, equals(5.0));
      expect(ticks[1].location, equals(90.0));
      expect(ticks[1].value, equals(0.10));
      expect(ticks[1].textElement.text, equals('< 0.1'));

      // Verify that the rest of the ticks are all above the threshold in value
      // and have normal labels.
      var aboveThresholdTicks = ticks.sublist(2);
      aboveThresholdTicks.retainWhere((tick) => tick.value > 0.1);
      expect(aboveThresholdTicks, hasLength(18));

      aboveThresholdTicks = ticks.sublist(2);
      aboveThresholdTicks.retainWhere((tick) =>
          tick.textElement.text != '' && !tick.textElement.text.contains('<'));
      expect(aboveThresholdTicks, hasLength(18));

      aboveThresholdTicks = ticks.sublist(2);
      aboveThresholdTicks.retainWhere((tick) => tick.labelOffset == null);
      expect(aboveThresholdTicks, hasLength(18));
    });
  });
}
