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

import 'dart:math';

import 'package:charts/charts.dart';
import 'package:charts/core.dart';
import 'package:meta/meta.dart' show immutable;

/// Displays individual ticks and range ticks and with a shade for ranges.
/// Sample ticks looks like:
/// -------------------------------------------------------------------
///  |   |                       |            |                    |
///  |   (Individual tick)       |            (Individual tick)    |
///  |///////Range Label/////////|///////////Range Label///////////|
@immutable
class RangeTickAxisDecoration<D> extends SmallTickAxisDecoration<D> {
  RangeTickAxisDecoration({
    super.labelStyle,
    LineStyle? lineStyle,
    super.labelAnchor,
    super.labelJustification,
    double? labelOffsetFromAxis,
    super.labelCollisionOffsetFromAxis,
    double? labelOffsetFromTick,
    super.labelCollisionOffsetFromTick,
    this.rangeShadeHeight,
    this.rangeShadeOffsetFromAxis,
    this.rangeShadeStyle,
    this.rangeTickLength,
    this.rangeTickOffset,
    this.rangeLabelStyle,
    super.tickLength,
    super.minimumPaddingBetweenLabels,
    super.labelRotation,
    super.labelCollisionRotation,
  })  : defaultLabelStyleSpec =
            TextStyle(fontSize: 9, color: StyleFactory.style.tickColor),
        super(
          axisLineStyle: lineStyle,
          labelOffsetFromAxis:
              labelOffsetFromAxis ?? defaultLabelOffsetFromAxis,
          labelOffsetFromTick:
              labelOffsetFromTick ?? defaultLabelOffsetFromTick,
        );
  // Specifies range shade's style.
  final LineStyle? rangeShadeStyle;
  // Specifies range label text style.
  final TextStyle? rangeLabelStyle;
  // Specifies range tick's length.
  final double? rangeTickLength;
  // Specifies range shade's height.
  final double? rangeShadeHeight;
  // Specifies the starting offet of range shade from axis in pixels.
  final double? rangeShadeOffsetFromAxis;
  // A range tick offset from the original location. The start point offset is
  // toward the origin and end point offset is toward the end of axis.
  final double? rangeTickOffset;

  final TextStyle defaultLabelStyleSpec;

  static const double defaultLabelOffsetFromAxis = 2;
  static const double defaultLabelOffsetFromTick = -4;

  @override
  TickDrawStrategy<D> createDrawStrategy(
    ChartContext context,
    GraphicsFactory graphicsFactory,
  ) =>
      RangeTickDrawStrategy<D>(
        context,
        graphicsFactory,
        tickLength: tickLength,
        rangeLabelTextStyle: rangeLabelStyle,
        rangeTickLength: rangeTickLength,
        rangeShadeHeight: rangeShadeHeight,
        rangeShadeOffsetFromAxis: rangeShadeOffsetFromAxis,
        rangeTickOffset: rangeTickOffset,
        lineStyle: lineStyle,
        labelStyleSpec: labelStyle ?? defaultLabelStyleSpec,
        axisLineStyle: axisLineStyle,
        rangeShadeStyleSpec: rangeShadeStyle,
        labelAnchor: labelAnchor,
        labelJustification: labelJustification,
        labelOffsetFromAxis: labelOffsetFromAxis,
        labelCollisionOffsetFromAxis: labelCollisionOffsetFromAxis,
        labelOffsetFromTick: labelOffsetFromTick,
        labelCollisionOffsetFromTick: labelCollisionOffsetFromTick,
        minimumPaddingBetweenLabels: minimumPaddingBetweenLabels,
        labelRotation: labelRotation,
        labelCollisionRotation: labelCollisionRotation,
      );

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is RangeTickAxisDecoration && super == other);
  }
}

