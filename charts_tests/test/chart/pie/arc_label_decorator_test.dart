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

import 'dart:math' show pi, Point, Rectangle;
import 'package:charts/charts.dart';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockCanvas extends Mock implements ChartCanvas {}

/// A fake [GraphicsFactory] that returns [FakeTextStyle] and [FakeTextElement].
class FakeGraphicsFactory extends GraphicsFactory {
  @override
  TextStyle createTextPaint() => TextStyle();

  @override
  TextElement createTextElement(String text) => FakeTextElement(text);

  @override
  LineStyle createLinePaint() => LineStyle();
}

/// Fake [TextElement] which returns text length as [horizontalSliceWidth].
///
/// Font size is returned for [verticalSliceWidth] and [baseline].
class FakeTextElement implements TextElement {
  @override
  final String text;

  @override
  TextStyle textStyle;

  @override
  int maxWidth;

  @override
  MaxWidthStrategy maxWidthStrategy;

  @override
  TextDirectionAligment textDirection;
  double opacity;

  FakeTextElement(this.text);

  @override
  TextMeasurement get measurement => TextMeasurement(
      horizontalSliceWidth: text.length.toDouble(),
      verticalSliceWidth: textStyle.fontSize.toDouble(),
      baseline: textStyle.fontSize.toDouble());
}

class FakeArcRendererElement extends ArcRendererElement<String> {
  final _series = MockImmutableSeries<String>();
  final AccessorFn<String> labelAccessor;
  final List<String> data;

  FakeArcRendererElement(this.labelAccessor, this.data) {
    when(_series.labelAccessorFn).thenReturn(labelAccessor);
    when(_series.data).thenReturn(data);
  }

  @override
  ImmutableSeries<String> get series => _series;
}

class MockImmutableSeries<D> extends Mock implements ImmutableSeries<D> {}

