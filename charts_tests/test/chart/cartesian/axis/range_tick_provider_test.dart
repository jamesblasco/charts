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

class MockNumericTickFormatter extends Mock
    implements TickFormatterElement<num> {}

class FakeNumericTickFormatter extends TickFormatterElement<num> {
  int calledTimes = 0;

  @override
  List<String> format(List<num> tickValues, Map<num, String> cache,
      {num stepSize}) {
    calledTimes += 1;

    return tickValues.map((value) => value.toString()).toList();
  }

  @override
  // TODO: implement props
  List<Object> get props => throw UnimplementedError();
}

class MockDrawStrategy<D> extends Mock implements BaseTickDrawStrategy<D> {}

void main() {
  ChartContext context;
  GraphicsFactory graphicsFactory;
  TickFormatterElement<num> formatter;
  BaseTickDrawStrategy<num> drawStrategy;
  LinearScaleElement scale;

  setUp(() {
    context = MockChartContext();
    graphicsFactory = MockGraphicsFactory();
    formatter = MockNumericTickFormatter();
    drawStrategy = MockDrawStrategy<num>();
    scale = LinearScaleElement()..range = ScaleOutputExtent(0, 300);

    when(graphicsFactory.createTextElement(any)).thenReturn(MockTextElement());
  });

  group('scale is extended with range tick values', () {
    test('values extend existing domain values', () {
      final tickProvider = RangeTickProviderElement<num>([
        Tick<num>(20200601, label: '20200601'),
        Tick<num>(20200608, label: '20200608'),
        Tick<num>(20200615, label: '20200615'),
        RangeTickSpec<num>(
          20200531,
          label: 'Week 1',
          rangeStartValue: 20200531,
          rangeEndValue: 20200607,
        ),
        RangeTickSpec<num>(
          20200607,
          label: 'Week 2',
          rangeStartValue: 20200607,
          rangeEndValue: 20200614,
        ),
        RangeTickSpec<num>(
          20200614,
          label: 'Week 3',
          rangeStartValue: 20200614,
          rangeEndValue: 20200621,
        ),
      ]);

      scale.addDomain(20200601);
      scale.addDomain(20200607);

      expect(scale.dataExtent.min, equals(20200601));
      expect(scale.dataExtent.max, equals(20200607));

      tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: formatter,
          formatterValueCache: <num, String>{},
          tickDrawStrategy: drawStrategy,
          orientation: null);

      expect(scale.dataExtent.min, equals(20200531));
      expect(scale.dataExtent.max, equals(20200621));
    });

    test('values within data extent', () {
      final tickProvider = RangeTickProviderElement<num>([
        Tick<num>(20200601, label: '20200601'),
        Tick<num>(20200608, label: '20200608'),
        RangeTickSpec<num>(
          20200531,
          label: 'Week 1',
          rangeStartValue: 20200531,
          rangeEndValue: 20200607,
        ),
        RangeTickSpec<num>(
          20200607,
          label: 'Week 2',
          rangeStartValue: 20200607,
          rangeEndValue: 20200614,
        ),
      ]);

      scale.addDomain(20200401);
      scale.addDomain(20200701);

      expect(scale.dataExtent.min, equals(20200401));
      expect(scale.dataExtent.max, equals(20200701));

      tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: formatter,
          formatterValueCache: <num, String>{},
          tickDrawStrategy: drawStrategy,
          orientation: null);

      expect(scale.dataExtent.min, equals(20200401));
      expect(scale.dataExtent.max, equals(20200701));
    });
  });

  group('formatter', () {
    test('is not called when all ticks have labels', () {
      final tickProvider = RangeTickProviderElement<num>([
        Tick<num>(20200601, label: '20200601'),
        Tick<num>(20200608, label: '20200608'),
        RangeTickSpec<num>(
          20200531,
          label: 'Week 1',
          rangeStartValue: 20200531,
          rangeEndValue: 20200607,
        ),
        RangeTickSpec<num>(
          20200607,
          label: 'Week 2',
          rangeStartValue: 20200607,
          rangeEndValue: 20200614,
        ),
      ]);

      final fakeFormatter = FakeNumericTickFormatter();

      tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: fakeFormatter,
          formatterValueCache: <num, String>{},
          tickDrawStrategy: drawStrategy,
          orientation: null);

      expect(fakeFormatter.calledTimes, equals(0));
    });

    test('is called when one ticks does not have label', () {
      final tickProvider = RangeTickProviderElement<num>([
        Tick<num>(20200601, label: '20200601'),
        Tick<num>(20200608, label: '20200608'),
        RangeTickSpec<num>(
          20200531,
          rangeStartValue: 20200531,
          rangeEndValue: 20200607,
        ),
        RangeTickSpec<num>(
          20200607,
          label: 'Week 2',
          rangeStartValue: 20200607,
          rangeEndValue: 20200614,
        ),
      ]);

      final fakeFormatter = FakeNumericTickFormatter();

      tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: fakeFormatter,
          formatterValueCache: <num, String>{},
          tickDrawStrategy: drawStrategy,
          orientation: null);

      expect(fakeFormatter.calledTimes, equals(1));
    });

    test('is called when all ticks do not have labels', () {
      final tickProvider = RangeTickProviderElement<num>([
        Tick<num>(20200601),
        Tick<num>(20200608),
        RangeTickSpec<num>(
          20200531,
          rangeStartValue: 20200531,
          rangeEndValue: 20200607,
        ),
        RangeTickSpec<num>(
          20200607,
          rangeStartValue: 20200607,
          rangeEndValue: 20200614,
        ),
      ]);

      final fakeFormatter = FakeNumericTickFormatter();

      tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: fakeFormatter,
          formatterValueCache: <num, String>{},
          tickDrawStrategy: drawStrategy,
          orientation: null);

      expect(fakeFormatter.calledTimes, equals(1));
    });
  });
}
