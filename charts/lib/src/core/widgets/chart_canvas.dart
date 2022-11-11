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

import 'dart:math' show Point, Rectangle, max;
import 'dart:ui' as ui show Gradient, Shader;

import 'package:charts/core.dart' hide GraphLink;
import 'package:charts/src/core/render/chart_canvas.dart';
import 'package:flutter/material.dart';

class FlutterChartCanvas implements ChartCanvas {
  FlutterChartCanvas(this.canvas);

  /// Pixels to allow to overdraw above the draw area that fades to transparent.
  static const double rectTopGradientPixels = 5;

  final Canvas canvas;

  final _paint = Paint();

  @override
  void drawCircleSector(
    Offset center,
    double radius,
    double innerRadius,
    double startAngle,
    double endAngle, {
    Color? fill,
    Color? stroke,
    double? strokeWidth,
  }) {
    CircleSectorPainter.draw(
      canvas: canvas,
      paint: _paint,
      center: center,
      radius: radius,
      innerRadius: innerRadius,
      startAngle: startAngle,
      endAngle: endAngle,
      fill: fill,
    );
  }

  @override
  void drawLine({
    required List<Offset> points,
    Rect? clipBounds,
    Color? fill,
    Color? stroke,
    bool? roundEndCaps,
    double? strokeWidth,
    List<int>? dashPattern,
  }) {
    LinePainter.draw(
      canvas: canvas,
      paint: _paint,
      points: points,
      clipBounds: clipBounds,
      fill: fill,
      stroke: stroke,
      roundEndCaps: roundEndCaps,
      strokeWidth: strokeWidth,
      dashPattern: dashPattern,
    );
  }

  @override
  void drawPie(CanvasPie canvasPie) {
    PiePainter.draw(canvas, _paint, canvasPie);
  }

  @override
  void drawPoint({
    required Offset point,
    required double radius,
    Color? fill,
    Color? stroke,
    double? strokeWidth,
    BlendMode? blendMode,
  }) {
    PointPainter.draw(
      canvas: canvas,
      paint: _paint,
      point: point,
      radius: radius,
      fill: fill,
      stroke: stroke,
      strokeWidth: strokeWidth,
    );
  }

  @override
  void drawPolygon({
    required List<Offset> points,
    Rect? clipBounds,
    Color? fill,
    Color? stroke,
    double? strokeWidth,
  }) {
    PolygonPainter.draw(
      canvas: canvas,
      paint: _paint,
      points: points,
      clipBounds: clipBounds,
      fill: fill,
      stroke: stroke,
      strokeWidth: strokeWidth,
    );
  }

  /// Creates a bottom to top gradient that transitions [fill] to transparent.
  ui.Gradient _createHintGradient(double left, double top, Color fill) {
    return ui.Gradient.linear(
      Offset(left, top),
      Offset(left, top - rectTopGradientPixels),
      [fill, fill.withOpacity(0)],
    );
  }

  @override
  void drawRect(
    Rect bounds, {
    Color? fill,
    FillPatternType? pattern,
    Color? stroke,
    double? strokeWidth,
    Rect? drawAreaBounds,
  }) {
    // TODO: remove this explicit `bool` type when no longer needed
    // to work around https://github.com/dart-lang/language/issues/1785
    final drawStroke =
        strokeWidth != null && strokeWidth > 0.0 && stroke != null;

    final strokeWidthOffset = drawStroke ? strokeWidth : 0;

    // Factor out stroke width, if a stroke is enabled.
    final fillRectBounds = Rect.fromLTWH(
      bounds.left + strokeWidthOffset / 2,
      bounds.top + strokeWidthOffset / 2,
      bounds.width - strokeWidthOffset,
      bounds.height - strokeWidthOffset,
    );

    switch (pattern) {
      case FillPatternType.forwardHatch:
        _drawForwardHatchPattern(
          fillRectBounds,
          canvas,
          fill: fill,
          drawAreaBounds: drawAreaBounds,
        );
        break;

      case FillPatternType.solid:
      case null:
        // Use separate rect for drawing stroke
        _paint.color = fill!;
        _paint.style = PaintingStyle.fill;

        // Apply a gradient to the top [rect_top_gradient_pixels] to transparent
        // if the rectangle is higher than the [drawAreaBounds] top.
        if (drawAreaBounds != null && bounds.top < drawAreaBounds.top) {
          _paint.shader = _createHintGradient(
            drawAreaBounds.left.toDouble(),
            drawAreaBounds.top.toDouble(),
            fill,
          );
        }

        canvas.drawRect(_getRect(fillRectBounds), _paint);
        break;
    }

    // [Canvas.drawRect] does not support drawing a rectangle with both a fill
    // and a stroke at this time. Use a separate rect for the stroke.
    if (drawStroke) {
      _paint
        ..color = stroke
        // Set shader to null if no draw area bounds so it can use the color
        // instead.
        ..shader = drawAreaBounds != null
            ? _createHintGradient(
                drawAreaBounds.left.toDouble(),
                drawAreaBounds.top.toDouble(),
                stroke,
              )
            : null
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;

      canvas.drawRect(_getRect(bounds), _paint);
    }

    // Reset the shader.
    _paint.shader = null;
  }

