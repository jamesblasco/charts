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

import 'dart:math' show Rectangle, min, max;

import 'package:charts/charts.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';
import 'package:meta/meta.dart' show protected, visibleForTesting;

export 'tick_providers/auto_adjusting_static_tick_provider.dart';

export 'collision_report.dart';
export 'draw_strategy/draw_strategy.dart';

export 'tick_formatters/formatters.dart';
export 'tick_providers/tick_providers.dart';
export 'linear/linear.dart';
export 'tick_providers/numeric_tick_provider.dart';
export 'ordinal_scale_domain_info.dart';

export 'scale/extents/extents.dart';
export 'scale/numeric_scale.dart';
export 'scale/ordinal_scale.dart';
export 'scale/scale.dart';
export 'scale/simple_ordinal_scale.dart';
export 'spec/spec.dart';

export 'tick/tick.dart';
export 'tick_providers/tick_strategy.dart';
export 'time/time.dart';

const measureAxisIdKey = AttributeKey<String>('Axis.measureAxisId');
const measureAxisKey =
    AttributeKey<MutableAxisElement<Object>>('Axis.measureAxis');
const domainAxisKey =
    AttributeKey<MutableAxisElement<Object>>('Axis.domainAxis');

/// Orientation of an Axis.
enum AxisOrientation { top, right, bottom, left }

abstract class ImmutableAxisElement<D> {
  /// Compare domain to the viewport.
  ///
  /// 0 if the domain is in the viewport.
  /// 1 if the domain is to the right of the viewport.
  /// -1 if the domain is to the left of the viewport.
  int compareDomainValueToViewport(D domain);

  /// Get location for the domain.
  double? getLocation(D? domain);

  D getDomain(double location);

  /// Rangeband for this axis.
  double get rangeBand;

  /// Step size for this axis.
  double get stepSize;

  /// Output range for this axis.
  ScaleOutputExtent? get range;
}

