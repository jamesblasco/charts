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

class MockContext extends Mock implements ChartContext {}

class MockGraphicsFactory extends Mock implements GraphicsFactory {}

class FakeNumericChart extends NumericCartesianRenderChart {
  FakeNumericChart() {
    context = MockContext();
    graphicsFactory = MockGraphicsFactory();
  }

  @override
  void initDomainAxis() {
    // Purposely bypass the renderer code.
  }
}

class FakeOrdinalChart extends OrdinalCartesianRenderChart {
  FakeOrdinalChart() {
    context = MockContext();
    graphicsFactory = MockGraphicsFactory();
  }

  @override
  void initDomainAxis() {
    // Purposely bypass the renderer code.
  }
}

class FakeTimeSeries extends TimeSeriesRenderChart {
  FakeTimeSeries() : super(dateTimeFactory: const LocalDateTimeFactory()) {
    context = MockContext();
    graphicsFactory = MockGraphicsFactory();
  }

  @override
  void initDomainAxis() {
    // Purposely bypass the renderer code.
  }
}

void main() {
  group('Axis reset with new axis spec', () {
    test('for ordinal chart', () {
      final chart = FakeOrdinalChart();
      chart.configurationChanged();
      final domainAxis = chart.domainAxis;
      expect(domainAxis, isNotNull);

      chart.domainAxisSpec = OrdinalAxis();
      chart.configurationChanged();

      expect(domainAxis, isNot(chart.domainAxis));
    });

    test('for numeric chart', () {
      final chart = FakeNumericChart();
      chart.configurationChanged();
      final domainAxis = chart.domainAxis;
      expect(domainAxis, isNotNull);

      chart.domainAxisSpec = NumericAxis();
      chart.configurationChanged();

      expect(domainAxis, isNot(chart.domainAxis));
    });

    test('for time series chart', () {
      final chart = FakeTimeSeries();
      chart.configurationChanged();
      final domainAxis = chart.domainAxis;
      expect(domainAxis, isNotNull);

      chart.domainAxisSpec = DateTimeAxis();
      chart.configurationChanged();

      expect(domainAxis, isNot(chart.domainAxis));
    });
  });
}