/// Draws small tick lines for each tick. Extends [BaseTickDrawStrategy].
class RangeTickDrawStrategy<D> extends SmallTickDrawStrategy<D> {
  RangeTickDrawStrategy(
    ChartContext chartContext,
    GraphicsFactory graphicsFactory, {
    double? tickLength,
    double? rangeTickLength,
    double? rangeShadeHeight,
    double? rangeShadeOffsetFromAxis,
    double? rangeTickOffset,
    TextStyle? rangeLabelTextStyle,
    LineStyle? lineStyle,
    LineStyle? rangeShadeStyleSpec,
    TextStyle? labelStyleSpec,
    LineStyle? axisLineStyle,
    TickLabelAnchor? labelAnchor,
    double? labelOffsetFromAxis,
    double? labelCollisionOffsetFromAxis,
    double? labelOffsetFromTick,
    double? labelCollisionOffsetFromTick,
    TickLabelJustification? labelJustification,
    double? minimumPaddingBetweenLabels,
    double? labelRotation,
    double? labelCollisionRotation,
  }) : super(
          chartContext,
          graphicsFactory,
          tickLength: tickLength,
          axisLineStyle: axisLineStyle,
          labelStyleSpec: labelStyleSpec,
          lineStyle: lineStyle,
          labelAnchor: labelAnchor ?? TickLabelAnchor.after,
          labelJustification: labelJustification,
          labelOffsetFromAxis: labelOffsetFromAxis,
          labelCollisionOffsetFromAxis: labelCollisionOffsetFromAxis,
          labelOffsetFromTick: labelOffsetFromTick,
          labelCollisionOffsetFromTick: labelCollisionOffsetFromTick,
          minimumPaddingBetweenLabels: minimumPaddingBetweenLabels,
          labelRotation: labelRotation,
          labelCollisionRotation: labelCollisionRotation,
        ) {
    rangeTickOffset = rangeTickOffset ?? this.rangeTickOffset;
    rangeTickLength = rangeTickLength ?? this.rangeTickLength;
    rangeShadeHeight = rangeShadeHeight ?? this.rangeShadeHeight;
    rangeShadeOffsetFromAxis =
        rangeShadeOffsetFromAxis ?? rangeShadeOffsetFromAxis;
    lineStyle =
        StyleFactory.style.createTickLineStyle(graphicsFactory, lineStyle);
    rangeShadeStyleSpec = LineStyle(
      color: Colors.grey.shade300,
    ).merge(rangeShadeStyleSpec);
    rangeShadeStyle = StyleFactory.style
        .createTickLineStyle(graphicsFactory, rangeShadeStyleSpec);
    rangeLabelStyle = rangeLabelTextStyle == null
        ? graphicsFactory
            .createTextPaint()
            .merge(TextStyle(color: StyleFactory.style.tickColor))
            .merge(labelStyleSpec)
            .copyWith(fontSize: rangeShadeHeight - 1)
        : graphicsFactory.createTextPaint().merge(rangeLabelTextStyle);
  }
  double rangeTickLength = 24;
  double rangeShadeHeight = 12;
  double rangeShadeOffsetFromAxis = 12;
  double rangeTickOffset = 12;
  late LineStyle rangeShadeStyle;
  late TextStyle rangeLabelStyle;

  @override
  void draw(
    ChartCanvas canvas,
    TickElement<D> tick, {
    required AxisOrientation orientation,
    required Rect axisBounds,
    required Rect drawAreaBounds,
    required bool isFirst,
    required bool isLast,
    bool collision = false,
  }) {
    if (tick is RangeAxisTicks<D>) {
      drawRangeShadeAndRangeLabel(
        tick,
        canvas,
        orientation,
        axisBounds,
        drawAreaBounds,
        isFirst,
        isLast,
      );
    } else {
      super.draw(
        canvas,
        tick,
        orientation: orientation,
        axisBounds: axisBounds,
        drawAreaBounds: drawAreaBounds,
        isFirst: isFirst,
        isLast: isLast,
        collision: collision,
      );
    }
  }

  @override
  ViewMeasuredSizes measureVerticallyDrawnTicks(
    List<TickElement<D>> ticks,
    double maxWidth,
    double maxHeight, {
    bool collision = false,
  }) {
    // TODO: Add spacing to account for the distance between the
    // text and the axis baseline (even if it isn't drawn).

    final maxHorizontalSliceWidth =
        ticks.fold<double>(0.0, (double prevMax, tick) {
      assert(tick.textElement != null);
      final labelElements = splitLabel(tick.textElement!);
      if (tick is RangeAxisTicks) {
        // Find the maximum within prevMax, label total height and
        // labelOffsetFromAxis + rangeShadeHeight.
        return max(
          max(
            prevMax,
            calculateWidthForRotatedLabel(
                  labelRotation(collision: collision),
                  getLabelHeight(labelElements),
                  getLabelWidth(labelElements),
                ) +
                labelOffsetFromAxis(collision: collision),
          ),
          labelOffsetFromAxis(collision: collision) + rangeShadeHeight,
        );
      } else {
        return max(
          prevMax,
          calculateWidthForRotatedLabel(
                labelRotation(collision: collision),
                getLabelHeight(labelElements),
                getLabelWidth(labelElements),
              ) +
              labelOffsetFromAxis(collision: collision),
        );
      }
    });

    return ViewMeasuredSizes(
      preferredWidth: maxHorizontalSliceWidth,
      preferredHeight: maxHeight,
    );
  }

  @override
  ViewMeasuredSizes measureHorizontallyDrawnTicks(
    List<TickElement<D>> ticks,
    double maxWidth,
    double maxHeight, {
    bool collision = false,
  }) {
    final maxVerticalSliceWidth =
        ticks.fold<double>(0.0, (double prevMax, tick) {
      final labelElements = splitLabel(tick.textElement!);

      if (tick is RangeAxisTicks) {
        // Find the maximum within prevMax, label total height and
        // labelOffsetFromAxis + rangeShadeHeight.
        return max(
          max(
            prevMax,
            calculateHeightForRotatedLabel(
                  labelRotation(collision: collision),
                  getLabelHeight(labelElements),
                  getLabelWidth(labelElements),
                ) +
                rangeShadeOffsetFromAxis,
          ),
          rangeShadeOffsetFromAxis + rangeShadeHeight,
        );
      } else {
        return max(
              prevMax,
              calculateHeightForRotatedLabel(
                labelRotation(collision: collision),
                getLabelHeight(labelElements),
                getLabelWidth(labelElements),
              ),
            ) +
            labelOffsetFromAxis(collision: collision);
      }
    });

    return ViewMeasuredSizes(
      preferredWidth: maxWidth,
      preferredHeight: maxVerticalSliceWidth,
    );
  }

