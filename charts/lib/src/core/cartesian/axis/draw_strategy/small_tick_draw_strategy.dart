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
class SmallTickAxisDecoration<D> extends BaseAxisDecoration<D> {
  const SmallTickAxisDecoration({
    super.labelStyle,
    this.lineStyle,
    super.axisLineStyle,
    super.labelAnchor,
    super.labelJustification,
    super.labelOffsetFromAxis,
    super.labelCollisionOffsetFromAxis,
    super.labelOffsetFromTick,
    super.labelCollisionOffsetFromTick,
    this.tickLength,
    super.minimumPaddingBetweenLabels,
    super.labelRotation,
    super.labelCollisionRotation,
  });
  final LineStyle? lineStyle;
  final double? tickLength;

  @override
  TickDrawStrategy<D> createDrawStrategy(
    ChartContext context,
    GraphicsFactory graphicsFactory,
  ) =>
      SmallTickDrawStrategy<D>(
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

  @override
  List<Object?> get props => [lineStyle, tickLength, super.props];
}

/// Draws small tick lines for each tick. Extends [BaseTickDrawStrategy].
class SmallTickDrawStrategy<D> extends BaseTickDrawStrategy<D> {
  SmallTickDrawStrategy(
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
  })  : tickLength = tickLength ?? StyleFactory.style.tickLength,
        lineStyle =
            StyleFactory.style.createTickLineStyle(graphicsFactory, lineStyle),
        super(
          axisLineStyle: lineStyle?.merge(axisLineStyle) ?? axisLineStyle,
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
    final tickPositions = calculateTickPositions(
      tick,
      orientation,
      axisBounds,
      drawAreaBounds,
      tickLength,
    );
    final tickStart = tickPositions.first;
    final tickEnd = tickPositions.last;

    canvas.drawLine(
      points: [tickStart, tickEnd],
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

  List<Offset> calculateTickPositions(
    TickElement<D> tick,
    AxisOrientation orientation,
    Rect axisBounds,
    Rect drawAreaBounds,
    double tickLength,
  ) {
    Offset tickStart;
    Offset tickEnd;
    final tickLocation = tick.location!;
    switch (orientation) {
      case AxisOrientation.top:
        final x = tickLocation;
        tickStart = Offset(x, axisBounds.bottom - tickLength);
        tickEnd = Offset(x, axisBounds.bottom);
        break;
      case AxisOrientation.bottom:
        final x = tickLocation;
        tickStart = Offset(x, axisBounds.top);
        tickEnd = Offset(x, axisBounds.top + tickLength);
        break;
      case AxisOrientation.right:
        final y = tickLocation;
        tickStart = Offset(axisBounds.left, y);
        tickEnd = Offset(axisBounds.left + tickLength, y);
        break;
      case AxisOrientation.left:
        final y = tickLocation;
        tickStart = Offset(axisBounds.right - tickLength, y);
        tickEnd = Offset(axisBounds.right, y);
        break;
    }
    return [tickStart, tickEnd];
  }
}
