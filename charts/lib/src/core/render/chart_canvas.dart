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


import 'package:charts/core.dart';

abstract class ChartCanvas {
  /// Set the name of the view doing the rendering for debugging purposes,
  /// or null when we believe rendering is complete.
  set drawingView(String? viewName);

  /// Renders a sector of a circle, with an optional hole in the center.
  ///
  /// [center] The x, y coordinates of the circle's center.
  /// [radius] The radius of the circle.
  /// [innerRadius] Optional radius of a hole in the center of the circle that
  ///     should not be filled in as part of the sector.
  /// [startAngle] The angle at which the arc starts, measured clockwise from
  ///     the positive x axis and expressed in radians
  /// [endAngle] The angle at which the arc ends, measured clockwise from the
  ///     positive x axis and expressed in radians.
  /// [fill] Fill color for the sector.
  /// [stroke] Stroke color of the arc and radius lines.
  /// [strokeWidth] Stroke width of the arc and radius lines.
  void drawCircleSector(
    Offset center,
    double radius,
    double innerRadius,
    double startAngle,
    double endAngle, {
    Color? fill,
    Color? stroke,
    double? strokeWidth,
  });

  /// Draws a smooth link from source to target.
  ///
  /// [sourceUpper] The location of the upper link at the source node.
  /// [sourceLower] The location of the lower link at the source node.
  /// [targetUpper] The location of the upper link at the target node.
  /// [targetLower] The location of the lower link at the target node.
  /// [fill] The fill color for the link.
  /// [orientation] Orientation enum of the link, vertical or horizontal.
  void drawLink(Link link, LinkOrientation orientation, Color fill);

  /// Renders a simple line.
  ///
  /// [dashPattern] controls the pattern of dashes and gaps in a line. It is a
  /// list of lengths of alternating dashes and gaps. The rendering is similar
  /// to stroke-dasharray in SVG path elements. An odd number of values in the
  /// pattern will be repeated to derive an even number of values. "1,2,3" is
  /// equivalent to "1,2,3,1,2,3."
  void drawLine({
    required List<Offset> points,
    Rect? clipBounds,
    Color? fill,
    Color? stroke,
    bool? roundEndCaps,
    double? strokeWidth,
    List<int>? dashPattern,
  });

  /// Renders a pie, with an optional hole in the center.
  void drawPie(CanvasPie canvasPie);

  /// Renders a simple point.
  ///
  /// [point] The x, y coordinates of the point.
  ///
  /// [radius] The radius of the point.
  ///
  /// [fill] Fill color for the point.
  ///
  /// [stroke] and [strokeWidth] configure the color and thickness of the
  /// outer edge of the point. Both must be provided together for a line to
  /// appear.
  ///
  /// [blendMode] Blend mode to be used when drawing this point on canvas.
  void drawPoint({
    required Offset point,
    required double radius,
    Color? fill,
    Color? stroke,
    double? strokeWidth,
    BlendMode? blendMode,
  });

  /// Renders a polygon shape described by a set of points.
  ///
  /// [points] describes the vertices of the polygon. The last point will always
  /// be connected to the first point to close the shape.
  ///
  /// [fill] configures the color inside the polygon. The shape will be
  /// transparent if this is not provided.
  ///
  /// [stroke] and [strokeWidth] configure the color and thickness of the
  /// edges of the polygon. Both must be provided together for a line to appear.
  void drawPolygon({
    required List<Offset> points,
    Rect? clipBounds,
    Color? fill,
    Color? stroke,
    double? strokeWidth,
  });

  /// Renders a simple rectangle.
  ///
  /// [drawAreaBounds] if specified and if the bounds of the rectangle exceed
  /// the draw area bounds on the top, the first x pixels (decided by the native
  /// platform) exceeding the draw area will apply a gradient to transparent
  /// with anything exceeding the x pixels to be transparent.
  void drawRect(
    Rect bounds, {
    Color? fill,
    Color? stroke,
    double? strokeWidth,
    Rect? drawAreaBounds,
  });

  /// Renders a rounded rectangle.
  void drawRRect(
    Rect bounds, {
    Color? fill,
    Color? stroke,
    Color? patternColor,
    FillPatternType? fillPattern,
    double? patternStrokeWidth,
    double? strokeWidth,
    num? radius,
    bool roundTopLeft = false,
    bool roundTopRight = false,
    bool roundBottomLeft = false,
    bool roundBottomRight = false,
  });

  /// Renders a stack of bars, rounding the last bar in the stack.
  ///
  /// The first bar of the stack is expected to be the "base" bar. This would
  /// be the bottom most bar for a vertically rendered bar.
  ///
  /// [drawAreaBounds] if specified and if the bounds of the rectangle exceed
  /// the draw area bounds on the top, the first x pixels (decided by the native
  /// platform) exceeding the draw area will apply a gradient to transparent
  /// with anything exceeding the x pixels to be transparent.
  void drawBarStack(
    CanvasBarStack canvasBarStack, {
    Rect? drawAreaBounds,
  });

  void drawText(
    TextElement textElement,
    double offsetX,
    double offsetY, {
    double rotation = 0.0,
  });

  /// Request the canvas to clip to [clipBounds].
  ///
  /// Applies to all operations until [restClipBounds] is called.
  void setClipBounds(Rect clipBounds);

  /// Restore
  void resetClipBounds();
}

Color getAnimatedColor(Color previous, Color target, double animationPercent) {
  final r =
      (((target.red - previous.red) * animationPercent) + previous.red).round();
  final g =
      (((target.green - previous.green) * animationPercent) + previous.green)
          .round();
  final b = (((target.blue - previous.blue) * animationPercent) + previous.blue)
      .round();
  final a =
      (((target.alpha - previous.alpha) * animationPercent) + previous.alpha)
          .round();

  return Color.fromARGB(a, r, g, b);
}

/// Defines the pattern for a color fill.
///
/// * [forwardHatch] defines a pattern of white lines angled up and to the right
///   on top of a bar filled with the fill color.
/// * [solid] defines a simple bar filled with the fill color. This is the
///   default pattern for bars.
enum FillPatternType { forwardHatch, solid }

/// Defines the blend modes to use for drawing on canvas.
enum BlendMode {
  color,
  colorBurn,
  colorDodge,
  darken,
  defaultMode,
  difference,
  exclusion,
  hardLight,
  hue,
  lighten,
  luminosity,
  multiply,
  overlay,
  saturation,
  screen,
  softLight,
  copy,
  destinationAtop,
  destinationIn,
  destinationOut,
  destinationOver,
  lighter,
  sourceAtop,
  sourceIn,
  sourceOut,
  sourceOver,
  xor
}

/// Determines the orientation of a drawn link.
///
/// * [horizontal] Link control points are averaged across the x-axis.
/// * [vertical] Link control points are averaged across the y-axis.
enum LinkOrientation { horizontal, vertical }

/// A link as defined by the two sets of points that determine the bezier
/// curves of the link.
///
/// [sourceUpper] The location of the upper link at the source node.
/// [sourceLower] The location of the lower link at the source node.
/// [targetUpper] The location of the upper link at the target node.
/// [targetLower] The location of the lower link at the target node.
class Link {
  Link(this.sourceUpper, this.sourceLower, this.targetUpper, this.targetLower);
  final Offset sourceUpper;
  final Offset sourceLower;
  final Offset targetUpper;
  final Offset targetLower;
}
