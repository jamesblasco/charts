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

import 'dart:math' show Point, max;

import 'package:charts/charts.dart';

/// Default Layout manager for [LayoutView]s.
class LayoutManagerImpl implements LayoutManager {
  /// Create a new [LayoutManager].
  LayoutManagerImpl({LayoutConfig? config}) : config = config ?? LayoutConfig();
  static const _minDrawWidth = 20.0;
  static const _minDrawHeight = 20.0;

  // Allow [Layoutconfig] to be mutable so it can be modified without requiring
  // a new copy of [DefaultLayoutManager] to be created.
  LayoutConfig config;

  /// Unordered list of views in the layout.
  final _views = <LayoutView>[];

  /// List of views in the order they should be drawn on the canvas.
  ///
  /// First element is painted first.
  late List<LayoutView> _paintOrderedViews;

  /// List of vies in the order they should be positioned in a chart margin.
  ///
  /// First element is closest to the draw area.
  late List<LayoutView> _positionOrderedViews;

  late _MeasuredSizes _measurements;

  late Rect _drawAreaBounds;
  bool _drawAreaBoundsOutdated = true;
  bool _viewsNeedPaintSort = true;
  bool _viewsNeedPositionSort = true;

  /// Add one [LayoutView].
  @override
  void addView(LayoutView view) {
    _views.add(view);
    _drawAreaBoundsOutdated = true;
    _viewsNeedPositionSort = true;
    _viewsNeedPaintSort = true;
  }

  /// Remove one [LayoutView].
  @override
  void removeView(LayoutView view) {
    if (_views.remove(view)) {
      _drawAreaBoundsOutdated = true;
      _viewsNeedPositionSort = true;
      _viewsNeedPaintSort = true;
    }
  }

  /// Returns true if [view] is already attached.
  @override
  bool isAttached(LayoutView view) => _views.contains(view);

  @override
  void updateConfig(LayoutConfig layoutConfig) {
    config = layoutConfig;
  }

  /// Get all layout components in the order to be drawn.
  @override
  List<LayoutView> get paintOrderedViews {
    if (_viewsNeedPaintSort) {
      _paintOrderedViews = List.of(_views);

      _paintOrderedViews.sort(
        (LayoutView v1, LayoutView v2) =>
            v1.layoutConfig.paintOrder!.compareTo(v2.layoutConfig.paintOrder!),
      );

      _viewsNeedPaintSort = false;
    }
    return _paintOrderedViews;
  }

  /// Get all layout components in the order to be visited.
  @override
  List<LayoutView> get positionOrderedViews {
    if (_viewsNeedPositionSort) {
      _positionOrderedViews = List.of(_views);

      _positionOrderedViews.sort(
        (LayoutView v1, LayoutView v2) => v1.layoutConfig.positionOrder!
            .compareTo(v2.layoutConfig.positionOrder!),
      );

      _viewsNeedPositionSort = false;
    }
    return _positionOrderedViews;
  }

  @override
  Rect get drawAreaBounds {
    assert(_drawAreaBoundsOutdated == false);
    return _drawAreaBounds;
  }

  @override
  Rect get drawableLayoutAreaBounds {
    assert(_drawAreaBoundsOutdated == false);

    final drawableViews =
        _views.where((LayoutView view) => view.isSeriesRenderer);

    var componentBounds = drawableViews.first.componentBounds;

    if (componentBounds != null) {
      for (final view in drawableViews.skip(1)) {
        if (view.componentBounds != null) {
          // See https://github.com/dart-lang/language/issues/1308 for why
          // `componentBounds` isn't promoted to be non-nullable.
          componentBounds =
              componentBounds!.expandToInclude(view.componentBounds!);
        }
      }
    } else {
      componentBounds = Rect.zero;
    }

    return componentBounds!;
  }

  @override
  double get marginBottom {
    assert(_drawAreaBoundsOutdated == false);
    return _measurements.bottomHeight;
  }

  @override
  double get marginLeft {
    assert(_drawAreaBoundsOutdated == false);
    return _measurements.leftWidth;
  }

  @override
  double get marginRight {
    assert(_drawAreaBoundsOutdated == false);
    return _measurements.rightWidth;
  }

