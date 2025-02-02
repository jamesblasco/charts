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

import 'package:flutter/material.dart';

/// Draws a simple point.
///
/// TODO: Support for more shapes than circles?
class PointPainter {
  static void draw({
    required Canvas canvas,
    required Paint paint,
    required Offset point,
    required double radius,
    Color? fill,
    Color? stroke,
    double? strokeWidth,
  }) {
    if (point == null) {
      return;
    }

    if (fill != null) {
      paint.color = fill;
      paint.style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(point.dx.toDouble(), point.dy.toDouble()),
        radius,
        paint,
      );
    }

    // [Canvas.drawCircle] does not support drawing a circle with both a fill
    // and a stroke at this time. Use a separate circle for the stroke.
    if (stroke != null && strokeWidth != null && strokeWidth > 0.0) {
      paint.color = stroke;
      paint.strokeWidth = strokeWidth;
      paint.strokeJoin = StrokeJoin.bevel;
      paint.style = PaintingStyle.stroke;

      canvas.drawCircle(
        Offset(point.dx.toDouble(), point.dy.toDouble()),
        radius,
        paint,
      );
    }
  }
}
