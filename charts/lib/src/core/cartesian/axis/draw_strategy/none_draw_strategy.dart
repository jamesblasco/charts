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

/// Renders no ticks no labels, and claims no space in layout.
/// However, it does render the axis line if asked to by the axis.
@immutable
class NoneRenderSpec<D> extends RenderSpec<D> {

  const NoneRenderSpec({this.axisLineStyle});
  final LineStyleSpec? axisLineStyle;

  @override
  TickDrawStrategy<D> createDrawStrategy(
          ChartContext context, GraphicsFactory graphicFactory,) =>
      NoneDrawStrategy<D>( graphicFactory,
          axisLineStyleSpec: axisLineStyle,);
  @override
  List<Object?> get props => [];
}

class NoneDrawStrategy<D> implements TickDrawStrategy<D> {

  NoneDrawStrategy(
    GraphicsFactory graphicsFactory, {
    LineStyleSpec? axisLineStyleSpec,
  })  : axisLineStyle = StyleFactory.style
            .createAxisLineStyle(graphicsFactory, axisLineStyleSpec),
        noneTextStyle = graphicsFactory.createTextPaint()
          ..color = Colors.transparent
          ..fontSize = 0;
  LineStyle axisLineStyle;
  TextPaintStyle noneTextStyle;

  @override
  void updateTickWidth(List<Tick<D>> ticks, int maxWidth, int maxHeight,
      AxisOrientation orientation,
      {bool collision = false,}) {}

  @override
  CollisionReport<D> collides(
          List<Tick<D>>? ticks, AxisOrientation? orientation,) =>
      CollisionReport(ticksCollide: false, ticks: ticks);

  @override
  void decorateTicks(List<Tick<D>> ticks) {
    // Even though no text is rendered, the text style for each element should
    // still be set to handle the case of the draw strategy being switched to
    // a different draw strategy. The new draw strategy will try to animate
    // the old ticks out and the text style property is used.
    for (final tick in ticks) {
      tick.textElement!.textStyle = noneTextStyle;
    }
  }

  @override
  void drawAxisLine(ChartCanvas canvas, AxisOrientation orientation,
      Rectangle<int> axisBounds,) {
    Point<num> start;
    Point<num> end;

    switch (orientation) {
      case AxisOrientation.top:
        start = axisBounds.bottomLeft;
        end = axisBounds.bottomRight;

        break;
      case AxisOrientation.bottom:
        start = axisBounds.topLeft;
        end = axisBounds.topRight;
        break;
      case AxisOrientation.right:
        start = axisBounds.topLeft;
        end = axisBounds.bottomLeft;
        break;
      case AxisOrientation.left:
        start = axisBounds.topRight;
        end = axisBounds.bottomRight;
        break;
    }

    canvas.drawLine(
      points: [start, end],
      dashPattern: axisLineStyle.dashPattern,
      fill: axisLineStyle.color,
      stroke: axisLineStyle.color,
      strokeWidthPx: axisLineStyle.strokeWidth.toDouble(),
    );
  }

  @override
  void draw(ChartCanvas canvas, Tick<D> tick,
      {required AxisOrientation orientation,
      required Rectangle<int> axisBounds,
      required Rectangle<int> drawAreaBounds,
      required bool isFirst,
      required bool isLast,
      bool collision = false,}) {}

  @override
  ViewMeasuredSizes measureHorizontallyDrawnTicks(
      List<Tick<D>> ticks, int maxWidth, int maxHeight,
      {bool collision = false,}) {
    return const ViewMeasuredSizes(preferredWidth: 0, preferredHeight: 0);
  }

  @override
  ViewMeasuredSizes measureVerticallyDrawnTicks(
      List<Tick<D>> ticks, int maxWidth, int maxHeight,
      {bool collision = false,}) {
    return const ViewMeasuredSizes(preferredWidth: 0, preferredHeight: 0);
  }
}
