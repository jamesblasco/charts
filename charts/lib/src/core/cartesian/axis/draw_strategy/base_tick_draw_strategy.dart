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

import 'package:charts/charts.dart';
import 'package:charts/core.dart';
import 'package:flutter/material.dart';

@immutable
abstract class BaseAxisDecoration<D> extends AxisDecoration<D> {
  const BaseAxisDecoration({
    this.labelStyle,
    this.labelAnchor,
    this.labelJustification,
    this.labelOffsetFromAxis,
    this.labelCollisionOffsetFromAxis,
    this.labelOffsetFromTick,
    this.labelCollisionOffsetFromTick,
    this.minimumPaddingBetweenLabels,
    this.labelRotation,
    this.labelCollisionRotation,
    this.axisLineStyle,
  });
  final TextStyle? labelStyle;
  final TickLabelAnchor? labelAnchor;
  final TickLabelJustification? labelJustification;

  /// Distance from the axis line in px.
  final double? labelOffsetFromAxis;

  /// Distance from the axis line in px when a collision between ticks has
  /// occurred.
  final double? labelCollisionOffsetFromAxis;

  /// Absolute distance from the tick to the text if using start/end
  final double? labelOffsetFromTick;

  /// Absolute distance from the tick to the text when a collision between ticks
  /// has occurred.
  final double? labelCollisionOffsetFromTick;

  final double? minimumPaddingBetweenLabels;

  /// Angle of rotation for tick labels, in degrees. When set to a non-zero
  /// value, all labels drawn for this axis will be rotated.
  final double? labelRotation;

  /// Angle of rotation for tick labels, in degrees when a collision between
  /// ticks has occurred.
  final double? labelCollisionRotation;

  final LineStyle? axisLineStyle;

  @override
  List<Object?> get props => [
        labelStyle,
        labelAnchor,
        labelJustification,
        labelOffsetFromAxis,
        labelCollisionOffsetFromAxis,
        labelOffsetFromTick,
        labelCollisionOffsetFromTick,
        minimumPaddingBetweenLabels,
        labelRotation,
        labelCollisionRotation,
        axisLineStyle,
      ];
}

