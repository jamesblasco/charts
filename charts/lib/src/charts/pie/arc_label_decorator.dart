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

import 'dart:math' show cos, min, sin, pi, Point, Rectangle;

import 'package:charts/charts.dart';
import 'package:charts/charts/pie.dart';
import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart' show immutable, protected;

/// Renders labels for arc renderers.
///
/// This decorator performs very basic label collision detection. If the y
/// position of a label positioned outside collides with the previously drawn
/// label (on the same side of the chart), then that label will be skipped.
class ArcLabelDecorator<D> extends ArcRendererDecorator<D> {
  ArcLabelDecorator({
    TextStyle? insideLabelStyleSpec,
    TextStyle? outsideLabelStyleSpec,
    ArcLabelLeaderLineStyle? leaderLineStyle,
    this.labelPosition = _defaultLabelPosition,
    this.labelPadding = _defaultLabelPadding,
    this.showLeaderLines = _defaultShowLeaderLines,
  })  : insideLabelStyleSpec = insideLabelStyleSpec ?? _defaultInsideLabelStyle,
        outsideLabelStyleSpec =
            outsideLabelStyleSpec ?? _defaultOutsideLabelStyle,
        leaderLineStyle = leaderLineStyle ?? _defaultLeaderLineStyle;
  // Default configuration
  static const _defaultLabelPosition = ArcLabelPosition.auto;
  static const _defaultLabelPadding = 5.0;
  static const _defaultInsideLabelStyle =
      TextStyle(fontSize: 12, color: Colors.white);
  static const _defaultOutsideLabelStyle =
      TextStyle(fontSize: 12, color: Colors.black);
  static final _defaultLeaderLineStyle = ArcLabelLeaderLineStyle(
    length: 20,
    thickness: 1,
    color: StyleFactory.style.arcLabelOutsideLeaderLine,
  );
  static const _defaultShowLeaderLines = true;

  /// Configures [TextStyle] for labels placed inside the arcs.
  final TextStyle insideLabelStyleSpec;

  /// Configures [TextStyle] for labels placed outside the arcs.
  final TextStyle outsideLabelStyleSpec;

  /// Configures [ArcLabelLeaderLineStyle] for leader lines for labels
  /// placed outside the arcs.
  final ArcLabelLeaderLineStyle leaderLineStyle;

  /// Configures where to place the label relative to the arcs.
  final ArcLabelPosition labelPosition;

  /// Space before and after the label text.
  final double labelPadding;

  /// Whether or not to draw leader lines for labels placed outside the arcs.
  final bool showLeaderLines;

  /// Render the labels on top of series data.
  @override
  final bool renderAbove = true;

  /// fields for collision detection.
  num? _previousOutsideLabelY;
  bool? _previousLabelLeftOfChart;

