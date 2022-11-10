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
class SmallTickRendererSpec<D> extends BaseRenderSpec<D> {

  const SmallTickRendererSpec({
    super.labelStyle,
    this.lineStyle,
    super.axisLineStyle,
    super.labelAnchor,
    super.labelJustification,
    super.labelOffsetFromAxisPx,
    super.labelCollisionOffsetFromAxisPx,
    super.labelOffsetFromTickPx,
    super.labelCollisionOffsetFromTickPx,
    this.tickLengthPx,
    super.minimumPaddingBetweenLabelsPx,
    super.labelRotation,
    super.labelCollisionRotation,
  });
  final LineStyleSpec? lineStyle;
  final int? tickLengthPx;

  @override
  TickDrawStrategy<D> createDrawStrategy(
          ChartContext context, GraphicsFactory graphicsFactory,) =>
      SmallTickDrawStrategy<D>(
        context,
        graphicsFactory,
        tickLengthPx: tickLengthPx,
        lineStyleSpec: lineStyle,
        labelStyleSpec: labelStyle,
        axisLineStyleSpec: axisLineStyle,
        labelAnchor: labelAnchor,
        labelJustification: labelJustification,
        labelOffsetFromAxisPx: labelOffsetFromAxisPx,
        labelCollisionOffsetFromAxisPx: labelCollisionOffsetFromAxisPx,
        labelOffsetFromTickPx: labelOffsetFromTickPx,
        labelCollisionOffsetFromTickPx: labelCollisionOffsetFromTickPx,
        minimumPaddingBetweenLabelsPx: minimumPaddingBetweenLabelsPx,
        labelRotation: labelRotation,
        labelCollisionRotation: labelCollisionRotation,
      );

  @override
  List<Object?> get props => [lineStyle, tickLengthPx, super.props];
}

/// Draws small tick lines for each tick. Extends [BaseTickDrawStrategy].
class SmallTickDrawStrategy<D> extends BaseTickDrawStrategy<D> {

  SmallTickDrawStrategy(
      super.chartContext, super.graphicsFactory,
      {int? tickLengthPx,
      LineStyleSpec? lineStyleSpec,
      super.labelStyleSpec,
      LineStyleSpec? axisLineStyleSpec,
      super.labelAnchor,
      super.labelJustification,
      super.labelOffsetFromAxisPx,
      super.labelCollisionOffsetFromAxisPx,
      super.labelOffsetFromTickPx,
      super.labelCollisionOffsetFromTickPx,
      super.minimumPaddingBetweenLabelsPx,
      super.labelRotation,
      super.labelCollisionRotation,})
      : tickLength = tickLengthPx ?? StyleFactory.style.tickLength,
        lineStyle = StyleFactory.style
            .createTickLineStyle(graphicsFactory, lineStyleSpec),
        super(
          axisLineStyleSpec: axisLineStyleSpec ?? lineStyleSpec,
        );
  int tickLength;
  LineStyle lineStyle;

  @override
  void draw(ChartCanvas canvas, Tick<D> tick,
      {required AxisOrientation orientation,
      required Rectangle<int> axisBounds,
      required Rectangle<int> drawAreaBounds,
      required bool isFirst,
      required bool isLast,
      bool collision = false,}) {
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
      strokeWidthPx: lineStyle.strokeWidth.toDouble(),
    );

    drawLabel(canvas, tick,
        orientation: orientation,
        axisBounds: axisBounds,
        drawAreaBounds: drawAreaBounds,
        isFirst: isFirst,
        isLast: isLast,
        collision: collision,);
  }

  List<Point<num>> calculateTickPositions(
    Tick<D> tick,
    AxisOrientation orientation,
    Rectangle<int> axisBounds,
    Rectangle<int> drawAreaBounds,
    int tickLength,
  ) {
    Point<num> tickStart;
    Point<num> tickEnd;
    final tickLocationPx = tick.locationPx!;
    switch (orientation) {
      case AxisOrientation.top:
        final x = tickLocationPx;
        tickStart = Point(x, axisBounds.bottom - tickLength);
        tickEnd = Point(x, axisBounds.bottom);
        break;
      case AxisOrientation.bottom:
        final x = tickLocationPx;
        tickStart = Point(x, axisBounds.top);
        tickEnd = Point(x, axisBounds.top + tickLength);
        break;
      case AxisOrientation.right:
        final y = tickLocationPx;
        tickStart = Point(axisBounds.left, y);
        tickEnd = Point(axisBounds.left + tickLength, y);
        break;
      case AxisOrientation.left:
        final y = tickLocationPx;
        tickStart = Point(axisBounds.right - tickLength, y);
        tickEnd = Point(axisBounds.right, y);
        break;
    }
    return [tickStart, tickEnd];
  }
}
