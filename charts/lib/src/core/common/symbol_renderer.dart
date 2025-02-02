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

import 'dart:math' show Rectangle, Point, min, sqrt;

import 'package:charts/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Strategy for rendering a symbol.
abstract class BaseSymbolRenderer extends Equatable {
  const BaseSymbolRenderer();
  bool shouldRepaint(covariant BaseSymbolRenderer oldRenderer);
}

/// Strategy for rendering a symbol bounded within a box.
abstract class SymbolRenderer extends BaseSymbolRenderer {
  const SymbolRenderer({required this.isSolid});

  /// Whether the symbol should be rendered as a solid shape, or a hollow shape.
  ///
  /// If this is true, then fillColor and strokeColor will be used to fill in
  /// the shape, and draw a border, respectively. The stroke (border) will only
  /// be visible if a non-zero strokeWidth is configured.
  ///
  /// If this is false, then the shape will be filled in with a white color
  /// (overriding fillColor). strokeWidth will default to 2 if none was
  /// configured.
  final bool isSolid;

  void paint(
    ChartCanvas canvas,
    Rect bounds, {
    List<int>? dashPattern,
    Color? fillColor,
    FillPatternType? fillPattern,
    Color? strokeColor,
    double? strokeWidth,
  });

  @protected
  double? getSolidStrokeWidth(double? strokeWidth) {
    return isSolid ? strokeWidth : (strokeWidth ?? 2.0);
  }

  @protected
  Color? getSolidFillColor(Color? fillColor) {
    return isSolid ? fillColor : StyleFactory.style.white;
  }

  @override
  List<Object?> get props => [isSolid];
}

/// Strategy for rendering a symbol centered around a point.
///
/// An optional second point can describe an extended symbol.
abstract class PointSymbolRenderer extends BaseSymbolRenderer {
  void paint(
    ChartCanvas canvas,
    Offset p1,
    double radius, {
    required Offset p2,
    Color? fillColor,
    Color? strokeColor,
  });
}

/// Rounded rectangular symbol with corners having [radius].
class RoundedRectSymbolRenderer extends SymbolRenderer {
  const RoundedRectSymbolRenderer({super.isSolid = true, double? radius})
      : radius = radius ?? 1.0;
  final double radius;

  @override
  void paint(
    ChartCanvas canvas,
    Rect bounds, {
    List<int>? dashPattern,
    Color? fillColor,
    FillPatternType? fillPattern,
    Color? strokeColor,
    double? strokeWidth,
  }) {
    canvas.drawRRect(
      bounds,
      fill: getSolidFillColor(fillColor),
      fillPattern: fillPattern,
      stroke: strokeColor,
      radius: radius,
      roundTopLeft: true,
      roundTopRight: true,
      roundBottomRight: true,
      roundBottomLeft: true,
    );
  }

  @override
  bool shouldRepaint(RoundedRectSymbolRenderer oldRenderer) {
    return this != oldRenderer;
  }

  @override
  List<Object?> get props => [radius, super.props];
}

/// Line symbol renderer.
class LineSymbolRenderer extends SymbolRenderer {
  const LineSymbolRenderer({
    List<int>? dashPattern,
    super.isSolid = true,
    double? strokeWidth,
  })  : strokeWidth = strokeWidth ?? strokeWidthForRoundEndCaps,
        _dashPattern = dashPattern;
  static const roundEndCapsPixels = 2;
  static const minLengthToRoundCaps = (roundEndCapsPixels * 2) + 1;
  static const strokeWidthForRoundEndCaps = 4.0;
  static const strokeWidthForNonRoundedEndCaps = 2.0;

  /// Thickness of the line stroke.
  final double strokeWidth;

  /// Dash pattern for the line.
  final List<int>? _dashPattern;

  @override
  void paint(
    ChartCanvas canvas,
    Rect bounds, {
    List<int>? dashPattern,
    Color? fillColor,
    FillPatternType? fillPattern,
    Color? strokeColor,
    double? strokeWidth,
  }) {
    final centerHeight = (bounds.bottom - bounds.top) / 2;

    // If we have a dash pattern, do not round the end caps, and set
    // strokeWidth to a smaller value. Using round end caps makes smaller
    // patterns blurry.
    final localDashPattern = dashPattern ?? _dashPattern;
    final roundEndCaps = localDashPattern == null;

    // If we have a dash pattern, the normal stroke width makes them look
    // strangely tall.
    final localStrokeWidth = localDashPattern == null
        ? getSolidStrokeWidth(strokeWidth ?? strokeWidth)
        : strokeWidthForNonRoundedEndCaps;

    // Adjust the length so the total width includes the rounded pixels.
    // Otherwise the cap is drawn past the bounds and appears to be cut off.
    // If bounds is not long enough to accommodate the line, do not adjust.
    var left = bounds.left;
    var right = bounds.right;

    if (roundEndCaps && bounds.width >= minLengthToRoundCaps) {
      left += roundEndCapsPixels;
      right -= roundEndCapsPixels;
    }

    // TODO: Pass in strokeWidth, roundEndCaps, and dashPattern from
    // line renderer config.
    canvas.drawLine(
      points: [Offset(left, centerHeight), Offset(right, centerHeight)],
      dashPattern: localDashPattern,
      fill: getSolidFillColor(fillColor),
      roundEndCaps: roundEndCaps,
      stroke: strokeColor,
      strokeWidth: localStrokeWidth,
    );
  }