void main() {
  ChartCanvas canvas;
  GraphicsFactory graphicsFactory;
  Rectangle<int> drawBounds;

  setUpAll(() {
    canvas = MockCanvas();
    graphicsFactory = FakeGraphicsFactory();
    drawBounds = Rectangle(0, 0, 200, 200);
  });

  group('pie chart', () {
    test('Paint labels with default settings', () {
      final data = ['A', 'B'];
      final arcElements = ArcRendererElementList(
        arcs: [
          // 'A' is small enough to fit inside the arc.
          // 'LongLabelB' should not fit inside the arc because it has length
          // greater than 10.
          FakeArcRendererElement((_) => 'A', data)
            ..startAngle = -pi / 2
            ..endAngle = pi / 2,
          FakeArcRendererElement((_) => 'LongLabelB', data)
            ..startAngle = pi / 2
            ..endAngle = 3 * pi / 2,
        ],
        center: Point(100.0, 100.0),
        innerRadius: 30.0,
        radius: 40.0,
        startAngle: -pi / 2,
      );

      final decorator = ArcLabelDecorator();

      decorator.decorate([arcElements], canvas, graphicsFactory,
          drawBounds: drawBounds, animationPercent: 1.0);

      final captured =
          verify(canvas.drawText(captureAny, captureAny, captureAny)).captured;
      // Draw text is called twice (once for each arc) and all 3 parameters were
      // captured. Total parameters captured expected to be 6.
      expect(captured, hasLength(6));
      // For arc 'A'.
      expect(captured[0].maxWidth, equals(10 - decorator.labelPadding));
      expect(captured[0].textDirection, equals(TextDirectionAligment.center));
      expect(captured[1], equals(135));
      expect(captured[2],
          equals(100 - decorator.insideLabelStyleSpec.fontSize ~/ 2));
      // For arc 'B'.
      expect(captured[3].maxWidth, equals(20));
      expect(captured[3].textDirection, equals(TextDirectionAligment.rtl));
      expect(
          captured[4],
          equals(60 -
              decorator.leaderLineStyle.length -
              decorator.labelPadding * 3));
      expect(captured[5],
          equals(100 - decorator.outsideLabelStyleSpec.fontSize ~/ 2));
    });

    test('LabelPosition.inside always paints inside the arc', () {
      final arcElements = ArcRendererElementList(
        arcs: [
          // 'LongLabelABC' would not fit inside the arc because it has length
          // greater than 10. [ArcLabelPosition.inside] should override this.
          FakeArcRendererElement((_) => 'LongLabelABC', ['A'])
            ..startAngle = -pi / 2
            ..endAngle = pi / 2,
        ],
        center: Point(100.0, 100.0),
        innerRadius: 30.0,
        radius: 40.0,
        startAngle: -pi / 2,
      );

      final decorator = ArcLabelDecorator(
          labelPosition: ArcLabelPosition.inside,
          insideLabelStyleSpec: TextStyle(fontSize: 10));

      decorator.decorate([arcElements], canvas, graphicsFactory,
          drawBounds: drawBounds, animationPercent: 1.0);

      final captured =
          verify(canvas.drawText(captureAny, captureAny, captureAny)).captured;
      expect(captured, hasLength(3));
      expect(captured[0].maxWidth, equals(10 - decorator.labelPadding));
      expect(captured[0].textDirection, equals(TextDirectionAligment.center));
      expect(captured[1], equals(135));
      expect(captured[2],
          equals(100 - decorator.insideLabelStyleSpec.fontSize ~/ 2));
    });

    test('LabelPosition.outside always paints outside the arc', () {
      final arcElements = ArcRendererElementList(
        arcs: [
          // 'A' will fit inside the arc because it has length less than 10.
          // [ArcLabelPosition.outside] should override this.
          FakeArcRendererElement((_) => 'A', ['A'])
            ..startAngle = -pi / 2
            ..endAngle = pi / 2,
        ],
        center: Point(100.0, 100.0),
        innerRadius: 30.0,
        radius: 40.0,
        startAngle: -pi / 2,
      );

      final decorator = ArcLabelDecorator(
          labelPosition: ArcLabelPosition.outside,
          outsideLabelStyleSpec: TextStyle(fontSize: 10));

      decorator.decorate([arcElements], canvas, graphicsFactory,
          drawBounds: drawBounds, animationPercent: 1.0);

      final captured =
          verify(canvas.drawText(captureAny, captureAny, captureAny)).captured;
      expect(captured, hasLength(3));
      expect(captured[0].maxWidth, equals(20));
      expect(captured[0].textDirection, equals(TextDirectionAligment.ltr));
      expect(
          captured[1],
          equals(140 +
              decorator.leaderLineStyle.length +
              decorator.labelPadding * 3));
      expect(captured[2],
          equals(100 - decorator.outsideLabelStyleSpec.fontSize ~/ 2));
    });

    test('Inside and outside label styles are applied', () {
      final data = ['A', 'B'];
      final arcElements = ArcRendererElementList(
        arcs: [
          // 'A' is small enough to fit inside the arc.
          // 'LongLabelB' should not fit inside the arc because it has length
          // greater than 10.
          FakeArcRendererElement((_) => 'A', data)
            ..startAngle = -pi / 2
            ..endAngle = pi / 2,
          FakeArcRendererElement((_) => 'LongLabelB', data)
            ..startAngle = pi / 2
            ..endAngle = 3 * pi / 2,
        ],
        center: Point(100.0, 100.0),
        innerRadius: 30.0,
        radius: 40.0,
        startAngle: -pi / 2,
      );

      final insideColor = Colors.black;
      final outsideColor = Colors.white;
      final decorator = ArcLabelDecorator(
          labelPadding: 0,
          insideLabelStyleSpec: TextStyle(
              fontSize: 10, fontFamily: 'insideFont', color: insideColor),
          outsideLabelStyleSpec: TextStyle(
              fontSize: 8, fontFamily: 'outsideFont', color: outsideColor));

      decorator.decorate([arcElements], canvas, graphicsFactory,
          drawBounds: drawBounds, animationPercent: 1.0);

      final captured =
          verify(canvas.drawText(captureAny, captureAny, captureAny)).captured;
      // Draw text is called twice (once for each arc) and all 3 parameters were
      // captured. Total parameters captured expected to be 6.
      expect(captured, hasLength(6));
      // For arc 'A'.
      expect(captured[0].maxWidth, equals(10 - decorator.labelPadding));
      expect(captured[0].textDirection, equals(TextDirectionAligment.center));
      expect(captured[0].textStyle.fontFamily, equals('insideFont'));
      expect(captured[0].textStyle.color, equals(insideColor));
      expect(captured[1], equals(135));
      expect(captured[2],
          equals(100 - decorator.insideLabelStyleSpec.fontSize ~/ 2));
      // For arc 'B'.
      expect(captured[3].maxWidth, equals(30));
      expect(captured[3].textDirection, equals(TextDirectionAligment.rtl));
      expect(captured[3].textStyle.fontFamily, equals('outsideFont'));
      expect(captured[3].textStyle.color, equals(outsideColor));
      expect(
          captured[4],
          equals(50 -
              decorator.leaderLineStyle.length -
              decorator.labelPadding * 3));
      expect(captured[5],
          equals(100 - decorator.outsideLabelStyleSpec.fontSize ~/ 2));
    });
  });

  group('Null and empty label scenarios', () {
    test('Skip label if label accessor does not exist', () {
      final arcElements = ArcRendererElementList(
        arcs: [
          FakeArcRendererElement(null, ['A'])
            ..startAngle = -pi / 2
            ..endAngle = pi / 2,
        ],
        center: Point(100.0, 100.0),
        innerRadius: 30.0,
        radius: 40.0,
        startAngle: -pi / 2,
      );

      ArcLabelDecorator().decorate([arcElements], canvas, graphicsFactory,
          drawBounds: drawBounds, animationPercent: 1.0);

      verifyNever(canvas.drawText(any, any, any));
    });

    test('Skip label if label is null or empty', () {
      final data = ['A', 'B'];
      final arcElements = ArcRendererElementList(
        arcs: [
          FakeArcRendererElement(null, data)
            ..startAngle = -pi / 2
            ..endAngle = pi / 2,
          FakeArcRendererElement((_) => '', data)
            ..startAngle = pi / 2
            ..endAngle = 3 * pi / 2,
        ],
        center: Point(100.0, 100.0),
        innerRadius: 30.0,
        radius: 40.0,
        startAngle: -pi / 2,
      );

      ArcLabelDecorator().decorate([arcElements], canvas, graphicsFactory,
          drawBounds: drawBounds, animationPercent: 1.0);

      verifyNever(canvas.drawText(any, any, any));
    });
  });
}
