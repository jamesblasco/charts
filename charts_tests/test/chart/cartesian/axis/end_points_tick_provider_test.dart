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

import 'package:charts/charts.dart';
import 'package:meta/meta.dart' show required;
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'time/simple_date_time_factory.dart' show SimpleDateTimeFactory;

class MockDateTimeScale extends Mock implements DateTimeScale {}

class MockNumericScale extends Mock implements NumericScaleElement {}

class MockOrdinalScale extends Mock implements SimpleOrdinalScaleElement {}

/// A fake draw strategy that reports collision and alternate ticks
///
/// Reports collision when the tick count is greater than or equal to
/// [collidesAfterTickCount].
///
/// Reports alternate rendering after tick count is greater than or equal to
/// [alternateRenderingAfterTickCount].
class FakeDrawStrategy<D> extends BaseTickDrawStrategy<D> {
  final int collidesAfterTickCount;
  final int alternateRenderingAfterTickCount;

  FakeDrawStrategy(
      this.collidesAfterTickCount, this.alternateRenderingAfterTickCount)
      : super(null, FakeGraphicsFactory());

  @override
  CollisionReport<D> collides(List<TickElement<D>> ticks, _) {
    final ticksCollide = ticks.length >= collidesAfterTickCount;
    final alternateTicksUsed = ticks.length >= alternateRenderingAfterTickCount;

    return CollisionReport(
        ticksCollide: ticksCollide,
        ticks: ticks,
        alternateTicksUsed: alternateTicksUsed);
  }

  @override
  void draw(ChartCanvas canvas, TickElement<D> tick,
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
  TextElement createTextElement(String text) => MockTextElement();

  @override
  LineStyle createLinePaint() => LineStyle();
}

class MockTextElement extends Mock implements TextElement {}

class MockChartContext extends Mock implements ChartContext {}

void main() {
  const dateTimeFactory = SimpleDateTimeFactory();
  FakeGraphicsFactory graphicsFactory;
  EndPointsTickProviderElement tickProvider;
  ChartContext context;

  setUp(() {
    graphicsFactory = FakeGraphicsFactory();
    context = MockChartContext();
  });

  test('dateTime_choosesEndPointTicks', () {
    final formatter = DateTimeTickFormatterElement(dateTimeFactory);
    final scale = MockDateTimeScale();
    tickProvider = EndPointsTickProviderElement<DateTime>();

    final drawStrategy = FakeDrawStrategy<DateTime>(10, 10);
    when(scale.viewportDomain).thenReturn(DateTimeExtents(
        start: DateTime(2018, 8, 1), end: DateTime(2018, 8, 11)));
    when(scale.rangeWidth).thenReturn(1000);
    when(scale.domainStepSize).thenReturn(1000.0);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <DateTime, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks, hasLength(2));
    expect(ticks[0].value, equals(DateTime(2018, 8, 1)));
    expect(ticks[1].value, equals(DateTime(2018, 8, 11)));
  });

  test('numeric_choosesEndPointTicks', () {
    final formatter = NumericTickFormatterElement();
    final scale = MockNumericScale();
    tickProvider = EndPointsTickProviderElement<num>();

    final drawStrategy = FakeDrawStrategy<num>(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(10.0, 70.0));
    when(scale.rangeWidth).thenReturn(1000);
    when(scale.domainStepSize).thenReturn(1000.0);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks, hasLength(2));
    expect(ticks[0].value, equals(10));
    expect(ticks[1].value, equals(70));
  });

  test('ordinal_choosesEndPointTicks', () {
    final formatter = OrdinalTickFormatterElement();
    final scale = SimpleOrdinalScaleElement();
    scale.addDomain('A');
    scale.addDomain('B');
    scale.addDomain('C');
    scale.addDomain('D');
    tickProvider = EndPointsTickProviderElement<String>();

    final drawStrategy = FakeDrawStrategy<String>(10, 10);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <String, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks, hasLength(2));
    expect(ticks[0].value, equals('A'));
    expect(ticks[1].value, equals('D'));
  });

  test('dateTime_emptySeriesChoosesNoTicks', () {
    final formatter = DateTimeTickFormatterElement(dateTimeFactory);
    final scale = MockDateTimeScale();
    tickProvider = EndPointsTickProviderElement<DateTime>();

    final drawStrategy = FakeDrawStrategy<DateTime>(10, 10);
    when(scale.viewportDomain).thenReturn(DateTimeExtents(
        start: DateTime(2018, 8, 1), end: DateTime(2018, 8, 11)));
    when(scale.rangeWidth).thenReturn(1000);

    // An un-configured axis has no domain step size, and its scale defaults to
    // infinity.
    when(scale.domainStepSize).thenReturn(double.infinity);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <DateTime, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks, hasLength(0));
  });

  test('numeric_emptySeriesChoosesNoTicks', () {
    final formatter = NumericTickFormatterElement();
    final scale = MockNumericScale();
    tickProvider = EndPointsTickProviderElement<num>();

    final drawStrategy = FakeDrawStrategy<num>(10, 10);
    when(scale.viewportDomain).thenReturn(NumericExtents(10.0, 70.0));
    when(scale.rangeWidth).thenReturn(1000);

    // An un-configured axis has no domain step size, and its scale defaults to
    // infinity.
    when(scale.domainStepSize).thenReturn(double.infinity);

    final ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: <num, String>{},
        tickDrawStrategy: drawStrategy,
        orientation: null);

    expect(ticks, hasLength(0));
  });
}
