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

import 'package:charts/core.dart';
import 'package:meta/meta.dart' show immutable;

@immutable
class GridlineAxisDecoration<D> extends SmallTickAxisDecoration<D> {
  const GridlineAxisDecoration({
    super.labelStyle,
    super.lineStyle,
    super.axisLineStyle,
    super.labelAnchor,
    super.labelJustification,
    super.tickLength,
    super.labelOffsetFromAxis,
    super.labelCollisionOffsetFromAxis,
    super.labelOffsetFromTick,
    super.labelCollisionOffsetFromTick,
    super.minimumPaddingBetweenLabels,
    super.labelRotation,
    super.labelCollisionRotation,
  });

  @override
  TickDrawStrategy<D> createDrawStrategy(
    ChartContext context,
    GraphicsFactory graphicsFactory,
  ) =>
      GridlineTickDrawStrategy<D>(
        context,
        graphicsFactory,
        tickLength: tickLength,
        lineStyle: lineStyle,
        labelStyleSpec: labelStyle,
        axisLineStyle: axisLineStyle,
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
}

/// Draws line across chart draw area for each tick.
///
/// Extends [BaseTickDrawStrategy].
class GridlineTickDrawStrategy<D> extends BaseTickDrawStrategy<D> {
  GridlineTickDrawStrategy(
    super.chartContext,
    super.graphicsFactory, {
    double? tickLength,
    LineStyle? lineStyle,
    super.labelStyleSpec,
    LineStyle? axisLineStyle,
    super.labelAnchor,
    super.labelJustification,
    super.labelOffsetFromAxis,
    super.labelCollisionOffsetFromAxis,
    super.labelOffsetFromTick,
    super.labelCollisionOffsetFromTick,
    super.minimumPaddingBetweenLabels,
    super.labelRotation,
    super.labelCollisionRotation,
  })  : tickLength = tickLength ?? 0.0,
        lineStyle =
            StyleFactory.style.createGridlineStyle(graphicsFactory, lineStyle),
        super(
          axisLineStyle: axisLineStyle ?? lineStyle,
        );
  double tickLength;
  LineStyle lineStyle;

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
    Point<num> lineStart;
    Point<num> lineEnd;
    final tickLocation = tick.location!;
    switch (orientation) {
      case AxisOrientation.top:
        final x = tickLocation;
        lineStart = Point(x, axisBounds.bottom - tickLength);
        lineEnd = Point(x, drawAreaBounds.bottom);
        break;
      case AxisOrientation.bottom:
        final x = tickLocation;
        lineStart = Point(x, drawAreaBounds.top + tickLength);
        lineEnd = Point(x, axisBounds.top);
        break;
      case AxisOrientation.right:
        final y = tickLocation;
        if (tickLabelAnchor(collision: collision) == TickLabelAnchor.after ||
            tickLabelAnchor(collision: collision) == TickLabelAnchor.before) {
          lineStart = Point(axisBounds.right, y);
        } else {
          lineStart = Point(axisBounds.left + tickLength, y);
        }
        lineEnd = Point(drawAreaBounds.left, y);
        break;
      case AxisOrientation.left:
        final y = tickLocation;

        if (tickLabelAnchor(collision: collision) == TickLabelAnchor.after ||
            tickLabelAnchor(collision: collision) == TickLabelAnchor.before) {
          lineStart = Point(axisBounds.left, y);
        } else {
          lineStart = Point(axisBounds.right - tickLength, y);
        }
        lineEnd = Point(drawAreaBounds.right, y);
        break;
    }

    canvas.drawLine(
      points: [lineStart, lineEnd],
      dashPattern: lineStyle.dashPattern,
      fill: lineStyle.color,
      stroke: lineStyle.color,
      strokeWidth: lineStyle.strokeWidth,
    );

    drawLabel(
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