  @override
  void decorate(
    List<ArcRendererElementList<D>> arcElementsList,
    ChartCanvas canvas,
    GraphicsFactory graphicsFactory, {
    required Rect drawBounds,
    required double animationPercent,
    bool rtl = false,
  }) {
    // Only decorate the arcs when animation is at 100%.
    if (animationPercent != 1.0) {
      return;
    }

    // Create [TextStyle] from [TextStyle] to be used by all the elements.
    // The [GraphicsFactory] is needed so it can't be created earlier.
    final insideLabelStyle =
        _getTextStyle(graphicsFactory, insideLabelStyleSpec);
    final outsideLabelStyle =
        _getTextStyle(graphicsFactory, outsideLabelStyleSpec);

    // Track the Y position of the previous outside label for collision
    // detection purposes.
    for (final arcElements in arcElementsList) {
      _previousOutsideLabelY = null;
      _previousLabelLeftOfChart = null;

      for (final element in arcElements.arcs) {
        final labelFn = element.series.labelAccessorFn;
        final datumIndex = element.index;
        final label = (labelFn != null) ? labelFn(datumIndex) : null;

        // If there are custom styles, use that instead of the default or the
        // style defined for the entire decorator.
        final datumInsideLabelStyle = _getDatumStyle(
          element.series.insideLabelStyleAccessorFn,
          datumIndex,
          graphicsFactory,
          defaultStyle: insideLabelStyle,
        );
        final datumOutsideLabelStyle = _getDatumStyle(
          element.series.outsideLabelStyleAccessorFn,
          datumIndex,
          graphicsFactory,
          defaultStyle: outsideLabelStyle,
        );

        // Skip calculation and drawing for this element if no label.
        if (label == null || label.isEmpty) {
          continue;
        }

        final arcAngle = element.endAngle - element.startAngle;

        final centerAngle = element.startAngle + (arcAngle / 2);

        final centerRadius = arcElements.innerRadius +
            ((arcElements.radius - arcElements.innerRadius) / 2);

        final outerPoint = Offset(
          arcElements.center.dx + arcElements.radius * cos(centerAngle),
          arcElements.center.dy + arcElements.radius * sin(centerAngle),
        );

        final bounds =
            Rect.fromPoints(arcElements.center, outerPoint);

        // Get space available inside and outside the arc.
        final totalPadding = labelPadding * 2;
        final insideArcWidth = min(
          ((arcAngle * 180 / pi) / 360) * (2 * pi * centerRadius),
          (arcElements.radius - arcElements.innerRadius) - labelPadding,
        );

        final leaderLineLength = showLeaderLines ? leaderLineStyle.length : 0.0;

        final outsideArcWidth = (drawBounds.width / 2) -
            bounds.width -
            totalPadding -
            // Half of the leader line is drawn inside the arc
            leaderLineLength / 2;

        final labelElement = graphicsFactory.createTextElement(label)
          ..maxWidthStrategy = MaxWidthStrategy.ellipsize;

        final calculatedLabelPosition = calculateLabelPosition(
          labelElement,
          datumInsideLabelStyle,
          insideArcWidth,
          outsideArcWidth,
          element,
          labelPosition,
        );

        // Set the max width and text style.
        if (calculatedLabelPosition == ArcLabelPosition.inside) {
          labelElement.textStyle = datumInsideLabelStyle;
          labelElement.maxWidth = insideArcWidth;
        } else {
          // calculatedLabelPosition == LabelPosition.outside
          labelElement.textStyle = datumOutsideLabelStyle;
          labelElement.maxWidth = outsideArcWidth;
        }

        // Only calculate and draw label if there's actually space for the
        // label.
        if (labelElement.maxWidth! > 0) {
          // Calculate the start position of label based on [labelAnchor].
          if (calculatedLabelPosition == ArcLabelPosition.inside) {
            _drawInsideLabel(canvas, arcElements, labelElement, centerAngle);
          } else {
            final l = _drawOutsideLabel(
              canvas,
              drawBounds,
              arcElements,
              labelElement,
              centerAngle,
            );

            if (l != null) {
              updateCollisionDetectionParams(l);
            }
          }
        }
      }
    }
  }

  @protected
  ArcLabelPosition calculateLabelPosition(
    TextElement labelElement,
    TextStyle labelStyle,
    double insideArcWidth,
    double outsideArcWidth,
    ArcRendererElement arcRendererelement,
    ArcLabelPosition labelPosition,
  ) {
    if (labelPosition == ArcLabelPosition.auto) {
      // For auto, first try to fit the text inside the arc.
      labelElement.textStyle = labelStyle;

      // A label fits if the space inside the arc is >= outside arc or if the
      // length of the text fits and the space. This is because if the arc has
      // more space than the outside, it makes more sense to place the label
      // inside the arc, even if the entire label does not fit.
      return (insideArcWidth >= outsideArcWidth ||
              labelElement.measurement.horizontalSliceWidth < insideArcWidth)
          ? ArcLabelPosition.inside
          : ArcLabelPosition.outside;
    } else {
      return labelPosition;
    }
  }

  /// Helper function that converts [TextStyle] to [TextStyle].
  TextStyle _getTextStyle(
    GraphicsFactory graphicsFactory,
    TextStyle labelSpec,
  ) {
    return graphicsFactory
        .createTextPaint()
        .copyWith(color: Colors.black, fontSize: 12)
        .merge(labelSpec);
  }

  /// Helper function to get datum specific style
  TextStyle _getDatumStyle(
    AccessorFn<TextStyle>? labelFn,
    int? datumIndex,
    GraphicsFactory graphicsFactory, {
    required TextStyle defaultStyle,
  }) {
    final styleSpec = (labelFn != null) ? labelFn(datumIndex) : null;
    return (styleSpec != null)
        ? _getTextStyle(graphicsFactory, styleSpec)
        : defaultStyle;
  }

  /// Draws a label inside of an arc.
  void _drawInsideLabel(
    ChartCanvas canvas,
    ArcRendererElementList<D> arcElements,
    TextElement labelElement,
    double centerAngle,
  ) {
    // Center the label inside the arc.
    final labelRadius = arcElements.innerRadius +
        (arcElements.radius - arcElements.innerRadius) / 2;

    final labelX = arcElements.center.dx + labelRadius * cos(centerAngle);

    final labelY = arcElements.center.dy +
        labelRadius * sin(centerAngle) -
        insideLabelStyleSpec.fontSize! / 2;

    labelElement.textDirection = TextDirectionAligment.center;

    canvas.drawText(labelElement, labelX, labelY);
  }

  @protected
  void updateCollisionDetectionParams(List<Object> params) {
    // List destructuring.
    _previousLabelLeftOfChart = params[0] as bool;
    _previousOutsideLabelY = params[1] as double;
  }

