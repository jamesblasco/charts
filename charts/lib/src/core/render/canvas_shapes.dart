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

import 'dart:math' show min, max, Point;

import 'package:charts/core.dart';

/// A rectangle to be painted by [ChartCanvas].
class CanvasRect {
  CanvasRect(
    this.bounds, {
    this.dashPattern,
    this.fill,
    this.pattern,
    this.stroke,
    this.strokeWidth,
  });
  final Rect bounds;
  final List<int>? dashPattern;
  final Color? fill;
  final FillPatternType? pattern;
  final Color? stroke;
  final double? strokeWidth;
}

/// A stack of [CanvasRect] to be painted by [ChartCanvas].
class CanvasBarStack {
  factory CanvasBarStack(
    List<CanvasRect> segments, {
    double? radius,
    double stackedBarPadding = 1,
    bool roundTopLeft = false,
    bool roundTopRight = false,
    bool roundBottomLeft = false,
    bool roundBottomRight = false,
  }) {
    final firstBarBounds = segments.first.bounds;

    // Find the rectangle that would represent the full stack of bars.
    var left = firstBarBounds.left;
    var top = firstBarBounds.top;
    var right = firstBarBounds.right;
    var bottom = firstBarBounds.bottom;

    for (var barIndex = 1; barIndex < segments.length; barIndex++) {
      final bounds = segments[barIndex].bounds;

      left = min(left, bounds.left);
      top = min(top, bounds.top);
      right = max(right, bounds.right);
      bottom = max(bottom, bounds.bottom);
    }

    final width = right - left;
    final height = bottom - top;
    final fullStackRect = Rect.fromLTWH(left, top, width, height);

    return CanvasBarStack._internal(
      segments,
      radius: radius,
      stackedBarPadding: stackedBarPadding,
      roundTopLeft: roundTopLeft,
      roundTopRight: roundTopRight,
      roundBottomLeft: roundBottomLeft,
      roundBottomRight: roundBottomRight,
      fullStackRect: fullStackRect,
    );
  }

  CanvasBarStack._internal(
    this.segments, {
    required this.radius,
    required this.stackedBarPadding,
    required this.roundTopLeft,
    required this.roundTopRight,
    required this.roundBottomLeft,
    required this.roundBottomRight,
    required this.fullStackRect,
  });
  final List<CanvasRect> segments;
  final double? radius;
  final double stackedBarPadding;
  final bool roundTopLeft;
  final bool roundTopRight;
  final bool roundBottomLeft;
  final bool roundBottomRight;
  final Rect fullStackRect;
}

/// A list of [CanvasPieSlice]s to be painted by [ChartCanvas].
class CanvasPie {
  CanvasPie(
    this.slices,
    this.center,
    this.radius,
    this.innerRadius, {
    this.stroke,
    this.strokeWidth = 0.0,
  });
  final List<CanvasPieSlice> slices;
  Offset center;
  double radius;
  double innerRadius;

  /// Color of separator lines between arcs.
  final Color? stroke;

  /// Stroke width of separator lines between arcs.
  double strokeWidth;
}

/// A circle sector to be painted by [ChartCanvas].
class CanvasPieSlice {
  CanvasPieSlice(this.startAngle, this.endAngle, {this.fill});
  double startAngle;
  double endAngle;
  Color? fill;
}