abstract class MutableAxisElement<D> extends ImmutableAxisElement<D>
    implements LayoutView {
  MutableAxisElement(
      {this.tickProvider, TickFormatterElement<D>? tickFormatter, this.scale})
      : _defaultScale = scale,
        _defaultTickProvider = tickProvider,
        _defaultTickFormatter = tickFormatter,
        _tickFormatter = tickFormatter;
  static const primaryMeasureAxisId = 'primaryMeasureAxisId';
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';
  static const _autoViewportDefault = true;

  final MutableScaleElement<D>? _defaultScale;

  /// [ScaleElement] of this axis.
  MutableScaleElement<D>? scale;

  /// Previous [ScaleElement] of this axis, used to calculate tick animation.
  MutableScaleElement<D>? _previousScale;

  final TickStrategyElement<D>? _defaultTickProvider;

  /// [TickStrategyElement] for this axis.
  TickStrategyElement<D>? tickProvider;

  final TickFormatterElement<D>? _defaultTickFormatter;

  TickFormatterElement<D>? _tickFormatter;

  set tickFormatter(TickFormatterElement<D>? formatter) {
    if (_tickFormatter != formatter) {
      _tickFormatter = formatter;
      _formatterValueCache.clear();
    }
  }

  /// [TickFormatterElement] for this axis.
  TickFormatterElement<D>? get tickFormatter => _tickFormatter;

  final _formatterValueCache = <D, String>{};

  /// [TickDrawStrategy] for this axis.
  TickDrawStrategy<D>? tickDrawStrategy;

  /// [AxisOrientation] for this axis.
  AxisOrientation? axisOrientation;

  ChartContext? context;

  /// If the output range should be reversed.
  bool reverseOutputRange = false;

  /// Configures whether the viewport should be reset back to default values
  /// when the domain is reset.
  ///
  /// This should generally be disabled when the viewport will be managed
  /// externally, e.g. from pan and zoom behaviors.
  bool autoViewport = _autoViewportDefault;

  /// If the axis line should always be drawn.
  bool? forceDrawAxisLine;

  /// If true, do not allow axis to be modified.
  ///
  /// Ticks (including their location) are not updated.
  /// Viewport changes not allowed.
  bool lockAxis = false;

  /// Ticks provided by the tick provider.
  List<TickElement<D>>? _providedTicks;

  /// Ticks used by the axis for drawing.
  final _axisTicks = <AxisTicksElement<D>>[];

  Rect? _componentBounds;
  late Rect? _drawAreaBounds;

  /// Order for chart layout painting.
  ///
  /// In general, domain axes should be drawn on top of measure axes to ensure
  /// that the domain axis line appears on top of any measure axis grid lines.
  int layoutPaintOrder = LayoutViewPaintOrder.measureAxis;

  /// If true, a collision has occurred between ticks on this axis.
  bool hasTickCollision = false;

  @protected
  MutableScaleElement<D>? get mutableScale => scale;

  /// Rangeband for this axis.
  @override
  double get rangeBand => scale!.rangeBand;

  @override
  double get stepSize => scale!.stepSize;

  @override
  ScaleOutputExtent? get range => scale!.range;

  void setRangeBandConfig(RangeBandConfig rangeBandConfig) {
    mutableScale!.rangeBandConfig = rangeBandConfig;
  }

  /// For bars to be renderer properly the RangeBandConfig must be set and
  /// type must not be RangeBandType.none.
  bool get hasValidBarChartRangeBandConfig =>
      (mutableScale?.rangeBandConfig.type ?? RangeBandType.none) !=
      RangeBandType.none;

  void addDomainValue(D domain) {
    if (lockAxis) {
      return;
    }

    scale!.addDomain(domain);
  }

  void resetDefaultConfiguration() {
    forceDrawAxisLine = null;
    autoViewport = _autoViewportDefault;
    scale = _defaultScale;
    _tickFormatter = _defaultTickFormatter;
    tickProvider = _defaultTickProvider;
  }

  void resetDomains() {
    if (lockAxis) {
      return;
    }

    // If the series list changes, clear the cache.
    //
    // There are cases where tick formatter has not "changed", but if measure
    // formatter provided to the tick formatter uses a closure value, the
    // formatter cache needs to be cleared.
    //
    // This type of use case for the measure formatter surfaced where the series
    // list also changes. So this is a round about way to also clear the
    // tick formatter cache.
    //
    // TODO: Measure formatter should be changed from a typedef to
    // a concrete class to force users to create a new tick formatter when
    // formatting is different, so we can recognize when the tick formatter is
    // changed and then clear cache accordingly.
    //
    // Remove this when bug above is fixed, and verify it did not cause
    // regression for b/110371453.
    _formatterValueCache.clear();

    final scale = this.scale!;
    scale.resetDomain();
    reverseOutputRange = false;

    if (autoViewport) {
      scale.resetViewportSettings();
    }

    // TODO: Reset rangeband and step size when we port over config
    //scale.rangeBandConfig = get range band config
    //scale.stepSizeConfig = get step size config
  }

  @override
  double? getLocation(D? domain) {
    const epsilon = 2e-10;
    if (domain != null) {
      final scale = this.scale!;
      final range = scale.range!;

      final domainLocation = scale[domain]!.toDouble();

      // If domain location is outside of scale range but only outside by less
      // than epsilon, correct the potential mislocation caused by floating
      // point computation by moving it inside of scale range.
      if (domainLocation > range.max && domainLocation - epsilon < range.max) {
        return domainLocation - epsilon;
      } else if (domainLocation < range.min &&
          domainLocation + epsilon > range.min) {
        return domainLocation + epsilon;
      }
      return domainLocation;
    }
    return null;
  }

  @override
  D getDomain(double location) => scale!.reverse(location);

  @override
  int compareDomainValueToViewport(D domain) {
    return scale!.compareDomainValueToViewport(domain);
  }

  void setOutputRange(double start, double end) {
    scale!.range = ScaleOutputExtent(start, end);
  }

  /// Request update ticks from tick provider and update the painted ticks.
  void updateTicks() {
    _updateProvidedTicks();
    if (_componentBounds != null) {
      _updateProvidedTickWidth(
        _componentBounds!.width,
        _componentBounds!.height,
      );
    }
    _updateAxisTicks();
  }

  /// Request ticks from tick provider.
  void _updateProvidedTicks() {
    if (lockAxis) {
      return;
    }

    assert(
      graphicsFactory != null,
      'Axis<D>.graphicsFactory must be set first',
    );
    assert(
      tickDrawStrategy != null,
      'Axis<D>.tickDrawStrategy must be set first',
    );

    // TODO: Ensure that tick providers take manually configured
    // viewport settings into account, so that we still get the right number.
    _providedTicks = tickProvider!.getTicks(
      context: context,
      graphicsFactory: graphicsFactory!,
      scale: scale!,
      formatter: tickFormatter!,
      formatterValueCache: _formatterValueCache,
      tickDrawStrategy: tickDrawStrategy!,
      orientation: axisOrientation,
      viewportExtensionEnabled: autoViewport,
    );

    hasTickCollision = tickDrawStrategy!
        .collides(_providedTicks, axisOrientation)
        .ticksCollide;
  }

  /// Updates the current provided tick labels with a max width.
  void _updateProvidedTickWidth(double maxWidth, double maxHeight) {
    if (axisOrientation != null) {
      tickDrawStrategy!.updateTickWidth(
        _providedTicks!,
        maxWidth,
        maxHeight,
        axisOrientation!,
        collision: hasTickCollision,
      );
    }
  }

  /// Updates the ticks that are actually used for drawing.
  void _updateAxisTicks() {
    if (lockAxis) {
      return;
    }

    final providedTicks = List.of(_providedTicks ?? <TickElement<D>>[]);

    final scale = this.scale!;

    for (final animatedTick in _axisTicks) {
      final tick =
          providedTicks.firstWhereOrNull((t) => t.value == animatedTick.value);

      if (tick != null) {
        // Swap out the text element only if the settings are different.
        // This prevents a costly new TextPainter in Flutter.
        if (!TextElement.elementSettingsSame(
          animatedTick.textElement!,
          tick.textElement!,
        )) {
          animatedTick.textElement = tick.textElement;
        }
        final newTarget = scale[tick.value]?.toDouble();
        if (scale.isRangeValueWithinViewport(newTarget!)) {
          // Update target for all existing ticks
          animatedTick.setNewTarget(newTarget);
        } else {
          // Animate out ticks that are outside the viewport.
          animatedTick.animateOut(animatedTick.location);
        }
        providedTicks.remove(tick);
      } else {
        // Animate out ticks that do not exist any more.
        animatedTick.animateOut(scale[animatedTick.value]!.toDouble());
      }
    }

    // Add new ticks
    for (final tick in providedTicks) {
      AxisTicksElement<D> animatedTick;
      if (tick is RangeTickElement<D>) {
        animatedTick = RangeAxisTicks<D>(tick);
      } else {
        animatedTick = AxisTicksElement<D>(tick);
      }
      if (scale.isRangeValueWithinViewport(animatedTick.location!)) {
        if (_previousScale != null) {
          animatedTick.animateInFrom(_previousScale![tick.value]!.toDouble());
        }
        _axisTicks.add(animatedTick);
      }
    }

    _axisTicks.sort();

    // Save a copy of the current scale to be used as the previous scale when
    // ticks are updated.
    _previousScale = scale.copy();
  }

  /// Configures the zoom and translate.
  ///
  /// [viewportScale] is the zoom factor to use, likely >= 1.0 where 1.0 maps
  /// the complete data extents to the output range, and 2.0 only maps half the
  /// data to the output range.
  ///
  /// [viewportTranslate] is the translate/pan to use in pixel units,
  /// likely <= 0 which shifts the start of the data before the edge of the
  /// chart giving us a pan.
  ///
  /// [drawAreaWidth] is the width of the draw area for the series data in pixel
  /// units, at minimum viewport scale level (1.0). When provided,
  /// [drawAreaHeight] is the height of the draw area for the series data in
  /// pixel units, at minimum viewport scale level (1.0). When provided,
  /// [viewportTranslate] will be clamped such that the axis cannot be panned
  /// beyond the bounds of the data.
  void setViewportSettings(
    double viewportScale,
    double viewportTranslate, {
    double? drawAreaWidth,
    double? drawAreaHeight,
  }) {
    // Don't let the viewport be panned beyond the bounds of the data.
    final clampedViewportTranslate = _clampTranslate(
      viewportScale,
      viewportTranslate,
      drawAreaWidth: drawAreaWidth,
      drawAreaHeight: drawAreaHeight,
    );

    scale!.setViewportSettings(viewportScale, clampedViewportTranslate);
  }

  /// Returns the current viewport scale.
  ///
  /// A scale of 1.0 would map the data directly to the output range, while a
  /// value of 2.0 would map the data to an output of double the range so you
  /// only see half the data in the viewport.  This is the equivalent to
  /// zooming.  Its value is likely >= 1.0.
  double get viewportScalingFactor => scale!.viewportScalingFactor;

  /// Returns the current pixel viewport offset
  ///
  /// The translate is used by the scale function when it applies the scale.
  /// This is the equivalent to panning.  Its value is likely <= 0 to pan the
  /// data to the left.
  double get viewportTranslate => scale!.viewportTranslate;

  /// Clamps a possible change in domain translation to fit within the range of
  /// the data.
  double _clampTranslate(
    double viewportScalingFactor,
    double viewportTranslate, {
    double? drawAreaWidth,
    double? drawAreaHeight,
  }) {
    if (isVertical) {
      if (drawAreaHeight == null) {
        return viewportTranslate;
      }
      // Bound the viewport translate to the range of the data.
      final maxPositiveTranslate =
          (drawAreaHeight * viewportScalingFactor) - drawAreaHeight;

      viewportTranslate = max(min(viewportTranslate, maxPositiveTranslate), 0);
    } else {
      if (drawAreaWidth == null) {
        return viewportTranslate;
      }
      // Bound the viewport translate to the range of the data.
      final maxNegativeTranslate =
          -1.0 * ((drawAreaWidth * viewportScalingFactor) - drawAreaWidth);

      viewportTranslate = min(max(viewportTranslate, maxNegativeTranslate), 0);
    }
    return viewportTranslate;
  }

  //
  // LayoutView methods.
  //

  @override
  GraphicsFactory? graphicsFactory;

  @override
  LayoutViewConfig get layoutConfig => LayoutViewConfig(
        paintOrder: layoutPaintOrder,
        position: _layoutPosition,
        positionOrder: LayoutViewPositionOrder.axis,
      );

  /// Get layout position from axis orientation.
  LayoutPosition? get _layoutPosition {
    LayoutPosition? position;
    switch (axisOrientation) {
      case AxisOrientation.top:
        position = LayoutPosition.top;
        break;
      case AxisOrientation.right:
        position = LayoutPosition.right;
        break;
      case AxisOrientation.bottom:
        position = LayoutPosition.bottom;
        break;
      case AxisOrientation.left:
        position = LayoutPosition.left;
        break;
      case null:
        break;
    }

    return position;
  }

  /// The axis is rendered vertically.
  bool get isVertical =>
      axisOrientation == AxisOrientation.left ||
      axisOrientation == AxisOrientation.right;

  @override
  ViewMeasuredSizes measure(double maxWidth, double maxHeight) {
    return isVertical
        ? _measureVerticalAxis(maxWidth, maxHeight)
        : _measureHorizontalAxis(maxWidth, maxHeight);
  }

  ViewMeasuredSizes _measureVerticalAxis(double maxWidth, double maxHeight) {
    setOutputRange(maxHeight, 0);
    _updateProvidedTicks();

    return tickDrawStrategy!.measureVerticallyDrawnTicks(
      _providedTicks!,
      maxWidth,
      maxHeight,
      collision: hasTickCollision,
    );
  }

  ViewMeasuredSizes _measureHorizontalAxis(double maxWidth, double maxHeight) {
    setOutputRange(0, maxWidth);
    _updateProvidedTicks();

    return tickDrawStrategy!.measureHorizontallyDrawnTicks(
      _providedTicks!,
      maxWidth,
      maxHeight,
      collision: hasTickCollision,
    );
  }

  /// Layout this component.
  @override
  void layout(Rect componentBounds, Rect drawAreaBounds) {
    _componentBounds = componentBounds;
    _drawAreaBounds = drawAreaBounds;

    // Update the output range if it is different than the current one.
    // This is necessary because during the measure cycle, the output range is
    // set between zero and the max range available. On layout, the output range
    // needs to be updated to account of the offset of the axis view.

    final outputStart =
        isVertical ? componentBounds.bottom : componentBounds.left;
    final outputEnd = isVertical ? componentBounds.top : componentBounds.right;

    final outputRange = reverseOutputRange
        ? ScaleOutputExtent(outputEnd, outputStart)
        : ScaleOutputExtent(outputStart, outputEnd);

    final scale = this.scale!;
    if (scale.range != outputRange) {
      scale.range = outputRange;
    }

    _updateProvidedTicks();
    _updateProvidedTickWidth(_componentBounds!.width, _componentBounds!.height);
    // Update animated ticks in layout, because updateTicks are called during
    // measure and we don't want to update the animation at that time.
    _updateAxisTicks();
  }

  @override
  bool get isSeriesRenderer => false;

  @override
  Rect? get componentBounds => _componentBounds;

  bool get drawAxisLine {
    if (forceDrawAxisLine != null) {
      return forceDrawAxisLine!;
    }

    return tickDrawStrategy is SmallTickDrawStrategy;
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {
    if (animationPercent == 1.0) {
      _axisTicks.removeWhere((t) => t.markedForRemoval);
    }

    for (var i = 0; i < _axisTicks.length; i++) {
      final animatedTick = _axisTicks[i];
      tickDrawStrategy!.draw(
        canvas,
        animatedTick..setCurrentTick(animationPercent),
        orientation: axisOrientation!,
        axisBounds: _componentBounds!,
        collision: hasTickCollision,
        drawAreaBounds: _drawAreaBounds!,
        isFirst: i == 0,
        isLast: i == _axisTicks.length - 1,
      );
    }

    if (drawAxisLine) {
      tickDrawStrategy!
          .drawAxisLine(canvas, axisOrientation!, _componentBounds!);
    }
  }
}

class NumericAxisElement extends MutableAxisElement<num> {
  NumericAxisElement({TickStrategyElement<num>? tickProvider})
      : super(
          tickProvider: tickProvider ?? NumericTickProviderElement(),
          tickFormatter: NumericTickFormatterElement(),
          scale: LinearScaleElement(),
        );

  void setScaleViewport(NumericExtents viewport) {
    autoViewport = false;
    (scale as NumericScaleElement).viewportDomain = viewport;
  }
}

class OrdinalAxisElement extends MutableAxisElement<String> {
  OrdinalAxisElement({
    TickDrawStrategy<String>? tickDrawStrategy,
    TickStrategyElement<String>? tickProvider,
    TickFormatterElement<String>? tickFormatter,
  }) : super(
          tickProvider: tickProvider ?? const OrdinalTickProviderElement(),
          tickFormatter: tickFormatter ?? const OrdinalTickFormatterElement(),
          scale: SimpleOrdinalScaleElement(),
        ) {
    this.tickDrawStrategy = tickDrawStrategy;
  }

  void setScaleViewport(OrdinalViewport viewport) {
    autoViewport = false;
    (scale as OrdinalScaleElement)
        .setViewport(viewport.dataSize, viewport.startingDomain);
  }

  @override
  void layout(Rect componentBounds, Rect drawAreaBounds) {
    super.layout(componentBounds, drawAreaBounds);

    // We are purposely clearing the viewport starting domain and data size
    // post layout.
    //
    // Originally we set a flag in [setScaleViewport] to recalculate viewport
    // settings on next scale update and then reset the flag. This doesn't work
    // because chart's measure cycle provides different ranges to the scale,
    // causing the scale to update multiple times before it is finalized after
    // layout.
    //
    // By resetting the viewport after layout, we guarantee the correct range
    // was used to apply the viewport and behaviors that update the viewport
    // based on translate and scale changes will not be affected (pan/zoom).
    (scale as OrdinalScaleElement).setViewport(null, null);
  }
}

/// Viewport to cover [dataSize] data points starting at [startingDomain] value.
class OrdinalViewport extends Equatable {
  const OrdinalViewport(this.startingDomain, this.dataSize);
  final String startingDomain;
  final int dataSize;

  @override
  List<Object?> get props => [dataSize];
}

@visibleForTesting
class AxisTester<D> {
  AxisTester(this._axis);
  final MutableAxisElement<D> _axis;

  List<AxisTicksElement<D>> get axisTicks => _axis._axisTicks;

  MutableScaleElement<D>? get scale => _axis.scale;

  List<D> get axisValues => axisTicks.map((t) => t.value).toList();
}
