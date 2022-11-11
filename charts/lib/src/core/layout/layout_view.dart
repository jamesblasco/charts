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

import 'dart:math' show Rectangle;

import 'package:charts/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Position of a [LayoutView].
enum LayoutPosition {
  bottom,
  fullBottom,

  top,
  fullTop,

  left,
  fullLeft,

  right,
  fullRight,

  drawArea,
}

/// Standard layout paint orders for all internal components.
///
/// Custom component layers should define their paintOrder by taking the nearest
/// layer from this list, and adding or subtracting 1. This will help reduce the
/// chance of custom behaviors, renderers, etc. from breaking if we need to
/// re-order these components internally.
class LayoutViewPaintOrder {
  // Draw range annotations beneath axis grid lines.
  static const rangeAnnotation = -10;
  // Axis elements form the "base layer" of all components on the chart. Domain
  // axes are drawn on top of measure axes to ensure that the domain axis line
  // appears on top of any measure axis grid lines.
  static const measureAxis = 0;
  static const domainAxis = 5;
  // Draw series data on top of axis elements.
  static const arc = 10;
  static const bar = 10;
  static const treeMap = 10;
  static const sankey = 10;
  static const barTargetLine = 15;
  static const line = 20;
  static const point = 25;
  // Draw most behaviors on top of series data.
  static const legend = 100;
  static const linePointHighlighter = 110;
  static const slider = 150;
  static const chartTitle = 160;
}

/// Standard layout position orders for all internal components.
///
/// Custom component layers should define their positionOrder by taking the
/// nearest component from this list, and adding or subtracting 1. This will
/// help reduce the chance of custom behaviors, renderers, etc. from breaking if
/// we need to re-order these components internally.
class LayoutViewPositionOrder {
  static const drawArea = 0;
  static const symbolAnnotation = 10;
  static const axis = 20;
  static const legend = 30;
  static const chartTitle = 40;
}

/// A configuration for margin (empty space) around a layout child view.
class ViewMargin {
  const ViewMargin({int? top, int? bottom, int? right, int? left})
      : top = top ?? 0,
        bottom = bottom ?? 0,
        right = right ?? 0,
        left = left ?? 0;

  /// A [ViewMargin] with all zero px.
  static const empty = ViewMargin(top: 0, bottom: 0, right: 0, left: 0);

  final int top;
  final int bottom;
  final int right;
  final int left;

  /// Total width.
  int get width => left + right;

  /// Total height.
  int get height => top + bottom;
}

/// Configuration of a [LayoutView].
@immutable
class LayoutViewConfig extends Equatable {
  /// Creates new [LayoutParams].
  ///
  /// [paintOrder] the order that this component will be drawn.
  /// [position] the [ComponentPosition] of this component.
  /// [positionOrder] the order of this component in a chart margin.
  const LayoutViewConfig({
    this.id,
    this.paintOrder,
    this.position,
    this.positionOrder,
    ViewMargin? viewMargin,
  }) : viewMargin = viewMargin ?? ViewMargin.empty;

  /// Unique identifier for the [LayoutView].
  final String? id;

  /// The order to paint a [LayoutView] on the canvas.
  ///
  /// The smaller number is drawn first.
  final int? paintOrder;

  /// The position of a [LayoutView] defining where to place the view.
  final LayoutPosition? position;

  /// The order to place the [LayoutView] within a chart margin.
  ///
  /// The smaller number is closer to the draw area. Elements positioned closer
  /// to the draw area will be given extra layout space first, before those
  /// further away.
  ///
  /// Note that all views positioned in the draw area are given the entire draw
  /// area bounds as their component bounds.
  final int? positionOrder;

  /// Defines the space around a layout component.
  final ViewMargin viewMargin;

  /// Returns true if it is a full position.
  bool get isFullPosition =>
      position == LayoutPosition.fullBottom ||
      position == LayoutPosition.fullTop ||
      position == LayoutPosition.fullRight ||
      position == LayoutPosition.fullLeft;

