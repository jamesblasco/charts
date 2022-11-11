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

import 'dart:math' show cos, pi, sin, Point;
import 'package:flutter/material.dart';

/// Draws a sector of a circle, with an optional hole in the center.
class CircleSectorPainter {
  /// Draws a sector of a circle, with an optional hole in the center.
  ///
  /// [center] The x, y coordinates of the circle's center.
  /// [radius] The radius of the circle.
  /// [innerRadius] Optional radius of a hole in the center of the circle that
  ///     should not be filled in as part of the sector.
  /// [startAngle] The angle at which the arc starts, measured clockwise from
  ///     the positive x axis and expressed in radians.
  /// [endAngle] The angle at which the arc ends, measured clockwise from the
  ///     positive x axis and expressed in radians.
  /// [fill] Fill color for the sector.
  /// [stroke] Stroke color of the arc and radius lines.
  /// [strokeWidth] Stroke width of the arc and radius lines.
  static void draw({
    required Canvas canvas,
    required Paint paint,
    required Offset center,
    required double radius,
    required double innerRadius,
    required double startAngle,
    required double endAngle,
    Color? fill,
  }) {
    paint.color = fill!;
    paint.style = PaintingStyle.fill;

    final innerRadiusStartPoint = Offset(
      innerRadius * cos(startAngle) + center.dx,
      innerRadius * sin(startAngle) + center.dy,
    );

    final innerRadiusEndPoint = Offset(
      innerRadius * cos(endAngle) + center.dx,
      innerRadius * sin(endAngle) + center.dy,
    );

    final radiusStartPoint = Offset(
      radius * cos(startAngle) + center.dx,
      radius * sin(startAngle) + center.dy,
    );

    final centerOffset = Offset(center.dx.toDouble(), center.dy.toDouble());

    final isFullCircle = endAngle - startAngle == 2 * pi;

    final midpointAngle = (endAngle + startAngle) / 2;

    final path = Path()
      ..moveTo(innerRadiusStartPoint.dx, innerRadiusStartPoint.dy);

    path.lineTo(radiusStartPoint.dx, radiusStartPoint.dy);

    // For full circles, draw the arc in two parts.
    if (isFullCircle) {
      path.arcTo(
        Rect.fromCircle(center: centerOffset, radius: radius),
        startAngle,
        midpointAngle - startAngle,
        true,
      );
      path.arcTo(
        Rect.fromCircle(center: centerOffset, radius: radius),
        midpointAngle,
        endAngle - midpointAngle,
        true,
      );
    } else {
      path.arcTo(
        Rect.fromCircle(center: centerOffset, radius: radius),
        startAngle,
        endAngle - startAngle,
        true,
      );
    }

    path.lineTo(innerRadiusEndPoint.dx, innerRadiusEndPoint.dy);

    // For full circles, draw the arc in two parts.
    if (isFullCircle) {
      path.arcTo(
        Rect.fromCircle(center: centerOffset, radius: innerRadius),
        endAngle,
        midpointAngle - endAngle,
        true,
      );
      path.arcTo(
        Rect.fromCircle(center: centerOffset, radius: innerRadius),
        midpointAngle,
        startAngle - midpointAngle,
        true,
      );
    } else {
      path.arcTo(
        Rect.fromCircle(center: centerOffset, radius: innerRadius),
        endAngle,
        startAngle - endAngle,
        true,
      );
    }

    // Drawing two copies of this line segment, before and after the arcs,
    // ensures that the path actually gets closed correctly.
    path.lineTo(radiusStartPoint.dx, radiusStartPoint.dy);

    canvas.drawPath(path, paint);
  }
}
