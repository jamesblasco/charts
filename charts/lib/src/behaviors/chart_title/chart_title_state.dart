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

import 'package:charts/core.dart';
import 'package:flutter/cupertino.dart';

/// Chart behavior that adds title text to a chart. An optional second line of
/// text may be rendered as a sub-title.
///
/// Titles will by default be rendered as the outermost component in the chart
/// margin.
class ChartTitleBehaviorState<D> implements ChartBehaviorState<D> {
  /// Constructs a [ChartTitleBehaviorState].
  ///
  /// [title] contains the text for the chart title.
  ChartTitleBehaviorState(
    String title, {
    BehaviorPosition? behaviorPosition,
    double? innerPadding,
    double? layoutMinSize,
    double? layoutPreferredSize,
    double? outerPadding,
    MaxWidthStrategy? maxWidthStrategy,
    ChartTitleDirection? titleDirection,
    OutsideJustification? titleOutsideJustification,
    double? titlePadding,
    TextStyle? titleStyleSpec,
    String? subTitle,
    TextStyle? subTitleStyleSpec,
  }) : _config = _ChartTitleConfig(
          behaviorPosition: behaviorPosition ?? _defaultBehaviorPosition,
          innerPadding: innerPadding ?? _defaultInnerPadding,
          layoutMinSize: layoutMinSize,
          layoutPreferredSize: layoutPreferredSize,
          outerPadding: outerPadding ?? _defaultOuterPadding,
          maxWidthStrategy: maxWidthStrategy ?? _defaultMaxWidthStrategy,
          title: title,
          titleDirection: titleDirection ?? _defaultTitleDirection,
          titleOutsideJustification:
              titleOutsideJustification ?? _defaultTitleOutsideJustification,
          titlePadding: titlePadding ?? _defaultTitlePadding,
          titleStyleSpec: titleStyleSpec ?? _defaultTitleStyle,
          subTitle: subTitle,
          subTitleStyleSpec: subTitleStyleSpec ?? _defaultSubTitleStyle,
        ) {
    _lifecycleListener =
        LifecycleListener<D>(onAxisConfigured: _updateViewData);
  }
  static const _defaultBehaviorPosition = BehaviorPosition.top;
  static const _defaultMaxWidthStrategy = MaxWidthStrategy.ellipsize;
  static const _defaultTitleDirection = ChartTitleDirection.auto;
  static const _defaultTitleOutsideJustification = OutsideJustification.middle;
  static final _defaultTitleStyle =
      TextStyle(fontSize: 18, color: StyleFactory.style.tickColor);
  static final _defaultSubTitleStyle =
      TextStyle(fontSize: 14, color: StyleFactory.style.tickColor);
  static const _defaultInnerPadding = 10.0;
  static const _defaultTitlePadding = 18.0;
  static const _defaultOuterPadding = 10.0;

  /// Stores all of the configured properties of the behavior.
  final _ChartTitleConfig _config;

  BaseRenderChart<D>? _chart;

  _ChartTitleLayoutView<D>? _view;

  late final LifecycleListener<D> _lifecycleListener;

  /// Layout position for the title.
  BehaviorPosition get behaviorPosition => _config.behaviorPosition;

  set behaviorPosition(BehaviorPosition behaviorPosition) {
    _config.behaviorPosition = behaviorPosition;
  }

  /// Minimum size of the legend component. Optional.
  ///
  /// If the legend is positioned in the top or bottom margin, then this
  /// configures the legend's height. If positioned in the start or end
  /// position, this configures the legend's width.
  double? get layoutMinSize => _config.layoutMinSize;

  set layoutMinSize(double? layoutMinSize) {
    _config.layoutMinSize = layoutMinSize;
  }

  /// Preferred size of the legend component. Defaults to 0.
  ///
  /// If the legend is positioned in the top or bottom margin, then this
  /// configures the legend's height. If positioned in the start or end
  /// position, this configures the legend's width.
  double? get layoutPreferredSize => _config.layoutPreferredSize;

  set layoutPreferredSize(double? layoutPreferredSize) {
    _config.layoutPreferredSize = layoutPreferredSize;
  }

  /// Strategy for handling title text that is too large to fit. Defaults to
  /// truncating the text with ellipses.
  MaxWidthStrategy get maxWidthStrategy => _config.maxWidthStrategy;