  @override
  double get marginTop {
    assert(_drawAreaBoundsOutdated == false);
    return _measurements.topHeight;
  }

  @override
  bool withinDrawArea(Offset point) {
    return _drawAreaBounds.containsPoint(point);
  }

  /// Measure and layout with given [width] and [height].
  @override
  void measure(double width, double height) {
    final topViews =
        _viewsForPositions(LayoutPosition.top, LayoutPosition.fullTop);
    final rightViews =
        _viewsForPositions(LayoutPosition.right, LayoutPosition.fullRight);
    final bottomViews =
        _viewsForPositions(LayoutPosition.bottom, LayoutPosition.fullBottom);
    final leftViews =
        _viewsForPositions(LayoutPosition.left, LayoutPosition.fullLeft);

    // Assume the full width and height of the chart is available when measuring
    // for the first time but adjust the maximum if margin spec is set.
    var measurements = _measure(
      width,
      height,
      topViews: topViews,
      rightViews: rightViews,
      bottomViews: bottomViews,
      leftViews: leftViews,
      useMax: true,
    );

    // Measure a second time but pass in the preferred width and height from
    // the first measure cycle.
    // Allow views to report a different size than the previously measured max.
    final secondMeasurements = _measure(
      width,
      height,
      topViews: topViews,
      rightViews: rightViews,
      bottomViews: bottomViews,
      leftViews: leftViews,
      previousMeasurements: measurements,
      useMax: true,
    );

    // If views need more space with the 2nd pass, perform a third pass.
    if (measurements.leftWidth != secondMeasurements.leftWidth ||
        measurements.rightWidth != secondMeasurements.rightWidth ||
        measurements.topHeight != secondMeasurements.topHeight ||
        measurements.bottomHeight != secondMeasurements.bottomHeight) {
      final thirdMeasurements = _measure(
        width,
        height,
        topViews: topViews,
        rightViews: rightViews,
        bottomViews: bottomViews,
        leftViews: leftViews,
        previousMeasurements: secondMeasurements,
        useMax: false,
      );

      measurements = thirdMeasurements;
    } else {
      measurements = secondMeasurements;
    }

    _measurements = measurements;

    // Draw area size.
    // Set to a minimum size if there is not enough space for the draw area.
    // Prevents the app from crashing by rendering overlapping content instead.
    final drawAreaWidth = max(
      _minDrawWidth,
      width - measurements.leftWidth - measurements.rightWidth,
    );
    final drawAreaHeight = max(
      _minDrawHeight,
      height - measurements.bottomHeight - measurements.topHeight,
    );

    // Bounds for the draw area.
    _drawAreaBounds = Rect.fromLTWH(
      measurements.leftWidth,
      measurements.topHeight,
      drawAreaWidth,
      drawAreaHeight,
    );
    _drawAreaBoundsOutdated = false;
  }

  @override
  void layout(double width, double height) {
    final topViews =
        _viewsForPositions(LayoutPosition.top, LayoutPosition.fullTop);
    final rightViews =
        _viewsForPositions(LayoutPosition.right, LayoutPosition.fullRight);
    final bottomViews =
        _viewsForPositions(LayoutPosition.bottom, LayoutPosition.fullBottom);
    final leftViews =
        _viewsForPositions(LayoutPosition.left, LayoutPosition.fullLeft);
    final drawAreaViews = _viewsForPositions(LayoutPosition.drawArea);

    final fullBounds = Rect.fromLTWH(0, 0, width, height);

    // Layout the margins.
    LeftMarginLayoutStrategy()
        .layout(leftViews, _measurements.leftSizes, fullBounds, drawAreaBounds);
    RightMarginLayoutStrategy().layout(
      rightViews,
      _measurements.rightSizes,
      fullBounds,
      drawAreaBounds,
    );
    BottomMarginLayoutStrategy().layout(
      bottomViews,
      _measurements.bottomSizes,
      fullBounds,
      drawAreaBounds,
    );
    TopMarginLayoutStrategy()
        .layout(topViews, _measurements.topSizes, fullBounds, drawAreaBounds);

    // Layout the drawArea.
    for (final view in drawAreaViews) {
      view.layout(_drawAreaBounds, _drawAreaBounds);
    }
  }