  double getLabelRadius(ArcRendererElementList<D> arcElements) =>
      arcElements.radius + leaderLineStyle.length / 2;

  /// Draws a label outside of an arc.
  List<Object>? _drawOutsideLabel(
    ChartCanvas canvas,
    Rect drawBounds,
    ArcRendererElementList<D> arcElements,
    TextElement labelElement,
    double centerAngle,
  ) {
    final labelRadius = getLabelRadius(arcElements);

    final labelPoint = Offset(
      arcElements.center.dx + labelRadius * cos(centerAngle),
      arcElements.center.dy + labelRadius * sin(centerAngle),
    );

    // Use the label's chart quandrant to determine whether it's rendered to the
    // right or left.
    final centerAbs = centerAngle.abs() % (2 * pi);
    final labelLeftOfChart = pi / 2 < centerAbs && centerAbs < pi * 3 / 2;

    // Shift the label horizontally away from the center of the chart.
    var labelX = labelLeftOfChart
        ? labelPoint.dx - labelPadding
        : labelPoint.dx + labelPadding;

    // Shift the label up by the size of the font.
    final labelY = labelPoint.dy - outsideLabelStyleSpec.fontSize! / 2;

    // Outside labels should flow away from the center of the chart
    labelElement.textDirection = labelLeftOfChart
        ? TextDirectionAligment.rtl
        : TextDirectionAligment.ltr;

    // Skip this label if it collides with the previously drawn label.
    if (detectOutsideLabelCollision(
      labelY,
      labelLeftOfChart,
      _previousOutsideLabelY,
      _previousLabelLeftOfChart,
    )) {
      return null;
    }

    if (showLeaderLines) {
      final tailX = _drawLeaderLine(
        canvas,
        labelLeftOfChart,
        labelPoint,
        arcElements.radius,
        arcElements.center,
        centerAngle,
      );

      // Shift the label horizontally by the length of the leader line.
      labelX = labelX + tailX;

      labelElement.maxWidth = labelElement.maxWidth! - tailX.abs();
    }

    canvas.drawText(labelElement, labelX, labelY);

    // Return a structured list of values.
    return [labelLeftOfChart, labelY];
  }

  /// Detects whether the current outside label collides with the previous label.
  @protected
  bool detectOutsideLabelCollision(
    num labelY,
    bool labelLeftOfChart,
    num? previousOutsideLabelY,
    bool? previousLabelLeftOfChart,
  ) {
    var collides = false;

    // Given that labels are vertically centered, we can assume they will
    // collide if the current label's Y coordinate +/- the font size
    // crosses past the Y coordinate of the previous label drawn on the
    // same side of the chart.
    if (previousOutsideLabelY != null &&
        labelLeftOfChart == previousLabelLeftOfChart) {
      if (labelY > previousOutsideLabelY) {
        if (labelY - outsideLabelStyleSpec.fontSize! <= previousOutsideLabelY) {
          collides = true;
        }
      } else {
        if (labelY + outsideLabelStyleSpec.fontSize! >= previousOutsideLabelY) {
          collides = true;
        }
      }
    }

    return collides;
  }

  /// Draws a leader line for the current arc.
  double _drawLeaderLine(
    ChartCanvas canvas,
    bool labelLeftOfChart,
    Offset labelPoint,
    double radius,
    Offset arcCenterPoint,
    double centerAngle,
  ) {
    final tailX = (labelLeftOfChart ? -1 : 1) * leaderLineStyle.length;

    final leaderLineTailPoint = Offset(labelPoint.dx + tailX, labelPoint.dy);

    final centerRadius = radius - leaderLineStyle.length / 2;
    final leaderLineStartPoint = Offset(
      arcCenterPoint.dx + centerRadius * cos(centerAngle),
      arcCenterPoint.dy + centerRadius * sin(centerAngle),
    );

    canvas.drawLine(
      points: [
        leaderLineStartPoint,
        labelPoint,
        leaderLineTailPoint,
      ],
      stroke: leaderLineStyle.color,
      strokeWidth: leaderLineStyle.thickness,
    );

    return tailX;
  }
}

/// Configures where to place the label relative to the arcs.
enum ArcLabelPosition {
  /// Automatically try to place the label inside the arc first and place it on
  /// the outside of the space available outside the arc is greater than space
  /// available inside the arc.
  auto,

  /// Always place label on the outside.
  outside,

  /// Always place label on the inside.
  inside
}

/// Style configuration for leader lines.
@immutable
class ArcLabelLeaderLineStyle extends Equatable {
  const ArcLabelLeaderLineStyle({
    required this.color,
    required this.length,
    required this.thickness,
  });

  final Color color;
  final double length;
  final double thickness;

  @override
  List<Object?> get props => [color, thickness, length];
}
