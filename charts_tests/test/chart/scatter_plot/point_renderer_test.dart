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
import 'package:test/test.dart';

/// Datum/Row for the chart.
class MyRow {
  final String campaignString;
  final int campaign;
  final int clickCount;
  final double radius;
  final double boundsRadius;
  final String shape;
  MyRow(this.campaignString, this.campaign, this.clickCount, this.radius,
      this.boundsRadius, this.shape);
}

void main() {
  PointRenderer renderer;
  List<MutableSeries<int>> numericSeriesList;

  setUp(() {
    var myFakeDesktopData = [
      // This datum should get a default bounds line radius value.
      MyRow('MyCampaign1', 0, 5, 3.0, null, null),
      MyRow('MyCampaign2', 10, 25, 5.0, 4.0, 'shape 1'),
      MyRow('MyCampaign3', 12, 75, 4.0, 4.0, 'shape 2'),
      // This datum should always get default radius values.
      MyRow('MyCampaign4', 13, 225, null, null, null),
    ];

    final maxMeasure = 300;

    numericSeriesList = [
      MutableSeries<int>(Series<MyRow, int>(
          id: 'Desktop',
          colorFn: (MyRow row, _) {
            // Color bucket the measure column value into 3 distinct colors.
            final bucket = row.clickCount / maxMeasure;

            if (bucket < 1 / 3) {
              return Colors.blue;
            } else if (bucket < 2 / 3) {
              return Colors.red;
            } else {
              return Colors.green;
            }
          },
          domainFn: (MyRow row, _) => row.campaign,
          measureFn: (MyRow row, _) => row.clickCount,
          measureOffsetFn: (MyRow row, _) => 0,
          radiusFn: (MyRow row, _) => row.radius,
          data: myFakeDesktopData)
        // Define a bounds line radius function.
        ..setAttribute(boundsLineRadiusFnKey,
            (int index) => myFakeDesktopData[index].boundsRadius))
    ];
  });

  group('preprocess', () {
    test('with numeric data and simple points', () {
      renderer = PointRenderer<int>(config: PointRendererConfig());

      renderer.preprocessSeries(numericSeriesList);

      expect(numericSeriesList.length, equals(1));

      // Validate Desktop series.
      var series = numericSeriesList[0];

      var keyFn = series.keyFn;

      var elementsList = series.getAttr(pointElementsKey);
      expect(elementsList.length, equals(4));

      expect(elementsList[0].index, equals(0));
      expect(elementsList[1].index, equals(1));
      expect(elementsList[2].index, equals(2));
      expect(elementsList[3].index, equals(3));

      expect(elementsList[0].radius, equals(3.0));
      expect(elementsList[1].radius, equals(5.0));
      expect(elementsList[2].radius, equals(4.0));
      expect(elementsList[3].radius, equals(3.5));

      expect(elementsList[0].boundsLineRadius, equals(3.0));
      expect(elementsList[1].boundsLineRadius, equals(4.0));
      expect(elementsList[2].boundsLineRadius, equals(4.0));
      expect(elementsList[3].boundsLineRadius, equals(3.5));

      expect(elementsList[0].symbolRendererId, equals(defaultSymbolRendererId));
      expect(elementsList[1].symbolRendererId, equals(defaultSymbolRendererId));
      expect(elementsList[2].symbolRendererId, equals(defaultSymbolRendererId));
      expect(elementsList[3].symbolRendererId, equals(defaultSymbolRendererId));

      expect(keyFn(0), equals('Desktop__0__5'));
      expect(keyFn(1), equals('Desktop__10__25'));
      expect(keyFn(2), equals('Desktop__12__75'));
      expect(keyFn(3), equals('Desktop__13__225'));
    });

    test('with numeric data and missing radiusFn', () {
      renderer = PointRenderer<int>(
          config: PointRendererConfig(radius: 2.0, boundsLineRadius: 1.5));

      // Remove the radius functions to test configured defaults.
      numericSeriesList[0].radiusFn = null;
      numericSeriesList[0].setAttr(boundsLineRadiusFnKey, null);

      renderer.preprocessSeries(numericSeriesList);

      expect(numericSeriesList.length, equals(1));

      // Validate Desktop series.
      var series = numericSeriesList[0];

      var elementsList = series.getAttr(pointElementsKey);
      expect(elementsList.length, equals(4));

      expect(elementsList[0].radius, equals(2.0));
      expect(elementsList[1].radius, equals(2.0));
      expect(elementsList[2].radius, equals(2.0));
      expect(elementsList[3].radius, equals(2.0));

      expect(elementsList[0].boundsLineRadius, equals(1.5));
      expect(elementsList[1].boundsLineRadius, equals(1.5));
      expect(elementsList[2].boundsLineRadius, equals(1.5));
      expect(elementsList[3].boundsLineRadius, equals(1.5));
    });

    test('with custom symbol renderer ID in data', () {
      renderer = PointRenderer<int>(config: PointRendererConfig());

      numericSeriesList[0].setAttr(pointSymbolRendererFnKey,
          (int index) => numericSeriesList[0].data[index].shape as String);

      renderer.preprocessSeries(numericSeriesList);

      expect(numericSeriesList.length, equals(1));

      // Validate Desktop series.
      var series = numericSeriesList[0];

      var elementsList = series.getAttr(pointElementsKey);
      expect(elementsList.length, equals(4));

      expect(elementsList[0].symbolRendererId, equals(defaultSymbolRendererId));
      expect(elementsList[1].symbolRendererId, equals('shape 1'));
      expect(elementsList[2].symbolRendererId, equals('shape 2'));
      expect(elementsList[3].symbolRendererId, equals(defaultSymbolRendererId));
    });

    test('with custom symbol renderer ID in series and data', () {
      renderer = PointRenderer<int>(config: PointRendererConfig());

      numericSeriesList[0].setAttr(pointSymbolRendererFnKey,
          (int index) => numericSeriesList[0].data[index].shape as String);
      numericSeriesList[0].setAttr(pointSymbolRendererIdKey, 'shape 0');

      renderer.preprocessSeries(numericSeriesList);

      expect(numericSeriesList.length, equals(1));

      // Validate Desktop series.
      var series = numericSeriesList[0];

      var elementsList = series.getAttr(pointElementsKey);
      expect(elementsList.length, equals(4));

      expect(elementsList[0].symbolRendererId, equals('shape 0'));
      expect(elementsList[1].symbolRendererId, equals('shape 1'));
      expect(elementsList[2].symbolRendererId, equals('shape 2'));
      expect(elementsList[3].symbolRendererId, equals('shape 0'));
    });
  });
}