  Iterable<LayoutView> _viewsForPositions(
    LayoutPosition p1, [
    LayoutPosition? p2,
  ]) {
    return positionOrderedViews.where(
      (LayoutView view) =>
          view.layoutConfig.position == p1 ||
          (p2 != null && view.layoutConfig.position == p2),
    );
  }

  /// Measure and return size measurements.
  /// [width] full width of chart
  /// [height] full height of chart
  _MeasuredSizes _measure(
    double width,
    double height, {
    required Iterable<LayoutView> topViews,
    required Iterable<LayoutView> rightViews,
    required Iterable<LayoutView> bottomViews,
    required Iterable<LayoutView> leftViews,
    _MeasuredSizes? previousMeasurements,
    required bool useMax,
  }) {
    final maxLeftWidth = config.margin.left.getMaxPixels(width);
    final maxRightWidth = config.margin.right.getMaxPixels(width);
    final maxBottomHeight = config.margin.bottom.getMaxPixels(height);
    final maxTopHeight = config.margin.top.getMaxPixels(height);

    // Assume the full width and height of the chart is available when measuring
    // for the first time but adjust the maximum if margin spec is set.
    var leftWidth = previousMeasurements?.leftWidth ?? maxLeftWidth;
    var rightWidth = previousMeasurements?.rightWidth ?? maxRightWidth;
    var bottomHeight = previousMeasurements?.bottomHeight ?? maxBottomHeight;
    var topHeight = previousMeasurements?.topHeight ?? maxTopHeight;

    // Only adjust the height if we have previous measurements.
    final adjustedHeight = (previousMeasurements != null)
        ? height - bottomHeight - topHeight
        : height;

    final leftSizes = LeftMarginLayoutStrategy().measure(
      leftViews,
      maxWidth: useMax ? maxLeftWidth : leftWidth,
      height: adjustedHeight,
      fullHeight: height,
    );

    leftWidth = max(leftSizes.total, config.margin.left.getMinPixels(width));

    final rightSizes = RightMarginLayoutStrategy().measure(
      rightViews,
      maxWidth: useMax ? maxRightWidth : rightWidth,
      height: adjustedHeight,
      fullHeight: height,
    );
    rightWidth = max(rightSizes.total, config.margin.right.getMinPixels(width));

    final adjustedWidth = width - leftWidth - rightWidth;

    final bottomSizes = BottomMarginLayoutStrategy().measure(
      bottomViews,
      maxHeight: useMax ? maxBottomHeight : bottomHeight,
      width: adjustedWidth,
      fullWidth: width,
    );
    bottomHeight =
        max(bottomSizes.total, config.margin.bottom.getMinPixels(height));

    final topSizes = TopMarginLayoutStrategy().measure(
      topViews,
      maxHeight: useMax ? maxTopHeight : topHeight,
      width: adjustedWidth,
      fullWidth: width,
    );
    topHeight = max(topSizes.total, config.margin.top.getMinPixels(height));

    return _MeasuredSizes(
      leftWidth: leftWidth,
      leftSizes: leftSizes,
      rightWidth: rightWidth,
      rightSizes: rightSizes,
      topHeight: topHeight,
      topSizes: topSizes,
      bottomHeight: bottomHeight,
      bottomSizes: bottomSizes,
    );
  }

  @override
  void applyToViews(void Function(LayoutView view) apply) {
    _views.forEach(apply);
  }
}

/// Helper class that stores measured width and height during measure cycles.
class _MeasuredSizes {
  _MeasuredSizes({
    required this.leftWidth,
    required this.leftSizes,
    required this.rightWidth,
    required this.rightSizes,
    required this.topHeight,
    required this.topSizes,
    required this.bottomHeight,
    required this.bottomSizes,
  });
  final double leftWidth;
  final SizeList leftSizes;

  final double rightWidth;
  final SizeList rightSizes;

  final double topHeight;
  final SizeList topSizes;

  final double bottomHeight;
  final SizeList bottomSizes;
}