  LayoutViewConfig copyWith({
    String? id,
    int? paintOrder,
    LayoutPosition? position,
    int? positionOrder,
    ViewMargin? viewMargin,
  }) {
    return LayoutViewConfig(
      id: id ?? this.id,
      paintOrder: paintOrder ?? this.paintOrder,
      position: position ?? this.position,
      positionOrder: positionOrder ?? this.positionOrder,
      viewMargin: viewMargin ?? this.viewMargin,
    );
  }

  @override
  List<Object?> get props => [
        id,
        paintOrder,
        position,
        positionOrder,
        viewMargin,
      ];
}

/// Size measurements of one component.
///
/// The measurement is tight to the component, without adding [ComponentBuffer].
class ViewMeasuredSizes {
  /// Create a new [ViewSizes].
  ///
  /// [preferredWidth] the component's preferred width.
  /// [preferredHeight] the component's preferred width.
  /// [minWidth] the component's minimum width. If not set, default to 0.
  /// [minHeight] the component's minimum height. If not set, default to 0.
  const ViewMeasuredSizes({
    required this.preferredWidth,
    required this.preferredHeight,
    double? minWidth,
    double? minHeight,
  })  : minWidth = minWidth ?? 0,
        minHeight = minHeight ?? 0;

  /// All zeroes component size.
  static const zero = ViewMeasuredSizes(
    preferredWidth: 0,
    preferredHeight: 0,
    minWidth: 0,
    minHeight: 0,
  );

  final double preferredWidth;
  final double preferredHeight;
  final double minWidth;
  final double minHeight;
}

/// A component that measures its size and accepts bounds to complete layout.
abstract class LayoutView {
  GraphicsFactory? get graphicsFactory;

  set graphicsFactory(GraphicsFactory? value);

  /// Layout params for this component.
  LayoutViewConfig get layoutConfig;

  /// Measure and return the size of this component.
  ///
  /// This measurement is without the [ComponentBuffer], which is added by the
  /// layout manager.
  ViewMeasuredSizes? measure(double maxWidth, double maxHeight);

  /// Layout this component.
  void layout(
      Rectangle<double> componentBounds, Rectangle<double> drawAreaBounds);

  /// Draw this component on the canvas.
  void paint(ChartCanvas canvas, double animationPercent);

  /// Bounding box for drawing this component.
  Rectangle<double>? get componentBounds;

  /// Whether or not this component is a series renderer that draws series
  /// data.
  ///
  /// This component may either render into the chart's draw area, or into a
  /// separate area bounded by the component bounds.
  bool get isSeriesRenderer;
}

/// Translates a component's [BehaviorPosition] and [OutsideJustification] into
/// a [LayoutPosition] that a [LayoutManager] can use to place components on the
/// chart.
LayoutPosition layoutPosition(
  BehaviorPosition behaviorPosition,
  OutsideJustification outsideJustification,
  bool isRtl,
) {
  LayoutPosition position;
  switch (behaviorPosition) {
    case BehaviorPosition.bottom:
      position = LayoutPosition.bottom;
      break;
    case BehaviorPosition.end:
      position = isRtl ? LayoutPosition.left : LayoutPosition.right;
      break;
    case BehaviorPosition.inside:
      position = LayoutPosition.drawArea;
      break;
    case BehaviorPosition.start:
      position = isRtl ? LayoutPosition.right : LayoutPosition.left;
      break;
    case BehaviorPosition.top:
      position = LayoutPosition.top;
      break;
  }

  // If we have a "full" [OutsideJustification], convert the layout position
  // to the "full" form.
  if (outsideJustification == OutsideJustification.start ||
      outsideJustification == OutsideJustification.middle ||
      outsideJustification == OutsideJustification.end) {
    switch (position) {
      case LayoutPosition.bottom:
        position = LayoutPosition.fullBottom;
        break;
      case LayoutPosition.left:
        position = LayoutPosition.fullLeft;
        break;
      case LayoutPosition.top:
        position = LayoutPosition.fullTop;
        break;
      case LayoutPosition.right:
        position = LayoutPosition.fullRight;
        break;

      // Ignore other positions, like DrawArea.
      default:
        break;
    }
  }

  return position;
}