/// Base strategy that draws tick labels and checks for label collisions.
abstract class BaseTickDrawStrategy<D> implements TickDrawStrategy<D> {
  BaseTickDrawStrategy(
    this.chartContext,
    this.graphicsFactory, {
    TextStyle? labelStyleSpec,
    LineStyle? axisLineStyle,
    TickLabelAnchor? labelAnchor,
    TickLabelJustification? labelJustification,
    double? labelOffsetFromAxis,
    double? labelCollisionOffsetFromAxis,
    double? labelOffsetFromTick,
    double? labelCollisionOffsetFromTick,
    double? minimumPaddingBetweenLabels,
    double? labelRotation,
    double? labelCollisionRotation,
  })  : labelStyle = graphicsFactory
            .createTextPaint()
            .merge(
              TextStyle(
                color: StyleFactory.style.tickColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            )
            .merge(labelStyleSpec),
        axisLineStyle = graphicsFactory
            .createLinePaint()
            .copyWith(color: labelStyleSpec?.color)
            .merge(axisLineStyle),
        _defaultTickLabelAnchor = labelAnchor ?? TickLabelAnchor.centered,
        tickLabelJustification =
            labelJustification ?? TickLabelJustification.inside,
        _rotateOnCollision = labelCollisionRotation != null,
        minimumPaddingBetweenLabels = minimumPaddingBetweenLabels ?? 50,
        _labelDefaultOffsetFromAxis = labelOffsetFromAxis ?? 5,
        _labelDefaultOffsetFromTick = labelOffsetFromTick ?? 5,
        _labelDefaultRotation = labelRotation ?? 0,
        _labelCollisionOffsetFromAxis = labelCollisionOffsetFromAxis ?? 5,
        _labelCollisionOffsetFromTick = labelCollisionOffsetFromTick ?? 5,
        _labelCollisionRotation = labelCollisionRotation ?? 0;
  static const _labelSplitPattern = '\n';
  static const multiLineLabelPadding = 2;

  static double _degToRad(double deg) => deg * (pi / 180.0);

  final ChartContext chartContext;
  final GraphicsFactory graphicsFactory;

  final LineStyle axisLineStyle;
  TextStyle labelStyle;
  TickLabelJustification tickLabelJustification;
  final TickLabelAnchor _defaultTickLabelAnchor;
  final double _labelDefaultOffsetFromAxis;
  final double _labelCollisionOffsetFromAxis;
  final double _labelDefaultOffsetFromTick;
  final double _labelCollisionOffsetFromTick;
  final double _labelDefaultRotation;
  final double _labelCollisionRotation;
  final bool _rotateOnCollision;

  double minimumPaddingBetweenLabels;

  double labelRotation({required bool collision}) =>
      collision && _rotateOnCollision
          ? _labelCollisionRotation
          : _labelDefaultRotation;

  double labelOffsetFromAxis({required bool collision}) =>
      collision && _rotateOnCollision
          ? _labelCollisionOffsetFromAxis
          : _labelDefaultOffsetFromAxis;

  double labelOffsetFromTick({required bool collision}) =>
      collision && _rotateOnCollision
          ? _labelCollisionOffsetFromTick
          : _labelDefaultOffsetFromTick;

  TickLabelAnchor tickLabelAnchor({required bool collision}) =>
      collision && _rotateOnCollision
          ? TickLabelAnchor.after
          : _defaultTickLabelAnchor;

  @override
  void decorateTicks(List<TickElement<D>> ticks) {
    for (final tick in ticks) {
      final textElement = tick.textElement;
      if (textElement == null) {
        continue;
      }

      // If no style at all, set the default style.
      if (textElement.textStyle == null) {
        textElement.textStyle = labelStyle;
      } else {
        // Fill in whatever is missing
        final textStyle = textElement.textStyle!;
        textElement.textStyle = textStyle.merge(labelStyle);
      }
    }
  }

  @override
  void updateTickWidth(
    List<TickElement<D>> ticks,
    double maxWidth,
    double maxHeight,
    AxisOrientation orientation, {
    bool collision = false,
  }) {
    final isVertical = orientation == AxisOrientation.right ||
        orientation == AxisOrientation.left;
    final rotationRelativeToAxis = labelRotation(collision: collision);
    final rotationRads =
        _degToRad(rotationRelativeToAxis - (isVertical ? 90 : 0)).abs();
    final availableSpace = (isVertical ? maxWidth : maxHeight) -
        labelOffsetFromAxis(collision: collision);
    final maxTextWidth =
        sin(rotationRads) == 0 ? null : availableSpace / sin(rotationRads);

    for (final tick in ticks) {
      if (maxTextWidth != null) {
        tick.textElement!.maxWidth = maxTextWidth;
        tick.textElement!.maxWidthStrategy = MaxWidthStrategy.ellipsize;
      } else {
        tick.textElement!.maxWidth = null;
        tick.textElement!.maxWidthStrategy = null;
      }
    }
  }

  @override
  CollisionReport<D> collides(
    List<TickElement<D>>? ticks,
    AxisOrientation? orientation,
  ) {
    List<TickElement<D>>? effectiveTicks = ticks;
    // TODO: Collision analysis for rotated labels are not
    // supported yet.

    // If there are no ticks, they do not collide.
    if (effectiveTicks == null) {
      return CollisionReport(
        ticksCollide: false,
        ticks: effectiveTicks,
        alternateTicksUsed: false,
      );
    }

    final vertical = orientation == AxisOrientation.left ||
        orientation == AxisOrientation.right;

    effectiveTicks = [
      for (var tick in effectiveTicks)
        if (tick.location != null) tick,
    ];

    // First sort ticks by smallest location first (NOT sorted by value).
    // This allows us to only check if a tick collides with the previous tick.
    effectiveTicks.sort((a, b) => a.location!.compareTo(b.location!));

    var previousEnd = double.negativeInfinity;
    var collides = false;

    for (final tick in effectiveTicks) {
      final tickSize = tick.textElement?.measurement;
      final tickLocation = tick.location!;

      if (vertical) {
        final adjustedHeight =
            (tickSize?.verticalSliceWidth ?? 0.0) + minimumPaddingBetweenLabels;

        if (_defaultTickLabelAnchor == TickLabelAnchor.inside) {
          if (identical(tick, effectiveTicks.first)) {
            // Top most tick draws down from the location
            collides = false;
            previousEnd = tickLocation + adjustedHeight;
          } else if (identical(tick, effectiveTicks.last)) {
            // Bottom most tick draws up from the location
            collides = previousEnd > tickLocation - adjustedHeight;
            previousEnd = tickLocation;
          } else {
            // All other ticks is centered.
            final halfHeight = adjustedHeight / 2;
            collides = previousEnd > tickLocation - halfHeight;
            previousEnd = tickLocation + halfHeight;
          }
        } else {
          collides = previousEnd > tickLocation;
          previousEnd = tickLocation + adjustedHeight;
        }
      } else {
        // Use the text direction the ticks specified, unless the label anchor
        // is set to [TickLabelAnchor.inside]. When 'inside' is set, the text
        // direction is normalized such that the left most tick is drawn ltr,
        // the last tick is drawn rtl, and all other ticks are in the center.
        // This is not set until it is painted, so collision check needs to get
        // the value also.
        final textDirection = _normalizeHorizontalAnchor(
          _defaultTickLabelAnchor,
          chartContext.isRtl,
          identical(tick, effectiveTicks.first),
          identical(tick, effectiveTicks.last),
        );
        final adjustedWidth = (tickSize?.horizontalSliceWidth ?? 0.0) +
            minimumPaddingBetweenLabels;
        switch (textDirection) {
          case TextDirectionAligment.ltr:
            collides = previousEnd > tickLocation;
            previousEnd = tickLocation + adjustedWidth;
            break;
          case TextDirectionAligment.rtl:
            collides = previousEnd > (tickLocation - adjustedWidth);
            previousEnd = tickLocation;
            break;
          case TextDirectionAligment.center:
            final halfWidth = adjustedWidth / 2;
            collides = previousEnd > tickLocation - halfWidth;
            previousEnd = tickLocation + halfWidth;

            break;
        }
      }

      if (collides) {
        return CollisionReport(
          ticksCollide: true,
          ticks: effectiveTicks,
          alternateTicksUsed: false,
        );
      }
    }

    return CollisionReport(
      ticksCollide: false,
      ticks: effectiveTicks,
      alternateTicksUsed: false,
    );
  }

  @override
  ViewMeasuredSizes measureVerticallyDrawnTicks(
    List<TickElement<D>> ticks,
    double maxWidth,
    double maxHeight, {
    bool collision = false,
  }) {
    // TODO: Add spacing to account for the distance between the
    // text and the axis baseline (even if it isn't drawn).

    final maxHorizontalSliceWidth =
        ticks.fold<double>(0.0, (double prevMax, tick) {
      final labelElements = splitLabel(tick.textElement!);

      return max(
        prevMax,
        calculateWidthForRotatedLabel(
              labelRotation(collision: collision),
              getLabelHeight(labelElements),
              getLabelWidth(labelElements),
            ) +
            labelOffsetFromAxis(collision: collision),
      );
    });

    return ViewMeasuredSizes(
      preferredWidth: maxHorizontalSliceWidth,
      preferredHeight: maxHeight,
    );
  }

  @override
  ViewMeasuredSizes measureHorizontallyDrawnTicks(
    List<TickElement<D>> ticks,
    double maxWidth,
    double maxHeight, {
    bool collision = false,
  }) {
    final maxVerticalSliceWidth = ticks.fold<double>(0, (double prevMax, tick) {
      final labelElements = splitLabel(tick.textElement!);

      return max(
        prevMax,
        calculateHeightForRotatedLabel(
          labelRotation(collision: collision),
          getLabelHeight(labelElements),
          getLabelWidth(labelElements),
        ),
      );
    }).round();

    return ViewMeasuredSizes(
      preferredWidth: maxWidth,
      preferredHeight: min(
        maxHeight,
        maxVerticalSliceWidth + labelOffsetFromAxis(collision: collision),
      ),
    );
  }

  @override
  void drawAxisLine(
    ChartCanvas canvas,
    AxisOrientation orientation,
    Rect axisBounds,
  ) {
    Offset start;
    Offset end;

    switch (orientation) {
      case AxisOrientation.top:
        start = axisBounds.bottomLeft;
        end = axisBounds.bottomRight;
        break;
      case AxisOrientation.bottom:
        start = axisBounds.topLeft;
        end = axisBounds.topRight;
        break;
      case AxisOrientation.right:
        start = axisBounds.topLeft;
        end = axisBounds.bottomLeft;
        break;
      case AxisOrientation.left:
        start = axisBounds.topRight;
        end = axisBounds.bottomRight;
        break;
    }

    canvas.drawLine(
      points: [start, end],
      fill: axisLineStyle.color,
      stroke: axisLineStyle.color,
      strokeWidth: axisLineStyle.strokeWidth,
      dashPattern: axisLineStyle.dashPattern,
    );
  }

  // TODO: Why is drawAreaBounds required when it is unused?
  @protected
  void drawLabel(
    ChartCanvas canvas,
    TickElement<D> tick, {
    required AxisOrientation orientation,
    required Rect axisBounds,
    required Rect? drawAreaBounds,
    required bool isFirst,
    required bool isLast,
    bool collision = false,
  }) {
    final location = tick.location ?? 0;
    final labelOffset = tick.labelOffset ?? 0;
    final isRtl = chartContext.isRtl;
    final labelElements = splitLabel(tick.textElement!);
    final labelHeight = getLabelHeight(labelElements);
    var multiLineLabelOffset = 0;

    for (final line in labelElements) {
      var x = 0.0;
      var y = 0.0;

      if (orientation == AxisOrientation.bottom ||
          orientation == AxisOrientation.top) {
        y = orientation == AxisOrientation.bottom
            ? axisBounds.top + labelOffsetFromAxis(collision: collision)
            : axisBounds.bottom -
                (labelHeight.toInt() - multiLineLabelOffset) -
                labelOffsetFromAxis(collision: collision);

        final direction = _normalizeHorizontalAnchor(
          tickLabelAnchor(collision: collision),
          isRtl,
          isFirst,
          isLast,
        );

        line.textDirection = direction;

        switch (direction) {
          case TextDirectionAligment.rtl:
            x = location +
                labelOffsetFromTick(collision: collision) +
                labelOffset;
            break;
          case TextDirectionAligment.ltr:
            x = location -
                labelOffsetFromTick(collision: collision) -
                labelOffset;
            break;
          case TextDirectionAligment.center:
            x = location - labelOffset;
            break;
        }
      } else {
        if (orientation == AxisOrientation.left) {
          if (tickLabelJustification == TickLabelJustification.inside) {
            x = axisBounds.right - labelOffsetFromAxis(collision: collision);
            line.textDirection = TextDirectionAligment.rtl;
          } else {
            x = axisBounds.left;
            line.textDirection = TextDirectionAligment.ltr;
          }
        } else {
          // orientation == right
          if (tickLabelJustification == TickLabelJustification.inside) {
            x = axisBounds.left + labelOffsetFromAxis(collision: collision);
            line.textDirection = TextDirectionAligment.ltr;
          } else {
            x = axisBounds.right;
            line.textDirection = TextDirectionAligment.rtl;
          }
        }

        switch (normalizeVerticalAnchor(
          tickLabelAnchor(collision: collision),
          isFirst,
          isLast,
        )) {
          case _PixelVerticalDirection.over:
            y = location -
                (labelHeight - multiLineLabelOffset) -
                labelOffsetFromTick(collision: collision) -
                labelOffset;
            break;
          case _PixelVerticalDirection.under:
            y = location +
                labelOffsetFromTick(collision: collision) +
                labelOffset;
            break;
          case _PixelVerticalDirection.center:
            y = location - labelHeight / 2 + labelOffset;
            break;
        }
      }
      canvas.drawText(
        line,
        x,
        y + multiLineLabelOffset,
        rotation: _degToRad(labelRotation(collision: collision).toDouble()),
      );
      multiLineLabelOffset +=
          multiLineLabelPadding + line.measurement.verticalSliceWidth.round();
    }
  }

  TextDirectionAligment _normalizeHorizontalAnchor(
    TickLabelAnchor anchor,
    bool isRtl,
    bool isFirst,
    bool isLast,
  ) {
    switch (anchor) {
      case TickLabelAnchor.before:
        return isRtl ? TextDirectionAligment.ltr : TextDirectionAligment.rtl;
      case TickLabelAnchor.after:
        return isRtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
      case TickLabelAnchor.inside:
        if (isFirst) {
          return TextDirectionAligment.ltr;
        }
        if (isLast) {
          return TextDirectionAligment.rtl;
        }
        return TextDirectionAligment.center;
      case TickLabelAnchor.centered:
        return TextDirectionAligment.center;
    }
  }

  @protected
  _PixelVerticalDirection normalizeVerticalAnchor(
    TickLabelAnchor anchor,
    bool isFirst,
    bool isLast,
  ) {
    switch (anchor) {
      case TickLabelAnchor.before:
        return _PixelVerticalDirection.under;
      case TickLabelAnchor.after:
        return _PixelVerticalDirection.over;
      case TickLabelAnchor.inside:
        if (isFirst) {
          return _PixelVerticalDirection.over;
        }
        if (isLast) {
          return _PixelVerticalDirection.under;
        }
        return _PixelVerticalDirection.center;
      case TickLabelAnchor.centered:
      default:
        return _PixelVerticalDirection.center;
    }
  }

  /// Returns the width of a rotated labels on a domain axis.
  double calculateWidthForRotatedLabel(
    double rotation,
    double labelHeight,
    double labelLength,
  ) {
    if (rotation == 0) return labelLength;
    final rotationRadian = _degToRad(rotation.toDouble());

    // Imagine a right triangle with a base that is parallel to the axis
    // baseline. The side of this triangle that is perpendicular to the baseline
    // is the height of the axis we wish to calculate. The hypotenuse of the
    // triangle is the given length of the tick labels, labelLength. The angle
    // between the perpendicular line and the hypotenuse (the tick label) is 90
    // - the label rotation angle, since the tick label transformation is
    // applied relative to the axis baseline. Given this triangle, we can
    // calculate the height of the axis by using the cosine of this angle.

    // The triangle assumes a zero-height line for the labels, but the actual
    // rendered text will be drawn above and below this center line. To account
    // for this, extend the label length by using a triangle with half the
    // height of the label.
    labelLength += labelHeight / 2.0 * tan(rotationRadian);

    // To compute the label width, we need the angle between the label and a
    // line perpendicular to the axis baseline, in radians.
    return labelLength * cos(rotationRadian);
  }

  /// Returns the height of a rotated labels on a domain axis.
  double calculateHeightForRotatedLabel(
    double rotation,
    double labelHeight,
    double labelLength,
  ) {
    if (rotation == 0) return labelHeight;
    final rotationRadian = _degToRad(rotation.toDouble());

    // Imagine a right triangle with a base that is parallel to the axis
    // baseline. The side of this triangle that is perpendicular to the baseline
    // is the height of the axis we wish to calculate. The hypotenuse of the
    // triangle is the given length of the tick labels, labelLength. The angle
    // between the perpendicular line and the hypotenuse (the tick label) is 90
    // - the label rotation angle, since the tick label transformation is
    // applied relative to the axis baseline. Given this triangle, we can
    // calculate the height of the axis by using the cosine of this angle.

    // The triangle assumes a zero-height line for the labels, but the actual
    // rendered text will be drawn above and below this center line. To account
    // for this, extend the label length by using a triangle with half the
    // height of the label.
    labelLength += labelHeight / 2.0 * tan(rotationRadian);

    // To compute the label height, we need the angle between the label and a
    // line perpendicular to the axis baseline, in radians.
    final angle = pi / 2.0 - rotationRadian.abs();
    return max(labelHeight, labelLength * cos(angle));
  }

  /// The [wholeLabel] is split into constituent chunks if it is multiline.
  List<TextElement> splitLabel(TextElement wholeLabel) => wholeLabel.text
      .split(_labelSplitPattern)
      .map(
        (line) => (graphicsFactory.createTextElement(line.trim())
          ..textStyle = wholeLabel.textStyle),
      )
      .toList();

  /// The width of the label (handles labels spanning multiple lines).
  ///
  /// If the label spans multiple lines then it returns the width of the
  /// longest line.
  double getLabelWidth(Iterable<TextElement> labelElements) => labelElements
      .map((line) => line.measurement.horizontalSliceWidth)
      .reduce(max);

  /// The height of the label (handles labels spanning multiple lines).
  double getLabelHeight(Iterable<TextElement> labelElements) {
    if (labelElements.isEmpty) return 0;
    final textHeight = labelElements.first.measurement.verticalSliceWidth;
    final numLines = labelElements.length;
    return (textHeight * numLines) + (multiLineLabelPadding * (numLines - 1));
  }
}

enum _PixelVerticalDirection {
  over,
  center,
  under,
}
