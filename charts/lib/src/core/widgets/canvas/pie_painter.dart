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

import 'dart:math' show cos, sin, Point;

import 'package:charts/core.dart';
import 'package:flutter/material.dart';

/// Draws a pie chart, with an optional hole in the center.
class PiePainter {
  /// Draws a pie chart, with an optional hole in the center.
  static void draw(Canvas canvas, Paint paint, CanvasPie canvasPie) {
    final center = canvasPie.center;
    final radius = canvasPie.radius;
    final innerRadius = canvasPie.innerRadius;

    for (final slice in canvasPie.slices) {
      CircleSectorPainter.draw(
        canvas: canvas,
        paint: paint,
        center: center,
        radius: radius,
        innerRadius: innerRadius,
        startAngle: slice.startAngle,
        endAngle: slice.endAngle,
        fill: slice.fill,
      );
    }

    // Draw stroke lines between pie slices. This is done after the slices are
    // drawn to ensure that they appear on top.
    if (canvasPie.stroke != null && canvasPie.slices.length > 1) {
      paint.color = canvasPie.stroke!;

      paint.strokeWidth = canvasPie.strokeWidth;
      paint.strokeJoin = StrokeJoin.bevel;
      paint.style = PaintingStyle.stroke;

      final path = Path();

      for (final slice in canvasPie.slices) {
        final innerRadiusStartPoint = Offset(
          innerRadius * cos(slice.startAngle) + center.dx,
          innerRadius * sin(slice.startAngle) + center.dy,
        );

        final innerRadiusEndPoint = Offset(
          innerRadius * cos(slice.endAngle) + center.dx,
          innerRadius * sin(slice.endAngle) + center.dy,
        );

        final radiusStartPoint = Offset(
          radius * cos(slice.startAngle) + center.dx,
          radius * sin(slice.startAngle) + center.dy,
        );

        final radiusEndPoint = Offset(
          radius * cos(slice.endAngle) + center.dx,
          radius * sin(slice.endAngle) + center.dy,
        );

        path.moveTo(innerRadiusStartPoint.dx, innerRadiusStartPoint.dy);

        path.lineTo(radiusStartPoint.dx, radiusStartPoint.dy);

        path.moveTo(innerRadiusEndPoint.dx, innerRadiusEndPoint.dy);

        path.lineTo(radiusEndPoint.dx, radiusEndPoint.dy);
      }

      canvas.drawPath(path, paint);
    }
  }
}