  set maxWidthStrategy(MaxWidthStrategy maxWidthStrategy) {
    _config.maxWidthStrategy = maxWidthStrategy;
  }

  /// Primary text for the title.
  String get title => _config.title;

  set title(String title) {
    _config.title = title;
  }

  /// Direction of the chart title text.
  ///
  /// This defaults to horizontal for a title in the top or bottom
  /// [behaviorPosition], or vertical for start or end [behaviorPosition].
  ChartTitleDirection get titleDirection => _config.titleDirection;

  set titleDirection(ChartTitleDirection titleDirection) {
    _config.titleDirection = titleDirection;
  }

  /// Justification of the title text if it is positioned outside of the draw
  /// area.
  OutsideJustification get titleOutsideJustification =>
      _config.titleOutsideJustification;

  set titleOutsideJustification(
    OutsideJustification titleOutsideJustification,
  ) {
    _config.titleOutsideJustification = titleOutsideJustification;
  }

  /// Space between the title and sub-title text, if defined.
  ///
  /// This padding is not used if no sub-title is provided.
  double get titlePadding => _config.titlePadding;

  set titlePadding(double titlePadding) {
    _config.titlePadding = titlePadding;
  }

  /// Style of the [title] text.
  TextStyle get titleStyleSpec => _config.titleStyleSpec;

  set titleStyleSpec(TextStyle titleStyleSpec) {
    _config.titleStyleSpec = titleStyleSpec;
  }

  /// Secondary text for the sub-title.
  ///
  /// [subTitle] is rendered on a second line below the [title], and may be
  /// styled differently.
  String? get subTitle => _config.subTitle;

  set subTitle(String? subTitle) {
    _config.subTitle = subTitle;
  }

  /// Style of the [subTitle] text.
  TextStyle get subTitleStyleSpec => _config.subTitleStyleSpec;

  set subTitleStyleSpec(TextStyle subTitleStyleSpec) {
    _config.subTitleStyleSpec = subTitleStyleSpec;
  }

  /// Space between the "inside" of the chart, and the title behavior itself.
  ///
  /// This padding is applied to all the edge of the title that is in the
  /// direction of the draw area. For a top positioned title, this is applied
  /// to the bottom edge. [outerPadding] is applied to the top, left, and right
  /// edges.
  ///
  /// If a sub-title is defined, this is the space between the sub-title text
  /// and the inside of the chart. Otherwise, it is the space between the title
  /// text and the inside of chart.
  double get innerPadding => _config.innerPadding;

  set innerPadding(double innerPadding) {
    _config.innerPadding = innerPadding;
  }

  /// Space between the "outside" of the chart, and the title behavior itself.
  ///
  /// This padding is applied to all 3 edges of the title that are not in the
  /// direction of the draw area. For a top positioned title, this is applied
  /// to the top, left, and right edges. [innerPadding] is applied to the
  /// bottom edge.
  double get outerPadding => _config.outerPadding;

  set outerPadding(double outerPadding) {
    _config.outerPadding = outerPadding;
  }

  @override
  void attachTo(BaseRenderChart<D> chart) {
    _chart = chart;

    _view = _ChartTitleLayoutView<D>(
      layoutPaintOrder: LayoutViewPaintOrder.chartTitle,
      config: _config,
      chart: _chart,
    );

    chart.addView(_view!);
    chart.addLifecycleListener(_lifecycleListener);
  }

  @override
  void removeFrom(BaseRenderChart<D> chart) {
    chart.removeView(_view!);
    chart.removeLifecycleListener(_lifecycleListener);
    _chart = null;
  }

  void _updateViewData() {
    _view!.config = _config;
  }

  @override
  String get role => 'ChartTitle-${_config.behaviorPosition}';

  bool get isRtl => _chart!.context.isRtl;
}

/// Layout view component for [ChartTitleBehaviorState].
class _ChartTitleLayoutView<D> extends LayoutView {
  _ChartTitleLayoutView({
    required int layoutPaintOrder,
    required _ChartTitleConfig config,
    required this.chart,
  }) : _config = config {
    // Set inside body to resolve [_layoutPosition].
    _layoutConfig = LayoutViewConfig(
      paintOrder: layoutPaintOrder,
      position: _layoutPosition,
      positionOrder: LayoutViewPositionOrder.chartTitle,
    );
  }
  late LayoutViewConfig _layoutConfig;