  @override
  bool shouldRepaint(LineSymbolRenderer oldRenderer) {
    return this != oldRenderer;
  }

  @override
  List<Object?> get props => [super.props, strokeWidth];
}

/// Circle symbol renderer.
class CircleSymbolRenderer extends SymbolRenderer {
  const CircleSymbolRenderer({super.isSolid = true});

  @override
  void paint(
    ChartCanvas canvas,
    Rect bounds, {
    List<int>? dashPattern,
    Color? fillColor,
    FillPatternType? fillPattern,
    Color? strokeColor,
    double? strokeWidth,
  }) {
    final center = Offset(
      bounds.left + (bounds.width / 2),
      bounds.top + (bounds.height / 2),
    );
    final radius = min(bounds.width, bounds.height) / 2;
    canvas.drawPoint(
      point: center,
      radius: radius,
      fill: getSolidFillColor(fillColor),
      stroke: strokeColor,
      strokeWidth: getSolidStrokeWidth(strokeWidth),
    );
  }

  @override
  bool shouldRepaint(CircleSymbolRenderer oldRenderer) {
    return this != oldRenderer;
  }

  @override
  List<Object?> get props => [super.props];
}

/// Rectangle symbol renderer.
class RectSymbolRenderer extends SymbolRenderer {
  const RectSymbolRenderer({super.isSolid = true});

  @override
  void paint(
    ChartCanvas canvas,
    Rect bounds, {
    List<int>? dashPattern,
    Color? fillColor,
    FillPatternType? fillPattern,
    Color? strokeColor,
    double? strokeWidth,
  }) {
    canvas.drawRect(
      bounds,
      fill: getSolidFillColor(fillColor),
      stroke: strokeColor,
      strokeWidth: getSolidStrokeWidth(strokeWidth),
    );
  }

  @override
  bool shouldRepaint(RectSymbolRenderer oldRenderer) {
    return this != oldRenderer;
  }
}

/// This [SymbolRenderer] renders an upward pointing equilateral triangle.
class TriangleSymbolRenderer extends SymbolRenderer {
  const TriangleSymbolRenderer({super.isSolid = true});

  @override
  void paint(
    ChartCanvas canvas,
    Rect bounds, {
    List<int>? dashPattern,
    Color? fillColor,
    FillPatternType? fillPattern,
    Color? strokeColor,
    double? strokeWidth,
  }) {
    // To maximize the size of the triangle in the available space, we can use
    // the width as the length of each size. Set the bottom edge to be the full
    // width, and then calculate the height based on the 30/60/90 degree right
    // triangle whose tall side is the height of our equilateral triangle.
    final dy = sqrt(3) / 2 * bounds.width;
    final centerX = (bounds.left + bounds.right) / 2;
    canvas.drawPolygon(
      points: [
        Offset(bounds.left, bounds.top + dy),
        Offset(bounds.right, bounds.top + dy),
        Offset(centerX, bounds.top),
      ],
      fill: getSolidFillColor(fillColor),
      stroke: strokeColor,
      strokeWidth: getSolidStrokeWidth(strokeWidth),
    );
  }

  @override
  bool shouldRepaint(covariant BaseSymbolRenderer oldRenderer) {
    return this != oldRenderer;
  }
}

/// Draws a cylindrical shape connecting two points.
class CylinderSymbolRenderer extends PointSymbolRenderer {
  CylinderSymbolRenderer();

  @override
  void paint(
    ChartCanvas canvas,
    Offset p1,
    double radius, {
    required Offset p2,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
  }) {
    if (p1 == null) {
      throw ArgumentError('Invalid point p1 "$p1"');
    }

    if (p2 == null) {
      throw ArgumentError('Invalid point p2 "$p2"');
    }

    final adjustedP1 = Offset(p1.dx, p1.dy);
    final adjustedP2 = Offset(p2.dx, p2.dy);

    canvas.drawLine(
      points: [adjustedP1, adjustedP2],
      stroke: strokeColor,
      roundEndCaps: true,
      strokeWidth: radius * 2,
    );
  }

  @override
  bool shouldRepaint(CylinderSymbolRenderer oldRenderer) {
    return this != oldRenderer;
  }

  @override
  List<Object?> get props => [];
}

/// Draws a rectangular shape connecting two points.
class RectangleRangeSymbolRenderer extends PointSymbolRenderer {
  RectangleRangeSymbolRenderer();

  @override
  void paint(
    ChartCanvas canvas,
    Offset p1,
    double radius, {
    required Offset p2,
    Color? fillColor,
    Color? strokeColor,
    double? strokeWidth,
  }) {
    if (p1 == null) {
      throw ArgumentError('Invalid point p1 "$p1"');
    }

    if (p2 == null) {
      throw ArgumentError('Invalid point p2 "$p2"');
    }

    final adjustedP1 = Offset(p1.dx, p1.dy);
    final adjustedP2 = Offset(p2.dx, p2.dy);

    canvas.drawLine(
      points: [adjustedP1, adjustedP2],
      stroke: strokeColor,
      roundEndCaps: false,
      strokeWidth: radius * 2,
    );
  }

  @override
  bool shouldRepaint(RectangleRangeSymbolRenderer oldRenderer) {
    return this != oldRenderer;
  }

  @override
  List<Object?> get props => [];
}
