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

class MockContext extends Mock implements ChartContext {}

/// Implementation of [BaseTickDrawStrategy] that does nothing on draw.
class BaseTickDrawStrategyImpl<D> extends BaseTickDrawStrategy<D> {
  BaseTickDrawStrategyImpl(
      ChartContext chartContext, GraphicsFactory graphicsFactory,
      {TextStyle labelStyleSpec,
      LineStyle axisLineStyle,
      TickLabelAnchor labelAnchor,
      TickLabelJustification labelJustification,
      double labelOffsetFromAxis,
      double labelCollisionOffsetFromAxis,
      double labelOffsetFromTick,
      double labelCollisionOffsetFromTick,
      double minimumPaddingBetweenLabels,
      double labelRotation,
      double labelCollisionRotation})
      : super(chartContext, graphicsFactory,
            labelStyleSpec: labelStyleSpec,
            axisLineStyle: axisLineStyle,
            labelAnchor: labelAnchor,
            labelJustification: labelJustification,
            labelOffsetFromAxis: labelOffsetFromAxis,
            labelCollisionOffsetFromAxis: labelCollisionOffsetFromAxis,
            labelOffsetFromTick: labelOffsetFromTick,
            labelCollisionOffsetFromTick: labelCollisionOffsetFromTick,
            minimumPaddingBetweenLabels: minimumPaddingBetweenLabels,
            labelRotation: labelRotation,
            labelCollisionRotation: labelCollisionRotation);

  @override
  void draw(
    ChartCanvas canvas,
    TickElement<D> tick, {
    @required AxisOrientation orientation,
    @required Rect axisBounds,
    @required Rect drawAreaBounds,
    @required bool isFirst,
    @required bool isLast,
    bool collision = false,
  }) {}

  @override
  void drawLabel(
    ChartCanvas canvas,
    TickElement<D> tick, {
    @required AxisOrientation orientation,
    @required Rect axisBounds,
    @required Rect drawAreaBounds,
    bool isFirst = false,
    bool isLast = false,
    bool collision = false,
  }) {
    super.drawLabel(canvas, tick,
        orientation: orientation,
        axisBounds: axisBounds,
        drawAreaBounds: drawAreaBounds,
        isFirst: isFirst,
        isLast: isLast,
        collision: collision);
  }
}

/// Fake [TextElement] for testing.
///
/// [baseline] returns the same value as the [verticalSliceWidth] specified.
class FakeTextElement implements TextElement {
  static const _defaultVerticalSliceWidth = 15.0;

  @override
  final String text;

  @override
  final TextMeasurement measurement;

  @override
  var textStyle = TextStyle();

  @override
  double maxWidth;

  @override
  MaxWidthStrategy maxWidthStrategy;

  @override
  TextDirectionAligment textDirection;
  double opacity;

  FakeTextElement(
    this.text,
    this.textDirection,
    double horizontalSliceWidth,
    double verticalSliceWidth,
  ) : measurement = TextMeasurement(
            horizontalSliceWidth: horizontalSliceWidth,
            verticalSliceWidth:
                verticalSliceWidth ?? _defaultVerticalSliceWidth);
}

class MockGraphicsFactory extends Mock implements GraphicsFactory {}

class MockChartCanvas extends Mock implements ChartCanvas {}

/// Helper function to create [TickElement] for testing.
TickElement<String> createTick(String value, double location,
    {double horizontalWidth,
    double verticalWidth,
    TextDirectionAligment textDirection,
    bool collision = false}) {
  return TickElement<String>(
      value: value,
      location: location,
      textElement: FakeTextElement(
          value, textDirection, horizontalWidth, verticalWidth));
}