  @override
  LayoutViewConfig get layoutConfig => _layoutConfig;

  /// Stores all of the configured properties of the behavior.
  _ChartTitleConfig _config;

  BaseRenderChart<D>? chart;

  bool get isRtl => chart?.context.isRtl ?? false;

  late Rectangle<double> _componentBounds;
  late Rectangle<double> _drawAreaBounds;

  @override
  GraphicsFactory? graphicsFactory;

  /// Cached layout element for the title text.
  ///
  /// This is used to prevent expensive Flutter painter layout calls on every
  /// animation frame during the paint cycle. It should never be cached during
  /// layout measurement.
  TextElement? _titleTextElement;

  /// Cached layout element for the sub-title text.
  ///
  /// This is used to prevent expensive Flutter painter layout calls on every
  /// animation frame during the paint cycle. It should never be cached during
  /// layout measurement.
  TextElement? _subTitleTextElement;

  /// Sets the configuration for the title behavior.
  set config(_ChartTitleConfig config) {
    _config = config;
    _layoutConfig = _layoutConfig.copyWith(position: _layoutPosition);
  }

  @override
  ViewMeasuredSizes measure(double maxWidth, double maxHeight) {
    double? minWidth;
    double? minHeight;
    var preferredWidth = 0.0;
    var preferredHeight = 0.0;

    // Always assume that we need outer padding and title padding, but only add
    // in the sub-title padding if we have one. Title is required, but sub-title
    // is optional.
    final totalPadding = _config.outerPadding +
        _config.innerPadding +
        (_config.subTitle != null ? _config.titlePadding : 0.0);

    final graphicsFactory = this.graphicsFactory!;

    // Create [TextStyle] from [TextStyle] to be used by all the elements.
    // The [GraphicsFactory] is needed so it can't be created earlier.
    final textStyle = _getTextStyle(graphicsFactory, _config.titleStyleSpec);

    final textElement = graphicsFactory.createTextElement(_config.title)
      ..maxWidthStrategy = _config.maxWidthStrategy
      ..textStyle = textStyle;

    final subTitleTextStyle =
        _getTextStyle(graphicsFactory, _config.subTitleStyleSpec);

    final subTitleTextElement = _config.subTitle == null
        ? null
        : (graphicsFactory.createTextElement(_config.subTitle!)
          ..maxWidthStrategy = _config.maxWidthStrategy
          ..textStyle = subTitleTextStyle);

    final resolvedTitleDirection = _resolvedTitleDirection;

    switch (_config.behaviorPosition) {
      case BehaviorPosition.bottom:
      case BehaviorPosition.top:
        final textHeight =
            (resolvedTitleDirection == ChartTitleDirection.vertical
                    ? textElement.measurement.horizontalSliceWidth
                    : textElement.measurement.verticalSliceWidth)
                .round();

        final subTitleTextHeight = subTitleTextElement != null
            ? (resolvedTitleDirection == ChartTitleDirection.vertical
                    ? subTitleTextElement.measurement.horizontalSliceWidth
                    : subTitleTextElement.measurement.verticalSliceWidth)
                .round()
            : 0;

        final measuredHeight = textHeight + subTitleTextHeight + totalPadding;
        minHeight = _config.layoutMinSize != null
            ? min(_config.layoutMinSize!, measuredHeight)
            : measuredHeight;

        preferredWidth = maxWidth;

        preferredHeight = _config.layoutPreferredSize != null
            ? min(_config.layoutPreferredSize!, maxHeight)
            : measuredHeight;
        break;

      case BehaviorPosition.end:
      case BehaviorPosition.start:
        final textWidth =
            (resolvedTitleDirection == ChartTitleDirection.vertical
                    ? textElement.measurement.verticalSliceWidth
                    : textElement.measurement.horizontalSliceWidth)
                .round();

        final subTitleTextWidth = subTitleTextElement != null
            ? (resolvedTitleDirection == ChartTitleDirection.vertical
                    ? subTitleTextElement.measurement.verticalSliceWidth
                    : subTitleTextElement.measurement.horizontalSliceWidth)
                .round()
            : 0;

        final measuredWidth = textWidth + subTitleTextWidth + totalPadding;
        minWidth = _config.layoutMinSize != null
            ? min(_config.layoutMinSize!, measuredWidth)
            : measuredWidth;

        preferredWidth = _config.layoutPreferredSize != null
            ? min(_config.layoutPreferredSize!, maxWidth)
            : measuredWidth;

        preferredHeight = maxHeight;
        break;

      case BehaviorPosition.inside:
        preferredWidth = _drawAreaBounds != null
            ? min(_drawAreaBounds.width, maxWidth)
            : maxWidth;

        preferredHeight = _drawAreaBounds != null
            ? min(_drawAreaBounds.height, maxHeight)
            : maxHeight;
        break;
    }

    // Reset the cached text elements used during the paint step.
    _resetTextElementCache();

    return ViewMeasuredSizes(
      minWidth: minWidth,
      minHeight: minHeight,
      preferredWidth: preferredWidth,
      preferredHeight: preferredHeight,
    );
  }