  void drawRangeShadeAndRangeLabel(
    RangeAxisTicks<D> tick,
    ChartCanvas canvas,
    AxisOrientation orientation,
    Rect axisBounds,
    Rect drawAreaBounds,
    bool isFirst,
    bool isLast,
  ) {
    // Create virtual range start and end ticks for position calculation.
    final rangeStartTick = TickElement<D>(
      value: tick.rangeStartValue,
      location: tick.rangeStartLocation - rangeTickOffset,
      textElement: null,
    );
    final rangeEndTick = TickElement<D>(
      value: tick.rangeEndValue,
      location: isLast
          ? tick.rangeEndLocation + rangeTickOffset
          : tick.rangeEndLocation - rangeTickOffset,
      textElement: null,
    );
    // Calculate range start positions.
    final rangeStartPositions = calculateTickPositions(
      rangeStartTick,
      orientation,
      axisBounds,
      drawAreaBounds,
      rangeTickLength,
    );
    final rangeStartTickStart = rangeStartPositions.first;
    final rangeStartTickEnd = rangeStartPositions.last;

    // Calculate range end positions.
    final rangeEndPositions = calculateTickPositions(
      rangeEndTick,
      orientation,
      axisBounds,
      drawAreaBounds,
      rangeTickLength,
    );
    final rangeEndTickStart = rangeEndPositions.first;
    final rangeEndTickEnd = rangeEndPositions.last;

    // Draw range shade.
    Rect rangeShade;
    switch (orientation) {
      case AxisOrientation.top:
      case AxisOrientation.bottom:
        rangeShade = Rect.fromLTWH(
          rangeStartTickStart.dx.toDouble(),
          rangeStartTickStart.dy + rangeShadeOffsetFromAxis,
          rangeEndTickStart.dx.toDouble() - rangeStartTickStart.dx,
          rangeShadeHeight,
        );
        break;
      case AxisOrientation.right:
        rangeShade = Rect.fromLTWH(
          rangeEndTickStart.dx + rangeShadeOffsetFromAxis,
          rangeEndTickStart.dy.toDouble(),
          rangeShadeHeight,
          rangeEndTickStart.dy.toDouble() - rangeEndTickStart.dy,
        );
        break;
      case AxisOrientation.left:
        rangeShade = Rect.fromLTWH(
          rangeEndTickStart.dx - rangeShadeOffsetFromAxis - rangeShadeHeight,
          rangeEndTickStart.dy.toDouble(),
          rangeShadeHeight,
          rangeEndTickStart.dy.toDouble() - rangeEndTickStart.dy,
        );
        break;
    }
    canvas.drawRect(
      rangeShade,
      fill: rangeShadeStyle.color,
      stroke: rangeShadeStyle.color,
      strokeWidth: rangeShadeStyle.strokeWidth,
    );

    // Draw the start and end boundaries of the range.
    canvas.drawLine(
      points: [rangeStartTickStart, rangeStartTickEnd],
      dashPattern: lineStyle.dashPattern,
      fill: lineStyle.color,
      stroke: lineStyle.color,
      strokeWidth: lineStyle.strokeWidth,
    );
    canvas.drawLine(
      points: [rangeEndTickStart, rangeEndTickEnd],
      dashPattern: lineStyle.dashPattern,
      fill: lineStyle.color,
      stroke: lineStyle.color,
      strokeWidth: lineStyle.strokeWidth,
    );

    // Prepare range label.
    final rangeLabelTextElement = tick.textElement!
      ..textStyle = rangeLabelStyle;

    final labelElements = splitLabel(rangeLabelTextElement);
    final labelWidth = getLabelWidth(labelElements);

    // Draw range label on top of range shade.
    var multiLineLabelOffset = 0;
    for (final line in labelElements) {
      var x = 0.0;
      var y = 0.0;

      if (orientation == AxisOrientation.bottom ||
          orientation == AxisOrientation.top) {
        y = rangeStartTickStart.dy + rangeShadeOffsetFromAxis - 1;

        x = rangeStartTickStart.dx +
            (rangeEndTickStart.dx - rangeStartTickStart.dx - labelWidth) / 2;
      }
      // TODO: add support for orientation left and right.
      canvas.drawText(line, x, y + multiLineLabelOffset);
      multiLineLabelOffset += BaseTickDrawStrategy.multiLineLabelPadding +
          line.measurement.verticalSliceWidth.round();
    }
  }
}