  @override
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
  }) {
    // Use separate rect for drawing stroke
    _paint
      ..color = fill!
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      _getRRect(
        bounds,
        radius: radius?.toDouble() ?? 0.0,
        roundTopLeft: roundTopLeft,
        roundTopRight: roundTopRight,
        roundBottomLeft: roundBottomLeft,
        roundBottomRight: roundBottomRight,
      ),
      _paint,
    );
  }

  @override
  void drawBarStack(CanvasBarStack barStack, {Rect? drawAreaBounds}) {
    // only clip if rounded rect.

    // Clip a rounded rect for the whole region if rounded bars.
    final roundedCorners = barStack.radius != null && 0 < barStack.radius!;

    if (roundedCorners) {
      canvas
        ..save()
        ..clipRRect(
          _getRRect(
            barStack.fullStackRect,
            radius: barStack.radius!.toDouble(),
            roundTopLeft: barStack.roundTopLeft,
            roundTopRight: barStack.roundTopRight,
            roundBottomLeft: barStack.roundBottomLeft,
            roundBottomRight: barStack.roundBottomRight,
          ),
        );
    }

    // Draw each bar.
    for (var barIndex = 0; barIndex < barStack.segments.length; barIndex++) {
      // TODO: Add configuration for hiding stack line.
      // TODO: Don't draw stroke on bottom of bars.
      final segment = barStack.segments[barIndex];
      drawRect(
        segment.bounds,
        fill: segment.fill,
        pattern: segment.pattern,
        stroke: segment.stroke,
        strokeWidth: segment.strokeWidth,
        drawAreaBounds: drawAreaBounds,
      );
    }

    if (roundedCorners) {
      canvas.restore();
    }
  }

  @override
  void drawText(
    TextElement textElement,
    double offsetX,
    double offsetY, {
    double rotation = 0.0,
  }) {
    // Must be Flutter TextElement.
    assert(textElement is FlutterTextElement);

    final flutterTextElement = textElement as FlutterTextElement;
    final textDirection = flutterTextElement.textDirection;
    final measurement = flutterTextElement.measurement;

    if (rotation != 0) {
      // TODO: Remove once textAnchor works.
      if (textDirection == TextDirectionAligment.rtl) {
        offsetY += measurement.horizontalSliceWidth.toInt();
      }

      offsetX -= flutterTextElement.verticalFontShift;

      canvas.save();
      canvas.translate(offsetX.toDouble(), offsetY.toDouble());
      canvas.rotate(rotation);

      textElement.textPainter!.paint(canvas, Offset.zero);

      canvas.restore();
    } else {
      // TODO: Remove once textAnchor works.
      if (textDirection == TextDirectionAligment.rtl) {
        offsetX -= measurement.horizontalSliceWidth.toInt();
      }

      // Account for missing center alignment.
      if (textDirection == TextDirectionAligment.center) {
        offsetX -= (measurement.horizontalSliceWidth / 2).ceil();
      }

      offsetY -= flutterTextElement.verticalFontShift;

      textElement.textPainter!
          .paint(canvas, Offset(offsetX.toDouble(), offsetY.toDouble()));
    }
  }

  @override
  void setClipBounds(Rect clipBounds) {
    canvas
      ..save()
      ..clipRect(_getRect(clipBounds));
  }

  @override
  void resetClipBounds() {
    canvas.restore();
  }

  /// Convert dart:math [Rectangle] to Flutter [Rect].
  Rect _getRect(Rect rectangle) {
    return Rect.fromLTWH(
      rectangle.left.toDouble(),
      rectangle.top.toDouble(),
      rectangle.width.toDouble(),
      rectangle.height.toDouble(),
    );
  }

  /// Convert dart:math [Rectangle] and to Flutter [RRect].
  RRect _getRRect(
    Rect rectangle, {
    double radius = 0,
    bool roundTopLeft = false,
    bool roundTopRight = false,
    bool roundBottomLeft = false,
    bool roundBottomRight = false,
  }) {
    final cornerRadius = radius == 0 ? Radius.zero : Radius.circular(radius);

    return RRect.fromLTRBAndCorners(
      rectangle.left.toDouble(),
      rectangle.top.toDouble(),
      rectangle.right.toDouble(),
      rectangle.bottom.toDouble(),
      topLeft: roundTopLeft ? cornerRadius : Radius.zero,
      topRight: roundTopRight ? cornerRadius : Radius.zero,
      bottomLeft: roundBottomLeft ? cornerRadius : Radius.zero,
      bottomRight: roundBottomRight ? cornerRadius : Radius.zero,
    );
  }

  /// Draws a forward hatch pattern in the given bounds.
  _drawForwardHatchPattern(
    Rect bounds,
    Canvas canvas, {
    Color? background,
    Color? fill,
    double fillWidth = 4.0,
    Rect? drawAreaBounds,
  }) {
    background ??= StyleFactory.style.white;
    fill ??= StyleFactory.style.black;

    // Fill in the shape with a solid background color.
    _paint.color = background;
    _paint.style = PaintingStyle.fill;

    // Apply a gradient the background if bounds exceed the draw area.
    if (drawAreaBounds != null && bounds.top < drawAreaBounds.top) {
      _paint.shader = _createHintGradient(
        drawAreaBounds.left.toDouble(),
        drawAreaBounds.top.toDouble(),
        background,
      );
    }

    canvas.drawRect(_getRect(bounds), _paint);

    // As a simplification, we will treat the bounds as a large square and fill
    // it up with lines from the bottom-left corner to the top-right corner.
    // Get the longer side of the bounds here for the size of this square.
    final size = max(bounds.width, bounds.height);

    final x0 = bounds.left + size + fillWidth;
    final x1 = bounds.left - fillWidth;
    final y0 = bounds.bottom - size - fillWidth;
    final y1 = bounds.bottom + fillWidth;
    const offset = 8;

    final isVertical = bounds.height >= bounds.width;

    // The "first" line segment will be drawn from the bottom left corner of the
    // bounds, up and towards the right. Start the loop N iterations "back" to
    // draw partial line segments beneath (or to the left) of this segment,
    // where N is the number of offsets that fit inside the smaller dimension of
    // the bounds.
    final smallSide = isVertical ? bounds.width : bounds.height;
    final start = -(smallSide / offset).round() * offset;

    // Keep going until we reach the top or right of the bounds, depending on
    // whether the rectangle is oriented vertically or horizontally.
    final end = size + offset;

    // Create gradient for line painter if top bounds exceeded.
    ui.Shader? lineShader;
    if (drawAreaBounds != null && bounds.top < drawAreaBounds.top) {
      lineShader = _createHintGradient(
        drawAreaBounds.left.toDouble(),
        drawAreaBounds.top.toDouble(),
        fill,
      );
    }

    for (var i = start; i < end; i = i + offset) {
      // For vertical bounds, we need to draw lines from top to bottom. For
      // bounds, we need to draw lines from left to right.
      final modifier = isVertical ? -1 * i : i;

      // Draw a line segment in the bottom right corner of the pattern.
      LinePainter.draw(
        canvas: canvas,
        paint: _paint,
        points: [
          Offset(x0 + modifier, y0),
          Offset(x1 + modifier, y1),
        ],
        stroke: fill,
        strokeWidth: fillWidth,
        shader: lineShader,
      );
    }
  }

  @override
  set drawingView(String? viewName) {}

  @override
  void drawLink(Link link, LinkOrientation orientation, Color fill) {
    // TODO: implement drawLink
  }
}