  @override
  void layout(
      Rectangle<double> componentBounds, Rectangle<double> drawAreaBounds) {
    _componentBounds = componentBounds;
    _drawAreaBounds = drawAreaBounds;

    // Reset the cached text elements used during the paint step.
    _resetTextElementCache();
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {
    final resolvedTitleDirection = _resolvedTitleDirection;

    var titleHeight = 0.0;
    var subTitleHeight = 0.0;

    // First, measure the height of the title and sub-title.
    if (_titleTextElement == null) {
      // Create [TextStyle] from [TextStyle] to be used by all the
      // elements. The [GraphicsFactory] is needed so it can't be created
      // earlier.
      final textStyle = _getTextStyle(graphicsFactory!, _config.titleStyleSpec);

      _titleTextElement = graphicsFactory!.createTextElement(_config.title)
        ..maxWidthStrategy = _config.maxWidthStrategy
        ..textStyle = textStyle;

      _titleTextElement!.maxWidth =
          resolvedTitleDirection == ChartTitleDirection.horizontal
              ? _componentBounds.width
              : _componentBounds.height;
    }

    // Get the height of the title so that we can off-set both text elements.
    titleHeight = _titleTextElement!.measurement.verticalSliceWidth;

    if (_config.subTitle != null) {
      // Chart titles do not animate. As an optimization for Flutter, cache the
      // [TextElement] to avoid an expensive painter layout operation on
      // subsequent animation frames.
      if (_subTitleTextElement == null) {
        // Create [TextStyle] from [TextStyle] to be used by all the
        // elements. The [GraphicsFactory] is needed so it can't be created
        // earlier.
        final textStyle =
            _getTextStyle(graphicsFactory!, _config.subTitleStyleSpec);

        _subTitleTextElement =
            graphicsFactory!.createTextElement(_config.subTitle!)
              ..maxWidthStrategy = _config.maxWidthStrategy
              ..textStyle = textStyle;

        _subTitleTextElement!.maxWidth =
            resolvedTitleDirection == ChartTitleDirection.horizontal
                ? _componentBounds.width
                : _componentBounds.height;
      }

      // Get the height of the sub-title so that we can off-set both text
      // elements.
      subTitleHeight = _subTitleTextElement!.measurement.verticalSliceWidth;
    }

    // Draw a title if the text is not empty.
    final labelPoint = _getLabelPosition(
      true,
      _componentBounds,
      resolvedTitleDirection,
      _titleTextElement!,
      titleHeight,
      subTitleHeight,
    );

    if (labelPoint != null) {
      final rotation = resolvedTitleDirection == ChartTitleDirection.vertical
          ? -pi / 2
          : 0.0;

      canvas.drawText(
        _titleTextElement!,
        labelPoint.x,
        labelPoint.y,
        rotation: rotation,
      );
    }

    // Draw a sub-title if the text is not empty.
    if (_config.subTitle != null) {
      final labelPoint = _getLabelPosition(
        false,
        _componentBounds,
        resolvedTitleDirection,
        _subTitleTextElement!,
        titleHeight,
        subTitleHeight,
      );

      if (labelPoint != null) {
        final rotation = resolvedTitleDirection == ChartTitleDirection.vertical
            ? -pi / 2
            : 0.0;

        canvas.drawText(
          _subTitleTextElement!,
          labelPoint.x,
          labelPoint.y,
          rotation: rotation,
        );
      }
    }
  }

  /// Resets the cached text elements used during the paint step.
  void _resetTextElementCache() {
    _titleTextElement = null;
    _subTitleTextElement = null;
  }

  /// Get the direction of the title, resolving "auto" position into the
  /// appropriate direction for the position of the behavior.
  ChartTitleDirection get _resolvedTitleDirection {
    var resolvedTitleDirection = _config.titleDirection;
    if (resolvedTitleDirection == ChartTitleDirection.auto) {
      switch (_config.behaviorPosition) {
        case BehaviorPosition.bottom:
        case BehaviorPosition.inside:
        case BehaviorPosition.top:
          resolvedTitleDirection = ChartTitleDirection.horizontal;
          break;
        case BehaviorPosition.end:
        case BehaviorPosition.start:
          resolvedTitleDirection = ChartTitleDirection.vertical;
          break;
      }
    }

    return resolvedTitleDirection;
  }

  /// Get layout position from chart title position.
  LayoutPosition get _layoutPosition {
    return layoutPosition(
      _config.behaviorPosition,
      _config.titleOutsideJustification,
      isRtl,
    );
  }

  /// Gets the resolved location for a label element.
  Point<double>? _getLabelPosition(
    bool isPrimaryTitle,
    Rectangle<num> bounds,
    ChartTitleDirection titleDirection,
    TextElement textElement,
    double titleHeight,
    double subTitleHeight,
  ) {
    switch (_config.behaviorPosition) {
      case BehaviorPosition.bottom:
      case BehaviorPosition.top:
        return _getHorizontalLabelPosition(
          isPrimaryTitle,
          bounds,
          titleDirection,
          textElement,
          titleHeight,
          subTitleHeight,
        );

      case BehaviorPosition.start:
      case BehaviorPosition.end:
        return _getVerticalLabelPosition(
          isPrimaryTitle,
          bounds,
          titleDirection,
          textElement,
          titleHeight,
          subTitleHeight,
        );

      case BehaviorPosition.inside:
        return null;
    }
  }

  /// Gets the resolved location for a title in the top or bottom margin.
  Point<double> _getHorizontalLabelPosition(
    bool isPrimaryTitle,
    Rectangle<num> bounds,
    ChartTitleDirection titleDirection,
    TextElement textElement,
    double titleHeight,
    double subTitleHeight,
  ) {
    var labelX = 0.0;
    var labelY = 0.0;

    switch (_config.titleOutsideJustification) {
      case OutsideJustification.middle:
      case OutsideJustification.middleDrawArea:
        final textWidth =
            (isRtl ? 1 : -1) * textElement.measurement.horizontalSliceWidth / 2;
        labelX = bounds.left + bounds.width / 2 + textWidth;

        textElement.textDirection =
            isRtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
        break;

      case OutsideJustification.end:
      case OutsideJustification.endDrawArea:
      case OutsideJustification.start:
      case OutsideJustification.startDrawArea:
        final alignLeft = isRtl
            ? (_config.titleOutsideJustification == OutsideJustification.end ||
                _config.titleOutsideJustification ==
                    OutsideJustification.endDrawArea)
            : (_config.titleOutsideJustification ==
                    OutsideJustification.start ||
                _config.titleOutsideJustification ==
                    OutsideJustification.startDrawArea);

        // Don't apply outer padding if we are aligned to the draw area.
        final padding = (_config.titleOutsideJustification ==
                    OutsideJustification.endDrawArea ||
                _config.titleOutsideJustification ==
                    OutsideJustification.startDrawArea)
            ? 0.0
            : _config.outerPadding;

        if (alignLeft) {
          labelX = bounds.left + padding;
          textElement.textDirection = TextDirectionAligment.ltr;
        } else {
          labelX = bounds.right - padding;
          textElement.textDirection = TextDirectionAligment.rtl;
        }
        break;
    }

    // labelY is always relative to the component bounds.
    if (_config.behaviorPosition == BehaviorPosition.bottom) {
      final padding = _config.innerPadding +
          (isPrimaryTitle ? 0 : _config.titlePadding + titleHeight);

      labelY = bounds.top + padding;
    } else {
      var padding = 0.0 + _config.innerPadding;
      if (isPrimaryTitle) {
        padding +=
            (subTitleHeight > 0 ? _config.titlePadding + subTitleHeight : 0) +
                titleHeight;
      } else {
        padding += subTitleHeight;
      }

      labelY = bounds.bottom - padding;
    }

    return Point<double>(labelX, labelY);
  }

  /// Gets the resolved location for a title in the left or right margin.
  Point<double> _getVerticalLabelPosition(
    bool isPrimaryTitle,
    Rectangle<num> bounds,
    ChartTitleDirection titleDirection,
    TextElement textElement,
    double titleHeight,
    double subTitleHeight,
  ) {
    var labelX = 0.0;
    var labelY = 0.0;

    switch (_config.titleOutsideJustification) {
      case OutsideJustification.middle:
      case OutsideJustification.middleDrawArea:
        final textWidth =
            (isRtl ? -1 : 1) * textElement.measurement.horizontalSliceWidth / 2;
        labelY = bounds.top + bounds.height / 2 + textWidth;

        textElement.textDirection =
            isRtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
        break;

      case OutsideJustification.end:
      case OutsideJustification.endDrawArea:
      case OutsideJustification.start:
      case OutsideJustification.startDrawArea:
        final alignLeft = isRtl
            ? (_config.titleOutsideJustification == OutsideJustification.end ||
                _config.titleOutsideJustification ==
                    OutsideJustification.endDrawArea)
            : (_config.titleOutsideJustification ==
                    OutsideJustification.start ||
                _config.titleOutsideJustification ==
                    OutsideJustification.startDrawArea);

        // Don't apply outer padding if we are aligned to the draw area.
        final padding = (_config.titleOutsideJustification ==
                    OutsideJustification.endDrawArea ||
                _config.titleOutsideJustification ==
                    OutsideJustification.startDrawArea)
            ? 0.0
            : _config.outerPadding;

        if (alignLeft) {
          labelY = bounds.bottom - padding;
          textElement.textDirection = TextDirectionAligment.ltr;
        } else {
          labelY = bounds.top + padding;
          textElement.textDirection = TextDirectionAligment.rtl;
        }
        break;
    }

    // labelX is always relative to the component bounds.
    if (_layoutPosition == LayoutPosition.right ||
        _layoutPosition == LayoutPosition.fullRight) {
      final padding = _config.outerPadding +
          (isPrimaryTitle ? 0 : _config.titlePadding + titleHeight);

      labelX = bounds.left + padding;
    } else {
      final padding = _config.outerPadding +
          titleHeight +
          (isPrimaryTitle
              ? (subTitleHeight > 0 ? _config.titlePadding + subTitleHeight : 0)
              : 0.0);

      labelX = bounds.right - padding;
    }

    return Point<double>(labelX, labelY);
  }

  // Helper function that converts [TextStyle] to [TextStyle].
  TextStyle _getTextStyle(
    GraphicsFactory graphicsFactory,
    TextStyle labelSpec,
  ) {
    return graphicsFactory.createTextPaint().merge(
          TextStyle(
            fontSize: 18,
            color: StyleFactory.style.tickColor,
          ).merge(labelSpec),
        );
  }

  @override
  Rectangle<double> get componentBounds => _drawAreaBounds;

  @override
  bool get isSeriesRenderer => false;
}

/// Configuration object for [ChartTitleBehaviorState].
class _ChartTitleConfig {
  _ChartTitleConfig({
    required this.behaviorPosition,
    required this.layoutMinSize,
    required this.layoutPreferredSize,
    required this.maxWidthStrategy,
    required this.title,
    required this.titleDirection,
    required this.titleOutsideJustification,
    required this.titleStyleSpec,
    required this.subTitle,
    required this.subTitleStyleSpec,
    required this.innerPadding,
    required this.titlePadding,
    required this.outerPadding,
  });

  BehaviorPosition behaviorPosition;

  double? layoutMinSize;
  double? layoutPreferredSize;

  MaxWidthStrategy maxWidthStrategy;

  String title;
  ChartTitleDirection titleDirection;
  OutsideJustification titleOutsideJustification;
  TextStyle titleStyleSpec;

  String? subTitle;
  TextStyle subTitleStyleSpec;

  double innerPadding;
  double titlePadding;
  double outerPadding;
}

/// Direction of the title text on the chart.
enum ChartTitleDirection {
  /// Automatically assign a direction based on the [RangeAnnotationAxisType].
  ///
  /// [horizontal] for measure axes, or [vertical] for domain axes.
  auto,

  /// Text flows parallel to the x axis.
  horizontal,

  /// Text flows parallel to the y axis.
  vertical,
}
