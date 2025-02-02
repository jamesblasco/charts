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
  final int campaign;
  final int clickCount;
  MyRow(this.campaign, this.clickCount);
}

class TestComparisonPointsDecorator<D> extends ComparisonPointsDecorator<D> {
  List<Offset> testComputeBoundedPointsForElement(
      PointRendererElement<D> pointElement, Rect drawBounds) {
    return computeBoundedPointsForElement(pointElement, drawBounds);
  }
}

void main() {
  TestComparisonPointsDecorator decorator;
  Rect bounds;

  setUp(() {
    decorator = TestComparisonPointsDecorator<num>();
    bounds = Rect.fromLTWH(0, 0, 100, 100);
  });

  group('compute bounded points', () {
    test('with line inside bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint(
            x: 10.0,
            xLower: 5.0,
            xUpper: 50.0,
            y: 20.0,
            yLower: 20.0,
            yUpper: 20.0),
        radius: 0,
        boundsLineRadius: 0,
        strokeWidth: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].dx, equals(5.0));
      expect(points[0].dy, equals(20.0));

      expect(points[1].dx, equals(50.0));
      expect(points[1].dy, equals(20.0));
    });

    test('with line entirely above bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint(
            x: 10.0,
            xLower: 5.0,
            xUpper: 50.0,
            y: -20.0,
            yLower: -20.0,
            yUpper: -20.0),
        radius: 0,
        boundsLineRadius: 0,
        strokeWidth: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points, isNull);
    });

    test('with line entirely below bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint(
            x: 10.0,
            xLower: 5.0,
            xUpper: 50.0,
            y: 120.0,
            yLower: 120.0,
            yUpper: 120.0),
        radius: 0,
        boundsLineRadius: 0,
        strokeWidth: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points, isNull);
    });

    test('with line entirely left of bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint(
            x: -10.0,
            xLower: -5.0,
            xUpper: -50.0,
            y: 20.0,
            yLower: 20.0,
            yUpper: 50.0),
        radius: 0,
        boundsLineRadius: 0,
        strokeWidth: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points, isNull);
    });

    test('with line entirely right of bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint(
            x: 110.0,
            xLower: 105.0,
            xUpper: 150.0,
            y: 20.0,
            yLower: 20.0,
            yUpper: 50.0),
        radius: 0,
        boundsLineRadius: 0,
        strokeWidth: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points, isNull);
    });

    test('with horizontal line extending beyond bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint(
            x: 10.0,
            xLower: -10.0,
            xUpper: 110.0,
            y: 20.0,
            yLower: 20.0,
            yUpper: 20.0),
        radius: 0,
        boundsLineRadius: 0,
        strokeWidth: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].dx, equals(0.0));
      expect(points[0].dy, equals(20.0));

      expect(points[1].dx, equals(100.0));
      expect(points[1].dy, equals(20.0));
    });

    test('with vertical line extending beyond bounds', () {
      final element = PointRendererElement<num>(
        point: DatumPoint(
            x: 20.0,
            xLower: 20.0,
            xUpper: 20.0,
            y: 10.0,
            yLower: -10.0,
            yUpper: 110.0),
        radius: 0,
        boundsLineRadius: 0,
        strokeWidth: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].dx, equals(20.0));
      expect(points[0].dy, equals(0.0));

      expect(points[1].dx, equals(20.0));
      expect(points[1].dy, equals(100.0));
    });

    test('with diagonal from top left to bottom right', () {
      final element = PointRendererElement<num>(
        point: DatumPoint(
            x: 50.0,
            xLower: -50.0,
            xUpper: 150.0,
            y: 50.0,
            yLower: -50.0,
            yUpper: 150.0),
        radius: 0,
        boundsLineRadius: 0,
        strokeWidth: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].dx, equals(0.0));
      expect(points[0].dy, equals(0.0));

      expect(points[1].dx, equals(100.0));
      expect(points[1].dy, equals(100.0));
    });

    test('with diagonal from bottom left to top right', () {
      final element = PointRendererElement<num>(
        point: DatumPoint(
            x: 50.0,
            xLower: -50.0,
            xUpper: 150.0,
            y: 50.0,
            yLower: 150.0,
            yUpper: -50.0),
        radius: 0,
        boundsLineRadius: 0,
        strokeWidth: 0,
      );

      final points =
          decorator.testComputeBoundedPointsForElement(element, bounds);

      expect(points.length, equals(2));

      expect(points[0].dx, equals(0.0));
      expect(points[0].dy, equals(100.0));

      expect(points[1].dx, equals(100.0));
      expect(points[1].dy, equals(0.0));
    });
  });
}
