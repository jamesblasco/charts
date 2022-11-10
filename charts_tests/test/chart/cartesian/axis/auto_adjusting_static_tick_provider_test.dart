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
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockChartContext extends Mock implements ChartContext {}

class MockGraphicsFactory extends Mock implements GraphicsFactory {}

class MockTextElement extends Mock implements TextElement {}

class MockNumericTickFormatter extends Mock implements TickFormatter<num> {}

class FakeNumericTickFormatter extends TickFormatter<num> {
  int calledTimes = 0;

  @override
  List<String> format(List<num> tickValues, Map<num, String> cache,
      {num stepSize}) {
    calledTimes += 1;

    return tickValues.map((value) => value.toString()).toList();
  }

  @override
  List<Object> get props => throw UnimplementedError();
}

class MockDrawStrategy<D> extends Mock implements BaseTickDrawStrategy<D> {}

void main() {
  ChartContext context;
  GraphicsFactory graphicsFactory;
  TickFormatter<num> formatter;
  BaseTickDrawStrategy<num> drawStrategy;
  LinearScale scale;

  setUp(() {
    context = MockChartContext();
    graphicsFactory = MockGraphicsFactory();
    formatter = MockNumericTickFormatter();
    drawStrategy = MockDrawStrategy<num>();
    scale = LinearScale()..range = ScaleOutputExtent(0, 300);

    when(graphicsFactory.createTextElement(any)).thenReturn(MockTextElement());
  });

  group('with tick increment', () {
    test('returns the first increment if there is no collision', () {
      final tickProvider = AutoAdjustingStaticTickProvider<num>([
        TickSpec<num>(1, label: '1'),
        TickSpec<num>(2, label: '2'),
        TickSpec<num>(3, label: '3')
      ], [
        1,
        2
      ]);
      when(drawStrategy.collides(any, any)).thenReturn(CollisionReport.empty());

      final ticks = tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: formatter,
          formatterValueCache: <num, String>{},
          tickDrawStrategy: drawStrategy,
          orientation: null);

      expect(ticks.map((tick) => tick.value).toList(), [1, 2, 3]);
    });

    test('returns the first non colliding increment', () {
      final tickProvider = AutoAdjustingStaticTickProvider<num>([
        TickSpec<num>(1, label: '1'),
        TickSpec<num>(2, label: '2'),
        TickSpec<num>(3, label: '3')
      ], [
        1,
        2
      ]);
      when(drawStrategy.collides(any, any)).thenAnswer((invocation) =>
          (invocation.positionalArguments.first as List).length == 3
              ? CollisionReport(ticksCollide: true, ticks: [])
              : CollisionReport.empty());

      final ticks = tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: formatter,
          formatterValueCache: <num, String>{},
          tickDrawStrategy: drawStrategy,
          orientation: null);

      expect(ticks.map((tick) => tick.value).toList(), [1, 3]);
    });
  });
}