void main() {
  GraphicsFactory graphicsFactory;
  ChartContext chartContext;

  setUpAll(() {
    graphicsFactory = MockGraphicsFactory();
    when(graphicsFactory.createLinePaint()).thenReturn(LineStyle());
    when(graphicsFactory.createTextPaint()).thenReturn(TextStyle());

    chartContext = MockContext();
    when(chartContext.chartContainerIsRtl).thenReturn(false);
    when(chartContext.isRtl).thenReturn(false);
  });

  group('collision detection - vertically drawn axis', () {
    test('ticks do not collide', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 2);

      final ticks = [
        createTick('A', 10.0, verticalWidth: 8.0), // 10.0 - 20.0 (18.0 + 2)
        createTick('B', 20.0, verticalWidth: 8.0), // 20.0 - 30.0 (28.0 + 2)
        createTick('C', 30.0, verticalWidth: 8.0), // 30.0 - 40.0 (38.0 + 2)
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks collide because it does not have minimum padding', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 2);

      final ticks = [
        createTick('A', 10.0, verticalWidth: 8.0), // 10.0 - 20.0 (18.0 + 2)
        createTick('B', 20.0, verticalWidth: 9.0), // 20.0 - 31.0 (28.0 + 3)
        createTick('C', 30.0, verticalWidth: 8.0), // 30.0 - 40.0 (38.0 + 2)
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('first tick causes collision', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 0);

      final ticks = [
        createTick('A', 10.0, verticalWidth: 11.0), // 10.0 - 21.0
        createTick('B', 20.0, verticalWidth: 10.0), // 20.0 - 30.0
        createTick('C', 30.0, verticalWidth: 10.0), // 30.0 - 40.0
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('last tick causes collision', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 0);

      final ticks = [
        createTick('A', 10.0, verticalWidth: 10.0), // 10.0 - 20.0
        createTick('B', 20.0, verticalWidth: 10.0), // 20.0 - 30.0
        createTick('C', 29.0, verticalWidth: 10.0), // 29.0 - 40.0
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks do not collide for inside tick label anchor', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 2, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('A', 10.0, verticalWidth: 8.0), // 10.0 - 20.0 (18.0 + 2)
        createTick('B', 25.0, verticalWidth: 8.0), // 20.0 - 30.0 (25 + 2 + 1)
        createTick('C', 40.0, verticalWidth: 8.0), // 30.0 - 40.0 (40-8-2)
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks collide for inside anchor - first tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 2, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('A', 10.0, verticalWidth: 9.0), // 10.0 - 21.0 (19.0 + 2)
        createTick('B', 25.0, verticalWidth: 8.0), // 20.0 - 30.0 (25 + 2 + 1)
        createTick('C', 40.0, verticalWidth: 8.0), // 30.0 - 40.0 (40-8-2)
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks collide for inside anchor - center tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 2, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('A', 10.0, verticalWidth: 8.0), // 10.0 - 20.0 (18.0 + 2)
        createTick('B', 25.0, verticalWidth: 9.0), // 19.5 - 30.5 (25 + 2.5 + 1)
        createTick('C', 40.0, verticalWidth: 8.0), // 30.0 - 40.0 (40-8-2)
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks collide for inside anchor - last tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 2, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('A', 10.0, verticalWidth: 8.0), // 10.0 - 20.0 (18.0 + 2)
        createTick('B', 25.0, verticalWidth: 8.0), // 20.0 - 30.0 (25 + 2 + 1)
        createTick('C', 40.0, verticalWidth: 9.0), // 29.0 - 40.0 (40-9-2)
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.left);

      expect(report.ticksCollide, isTrue);
    });
  });

  group('collision detection - horizontally drawn axis', () {
    test('ticks do not collide for TickLabelAnchor.before', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 2, labelAnchor: TickLabelAnchor.before);

      final ticks = [
        createTick('A', 10.0, horizontalWidth: 8.0), // 10.0 - 20.0 (18.0 + 2)
        createTick('B', 20.0, horizontalWidth: 8.0), // 20.0 - 30.0 (28.0 + 2)
        createTick('C', 30.0, horizontalWidth: 8.0), // 30.0 - 40.0 (38.0 + 2)
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks do not collide for TickLabelAnchor.inside', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 0, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('A', 10.0,
            horizontalWidth: 10.0,
            textDirection: TextDirectionAligment.ltr), // 10.0 - 20.0
        createTick('B', 25.0,
            horizontalWidth: 10.0,
            textDirection: TextDirectionAligment.center), // 20.0 - 30.0
        createTick('C', 40.0,
            horizontalWidth: 10.0,
            textDirection: TextDirectionAligment.rtl), // 30.0 - 40.0
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks collide - first tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 0, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('A', 10.0, horizontalWidth: 11.0), // 10.0 - 21.0
        createTick('B', 25.0, horizontalWidth: 10.0), // 20.0 - 30.0
        createTick('C', 40.0, horizontalWidth: 10.0), // 30.0 - 40.0
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks collide - middle tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 0, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('A', 10.0, horizontalWidth: 10.0), // 10.0 - 20.0
        createTick('B', 25.0, horizontalWidth: 11.0), // 19.5 - 30.5
        createTick('C', 40.0, horizontalWidth: 10.0), // 30.0 - 40.0
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isTrue);
    });

    test('ticks collide - last tick too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 0, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('A', 10.0, horizontalWidth: 10.0), // 10.0 - 20.0
        createTick('B', 25.0, horizontalWidth: 10.0), // 20.0 - 30.0
        createTick('C', 40.0, horizontalWidth: 11.0), // 29.0 - 40.0
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isTrue);
    });
  });

  group('collision detection - unsorted ticks', () {
    test('ticks do not collide', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 0, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('C', 40.0, horizontalWidth: 10.0), // 30.0 - 40.0
        createTick('B', 25.0, horizontalWidth: 10.0), // 20.0 - 30.0
        createTick('A', 10.0, horizontalWidth: 10.0), // 10.0 - 20.0
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isFalse);
    });

    test('ticks collide - tick B is too large', () {
      final drawStrategy = BaseTickDrawStrategyImpl(
          chartContext, graphicsFactory,
          minimumPaddingBetweenLabels: 0, labelAnchor: TickLabelAnchor.inside);

      final ticks = [
        createTick('A', 10.0, horizontalWidth: 10.0), // 10.0 - 20.0
        createTick('C', 40.0, horizontalWidth: 10.0), // 30.0 - 40.0
        createTick('B', 25.0, horizontalWidth: 11.0), // 19.5 - 30.5
      ];

      final report = drawStrategy.collides(ticks, AxisOrientation.bottom);

      expect(report.ticksCollide, isTrue);
    });
  });

  group('collision detection - corner cases', () {
    test('null ticks do not collide', () {
      final drawStrategy =
          BaseTickDrawStrategyImpl(chartContext, graphicsFactory);

      final report = drawStrategy.collides(null, AxisOrientation.left);

      expect(report.ticksCollide, isFalse);
    });

    test('empty tick list do not collide', () {
      final drawStrategy =
          BaseTickDrawStrategyImpl(chartContext, graphicsFactory);

      final report = drawStrategy.collides([], AxisOrientation.left);

      expect(report.ticksCollide, isFalse);
    });

    test('single tick does not collide', () {
      final drawStrategy =
          BaseTickDrawStrategyImpl(chartContext, graphicsFactory);

      final report = drawStrategy.collides(
          [createTick('A', 10.0, horizontalWidth: 10.0)],
          AxisOrientation.bottom);

      expect(report.ticksCollide, isFalse);
    });
  });
  group('Draw Label', () {
    void setUpLabel(String text, {double width}) =>
        when(graphicsFactory.createTextElement(text))
            .thenReturn(FakeTextElement(
          text,
          TextDirectionAligment.ltr,
          width,
          15.0,
        ));

    BaseTickDrawStrategyImpl drawStrategy;
    List<TickElement> ticks;

    setUp(() {
      drawStrategy = BaseTickDrawStrategyImpl(chartContext, graphicsFactory);

      ticks = [
        createTick('This label \nspans \n multiple lines!!!', 0.0,
            horizontalWidth: 100.0, verticalWidth: 15.0), // 10.0 - 20.0
        createTick('A', 20.0,
            horizontalWidth: 10.0, verticalWidth: 15.0), // 30.0 - 40.0
      ];

      setUpLabel('This label', width: 30.0);
      setUpLabel('spans', width: 10.0);
      setUpLabel('multiple lines!!!', width: 60.0);
      setUpLabel('A', width: 10.0);
    });

    test('measureHorizontallyDrawnTicks', () {
      final offset = drawStrategy.labelOffsetFromAxis(collision: false);
      final sizes = drawStrategy.measureHorizontallyDrawnTicks(ticks, 250, 500);

      // Text-Height * numLines + paddingBetweenLines + offset.
      expect(sizes.preferredHeight, 15 * 3 + 4 + offset);
      expect(sizes.preferredWidth, 250);
    });

    test('measureVerticallyDrawnTicks', () {
      final offset = drawStrategy.labelOffsetFromAxis(collision: false);
      final sizes = drawStrategy.measureVerticallyDrawnTicks(ticks, 250, 500);

      // Width of the longest line + offset.
      expect(sizes.preferredWidth, 60.0 + offset);
      expect(sizes.preferredHeight, 500);
    });

    test('measureVerticallyDrawnTicks - negative labelOffsetFromAxis', () {
      final offset = -500.0;
      drawStrategy = BaseTickDrawStrategyImpl(chartContext, graphicsFactory,
          labelOffsetFromAxis: offset);
      final sizes = drawStrategy.measureVerticallyDrawnTicks(ticks, 250, 500);

      expect(sizes.preferredWidth, 0);
      expect(sizes.preferredHeight, 500);
    });

    test('Draw multiline label', () {
      final chartCanvas = MockChartCanvas();
      final axisBounds = Rect.fromLTWH(0, 0, 1000, 1000);

      drawStrategy.drawLabel(
        chartCanvas,
        ticks.first,
        orientation: AxisOrientation.bottom,
        axisBounds: axisBounds,
        drawAreaBounds: null,
      );

      // The y-coordinate should increase by the line's height + padding.
      final labelLine1 =
          verify(chartCanvas.drawText(captureAny, 0, 5, rotation: 0))
              .captured
              .single as TextElement;
      expect(labelLine1.text, 'This label');

      final labelLine2 =
          verify(chartCanvas.drawText(captureAny, 0, 22, rotation: 0))
              .captured
              .single as TextElement;
      expect(labelLine2.text, 'spans');

      final labelLine3 =
          verify(chartCanvas.drawText(captureAny, 0, 39, rotation: 0))
              .captured
              .single as TextElement;
      expect(labelLine3.text, 'multiple lines!!!');
    });

    test('Draw single line label', () {
      final chartCanvas = MockChartCanvas();
      final axisBounds = Rect.fromLTWH(0, 0, 1000, 1000);

      drawStrategy.drawLabel(
        chartCanvas,
        ticks[1],
        orientation: AxisOrientation.top,
        axisBounds: axisBounds,
        drawAreaBounds: null,
      );

      final labelLine =
          verify(chartCanvas.drawText(captureAny, 20, 980, rotation: 0))
              .captured
              .single as TextElement;
      expect(labelLine.text, 'A');
    });
  });

  group('Draw Label with collision', () {
    const collisionRotationDegrees = 45.0;
    const collisionRotationRadians = 0.7853981633974483;

    void setUpLabel(String text, {double width}) =>
        when(graphicsFactory.createTextElement(text))
            .thenReturn(FakeTextElement(
          text,
          TextDirectionAligment.ltr,
          width,
          15.0,
        ));

    BaseTickDrawStrategyImpl drawStrategy;
    List<TickElement> ticks;

    setUp(() {
      drawStrategy = BaseTickDrawStrategyImpl(chartContext, graphicsFactory,
          labelCollisionRotation: collisionRotationDegrees);

      ticks = [
        createTick('This label \nspans \n multiple lines!!!', 0.0,
            horizontalWidth: 100.0,
            verticalWidth: 15.0,
            collision: true), // 10.0 - 20.0
        createTick('A', 20.0,
            horizontalWidth: 10.0,
            verticalWidth: 15.0,
            collision: true), // 30.0 - 40.0
      ];

      setUpLabel('This label', width: 30.0);
      setUpLabel('spans', width: 10.0);
      setUpLabel('multiple lines!!!', width: 60.0);
      setUpLabel('A', width: 10.0);
    });

    test('measureHorizontallyDrawnTicks', () {
      final offset = drawStrategy.labelOffsetFromAxis(collision: true);
      final sizes = drawStrategy.measureHorizontallyDrawnTicks(ticks, 250, 500,
          collision: true);

      // Text-Height * numLines + paddingBetweenLines + offset.
      var baseHeight = (15 * 3 + 4);
      var heightAdjustedForAngle = drawStrategy.calculateHeightForRotatedLabel(
          collisionRotationDegrees,
          baseHeight.toDouble(),
          60 /* width of longest label */);

      expect(sizes.preferredHeight, (heightAdjustedForAngle + offset).ceil());
      expect(sizes.preferredWidth, 250);
    });

    test('measureVerticallyDrawnTicks', () {
      final offset = drawStrategy.labelOffsetFromAxis(collision: true);
      final sizes = drawStrategy.measureVerticallyDrawnTicks(ticks, 250, 500,
          collision: true);

      // Width of the longest line + offset.
      expect(sizes.preferredWidth, closeTo(59.75 + offset, 0.001));
      expect(sizes.preferredHeight, 500);
    });

    test('measureVerticallyDrawnTicks - negativate labelOffsetFromAxis', () {
      final offset = -500.0;
      drawStrategy = BaseTickDrawStrategyImpl(chartContext, graphicsFactory,
          labelCollisionRotation: 45, labelCollisionOffsetFromAxis: offset);
      final sizes = drawStrategy.measureVerticallyDrawnTicks(ticks, 250, 500,
          collision: true);

      expect(sizes.preferredWidth, 0);
      expect(sizes.preferredHeight, 500);
    });

    test('Draw multiline label', () {
      final chartCanvas = MockChartCanvas();
      final axisBounds = Rect.fromLTWH(0, 0, 1000, 1000);

      drawStrategy.drawLabel(
        chartCanvas,
        ticks.first,
        orientation: AxisOrientation.bottom,
        axisBounds: axisBounds,
        drawAreaBounds: null,
        collision: true,
      );

      // The y-coordinate should increase by the line's height + padding.
      final labelLine1 = verify(chartCanvas.drawText(captureAny, -5, 5,
              rotation: collisionRotationRadians))
          .captured
          .single;
      expect(labelLine1.text, 'This label');

      final labelLine2 = verify(chartCanvas.drawText(captureAny, -5, 22,
              rotation: collisionRotationRadians))
          .captured
          .single;
      expect(labelLine2.text, 'spans');

      final labelLine3 = verify(chartCanvas.drawText(captureAny, -5, 39,
              rotation: collisionRotationRadians))
          .captured
          .single;
      expect(labelLine3.text, 'multiple lines!!!');
    });

    test('Draw single line label', () {
      final chartCanvas = MockChartCanvas();
      final axisBounds = Rect.fromLTWH(0, 0, 1000, 1000);

      drawStrategy.drawLabel(
        chartCanvas,
        ticks[1],
        orientation: AxisOrientation.top,
        axisBounds: axisBounds,
        drawAreaBounds: null,
        collision: true,
      );

      final labelLine = verify(chartCanvas.drawText(captureAny, 15, 980,
              rotation: collisionRotationRadians))
          .captured
          .single;
      expect(labelLine.text, 'A');
    });
  });

  group('Adjust width of labels based on size', () {
    void setUpLabel(String text, {double width}) =>
        when(graphicsFactory.createTextElement(text))
            .thenReturn(FakeTextElement(
          text,
          TextDirectionAligment.ltr,
          width,
          15.0,
        ));

    BaseTickDrawStrategyImpl drawStrategy;
    List<TickElement> ticks;

    setUp(() {
      ticks = [
        createTick('This label is long', 0.0,
            horizontalWidth: 50.0, verticalWidth: 15.0),
        createTick('Test', 0.0, horizontalWidth: 10.0, verticalWidth: 15.0),
      ];

      setUpLabel('This label is long', width: 50.0);
      setUpLabel('Test', width: 10.0);
    });

    test('Sets max width for vertical labels', () {
      drawStrategy = BaseTickDrawStrategyImpl(chartContext, graphicsFactory,
          labelOffsetFromTick: 0, labelOffsetFromAxis: 0);

      drawStrategy.updateTickWidth(ticks, 25, 500, AxisOrientation.left);
      expect(ticks.first.textElement.maxWidth, 25);
      expect(
          ticks.first.textElement.maxWidthStrategy, MaxWidthStrategy.ellipsize);
      expect(ticks.last.textElement.maxWidth, 25);
      expect(
          ticks.last.textElement.maxWidthStrategy, MaxWidthStrategy.ellipsize);
    });

    test('Sets max width for vertical labels that are parallel to the axis ',
        () {
      drawStrategy = BaseTickDrawStrategyImpl(chartContext, graphicsFactory,
          labelOffsetFromTick: 0, labelOffsetFromAxis: 0, labelRotation: 90);

      drawStrategy.updateTickWidth(ticks, 25, 500, AxisOrientation.left);
      expect(ticks.first.textElement.maxWidth, null);
      expect(ticks.first.textElement.maxWidthStrategy, null);
      expect(ticks.last.textElement.maxWidth, null);
      expect(ticks.last.textElement.maxWidthStrategy, null);
    });

    test('Sets max width for vertical labels that are angled', () {
      drawStrategy = BaseTickDrawStrategyImpl(chartContext, graphicsFactory,
          labelOffsetFromTick: 0, labelOffsetFromAxis: 0, labelRotation: 45);

      drawStrategy.updateTickWidth(ticks, 25, 500, AxisOrientation.left);
      expect(ticks.first.textElement.maxWidth, closeTo(35.355, 0.001));
      expect(
          ticks.first.textElement.maxWidthStrategy, MaxWidthStrategy.ellipsize);
      expect(ticks.last.textElement.maxWidth, closeTo(35.355, 0.001));
      expect(
          ticks.last.textElement.maxWidthStrategy, MaxWidthStrategy.ellipsize);
    });

    test('Sets max width for horizontal labels', () {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromTick: 0,
        labelOffsetFromAxis: 0,
        // 90 degrees makes the labels directly perpendicular to the axis.
        labelRotation: 90,
      );

      drawStrategy.updateTickWidth(ticks, 500, 25, AxisOrientation.bottom);
      expect(ticks.first.textElement.maxWidth, 25);
      expect(
          ticks.first.textElement.maxWidthStrategy, MaxWidthStrategy.ellipsize);
      expect(ticks.last.textElement.maxWidth, 25);
      expect(
          ticks.last.textElement.maxWidthStrategy, MaxWidthStrategy.ellipsize);
    });

    test('Sets max width for horizontal labels that are parallel to the axis',
        () {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromTick: 0,
        labelOffsetFromAxis: 0,
      );

      drawStrategy.updateTickWidth(ticks, 500, 25, AxisOrientation.bottom);
      expect(ticks.first.textElement.maxWidth, null);
      expect(ticks.first.textElement.maxWidthStrategy, null);
      expect(ticks.last.textElement.maxWidth, null);
      expect(ticks.last.textElement.maxWidthStrategy, null);
    });

    test('Sets max width for horizontal labels that are angled', () {
      drawStrategy = BaseTickDrawStrategyImpl(
        chartContext,
        graphicsFactory,
        labelOffsetFromTick: 0,
        labelOffsetFromAxis: 0,
        labelRotation: 45,
      );

      drawStrategy.updateTickWidth(ticks, 500, 25, AxisOrientation.bottom);
      expect(ticks.first.textElement.maxWidth, closeTo(35.355, 0.001));
      expect(
          ticks.first.textElement.maxWidthStrategy, MaxWidthStrategy.ellipsize);
      expect(ticks.last.textElement.maxWidth, closeTo(35.355, 0.001));
      expect(
          ticks.last.textElement.maxWidthStrategy, MaxWidthStrategy.ellipsize);
    });
  });
}
