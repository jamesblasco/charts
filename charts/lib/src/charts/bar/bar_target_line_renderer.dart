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

import 'dart:math' show Point, Rectangle, max, min;
import 'package:charts/charts/bar.dart';

/// Renders series data as a series of bar target lines.
///
/// Usually paired with a BarRenderer to display target metrics alongside actual
/// metrics.
class BarTargetLineRenderer<D> extends BaseBarRenderer<D,
    _BarTargetLineRendererElement, _AnimatedBarTargetLine<D>> {
  factory BarTargetLineRenderer({
    BarTargetLineRendererConfig<D>? config,
    String? rendererId,
  }) {
    config ??= BarTargetLineRendererConfig<D>();
    rendererId ??= 'barTargetLine';
    return BarTargetLineRenderer._internal(
      config: config,
      rendererId: rendererId,
    );
  }

  BarTargetLineRenderer._internal({
    required BarTargetLineRendererConfig<D> super.config,
    required super.rendererId,
  })  : _barGroupInnerPaddingPx = config.barGroupInnerPaddingPx,
        super(
          layoutPaintOrder:
              config.layoutPaintOrder ?? LayoutViewPaintOrder.barTargetLine,
        );

  /// If we are grouped, use this spacing between the bars in a group.
  final int _barGroupInnerPaddingPx;

  /// Standard color for all bar target lines.
  final _color = const Color.fromARGB(153, 0, 0, 0);

  @override
  void configureSeries(List<MutableSeries<D>> seriesList) {
    for (final series in seriesList) {
      series.colorFn ??= (_) => _color;
      series.fillColorFn ??= (_) => _color;

      // Fill in missing seriesColor values with the color of the first datum in
      // the series. Note that [Series.colorFn] should always return a color.
      if (series.seriesColor == null) {
        try {
          series.seriesColor = series.colorFn!(0);
        } catch (exception) {
          series.seriesColor = _color;
        }
      }
    }
  }

  @override
  DatumDetails<D> addPositionToDetailsForSeriesDatum(
    DatumDetails<D> details,
    SeriesDatum<D> seriesDatum,
  ) {
    final series = details.series!;

    final domainAxis = series.getAttr(domainAxisKey) as ImmutableAxisElement<D>;
    final measureAxis =
        series.getAttr(measureAxisKey) as ImmutableAxisElement<num>;

    final barGroupIndex = series.getAttr(barGroupIndexKey)!;
    final previousBarGroupWeight = series.getAttr(previousBarGroupWeightKey);
    final barGroupWeight = series.getAttr(barGroupWeightKey);
    final allBarGroupWeights = series.getAttr(allBarGroupWeightsKey);
    final numBarGroups = series.getAttr(barGroupCountKey)!;

    final points = _getTargetLinePoints(
      details.domain,
      domainAxis,
      domainAxis.rangeBand.round(),
      config.maxBarWidthPx,
      details.measure,
      details.measureOffset!,
      measureAxis,
      barGroupIndex,
      previousBarGroupWeight,
      barGroupWeight,
      allBarGroupWeights,
      numBarGroups,
    );

    NullablePoint chartPosition;

    if (renderingVertically) {
      chartPosition = NullablePoint(
        (points[0].x + (points[1].x - points[0].x) / 2).toDouble(),
        points[0].y.toDouble(),
      );
    } else {
      chartPosition = NullablePoint(
        points[0].x.toDouble(),
        (points[0].y + (points[1].y - points[0].y) / 2).toDouble(),
      );
    }

    return DatumDetails.from(details, chartPosition: chartPosition);
  }

  @override
  _BarTargetLineRendererElement getBaseDetails(dynamic datum, int index) {
    final localConfig = config as BarTargetLineRendererConfig<D>;
    return _BarTargetLineRendererElement(
      roundEndCaps: localConfig.roundEndCaps,
    );
  }

  /// Generates an [_AnimatedBarTargetLine] to represent the previous and
  /// current state of one bar target line on the chart.
  @override
  _AnimatedBarTargetLine<D> makeAnimatedBar({
    required String key,
    required ImmutableSeries<D> series,
    dynamic datum,
    Color? color,
    List<int>? dashPattern,
    required _BarTargetLineRendererElement details,
    D? domainValue,
    required ImmutableAxisElement<D> domainAxis,
    required int domainWidth,
    num? measureValue,
    required num measureOffsetValue,
    required ImmutableAxisElement<num> measureAxis,
    double? measureAxisPosition,
    Color? fillColor,
    FillPatternType? fillPattern,
    required int barGroupIndex,
    double? previousBarGroupWeight,
    double? barGroupWeight,
    List<double>? allBarGroupWeights,
    required int numBarGroups,
    double? strokeWidthPx,
    bool? measureIsNull,
    bool? measureIsNegative,
  }) {
    return _AnimatedBarTargetLine(
      key: key,
      datum: datum,
      series: series,
      domainValue: domainValue,
    )..setNewTarget(
        makeBarRendererElement(
          color: color,
          details: details,
          dashPattern: dashPattern,
          domainValue: domainValue,
          domainAxis: domainAxis,
          domainWidth: domainWidth,
          measureValue: measureValue,
          measureOffsetValue: measureOffsetValue,
          measureAxisPosition: measureAxisPosition,
          measureAxis: measureAxis,
          fillColor: fillColor,
          fillPattern: fillPattern,
          strokeWidthPx: strokeWidthPx,
          barGroupIndex: barGroupIndex,
          previousBarGroupWeight: previousBarGroupWeight,
          barGroupWeight: barGroupWeight,
          allBarGroupWeights: allBarGroupWeights,
          numBarGroups: numBarGroups,
          measureIsNull: measureIsNull,
          measureIsNegative: measureIsNegative,
        ),
      );
  }

  /// Generates a [_BarTargetLineRendererElement] to represent the rendering
  /// data for one bar target line on the chart.
  @override
  _BarTargetLineRendererElement makeBarRendererElement({
    Color? color,
    List<int>? dashPattern,
    required _BarTargetLineRendererElement details,
    D? domainValue,
    required ImmutableAxisElement<D> domainAxis,
    required int domainWidth,
    num? measureValue,
    required num measureOffsetValue,
    required ImmutableAxisElement<num> measureAxis,
    double? measureAxisPosition,
    Color? fillColor,
    FillPatternType? fillPattern,
    double? strokeWidthPx,
    required int barGroupIndex,
    double? previousBarGroupWeight,
    double? barGroupWeight,
    List<double>? allBarGroupWeights,
    required int numBarGroups,
    bool? measureIsNull,
    bool? measureIsNegative,
  }) {
    return _BarTargetLineRendererElement(roundEndCaps: details.roundEndCaps)
      ..color = color
      ..dashPattern = dashPattern
      ..fillColor = fillColor
      ..fillPattern = fillPattern
      ..measureAxisPosition = measureAxisPosition
      ..strokeWidthPx = strokeWidthPx
      ..measureIsNull = measureIsNull
      ..measureIsNegative = measureIsNegative
      ..points = _getTargetLinePoints(
        domainValue,
        domainAxis,
        domainWidth,
        config.maxBarWidthPx,
        measureValue,
        measureOffsetValue,
        measureAxis,
        barGroupIndex,
        previousBarGroupWeight,
        barGroupWeight,
        allBarGroupWeights,
        numBarGroups,
      );
  }

  @override
  void paintBar(
    ChartCanvas canvas,
    double animationPercent,
    Iterable<_BarTargetLineRendererElement> barElements,
  ) {
    for (final bar in barElements) {
      // TODO: Combine common line attributes into
      // GraphicsFactory.lineStyle or similar.
      canvas.drawLine(
        clipBounds: drawBounds,
        points: bar.points,
        stroke: bar.color,
        roundEndCaps: bar.roundEndCaps,
        strokeWidthPx: bar.strokeWidthPx,
        dashPattern: bar.dashPattern,
      );
    }
  }

  /// Generates a set of points that describe a bar target line.
  List<Point<int>> _getTargetLinePoints(
    D? domainValue,
    ImmutableAxisElement<D> domainAxis,
    int domainWidth,
    int? maxBarWidthPx,
    num? measureValue,
    num measureOffsetValue,
    ImmutableAxisElement<num> measureAxis,
    int barGroupIndex,
    double? previousBarGroupWeight,
    double? barGroupWeight,
    List<double>? allBarGroupWeights,
    int numBarGroups,
  ) {
    // If no weights were passed in, default to equal weight per bar.
    if (barGroupWeight == null) {
      barGroupWeight = 1 / numBarGroups;
      previousBarGroupWeight = barGroupIndex * barGroupWeight;
    }

    final localConfig = config as BarTargetLineRendererConfig<D>;

    // Calculate how wide each bar target line should be within the group of
    // bar target lines. If we only have one series, or are stacked, then
    // barWidth should equal domainWidth.
    final spacingLoss = _barGroupInnerPaddingPx * (numBarGroups - 1);
    var desiredWidth = ((domainWidth - spacingLoss) / numBarGroups).round();

    if (maxBarWidthPx != null) {
      desiredWidth = min(desiredWidth, maxBarWidthPx);
      domainWidth = desiredWidth * numBarGroups + spacingLoss;
    }

    // If the series was configured with a weight pattern, treat the "max" bar
    // width as the average max width. The overall total width will still equal
    // max times number of bars, but this results in a nicer final picture.
    var barWidth = desiredWidth;
    if (allBarGroupWeights != null) {
      barWidth =
          (desiredWidth * numBarGroups * allBarGroupWeights[barGroupIndex])
              .floor();
    }
    // Get the overdraw boundaries.
    final overDrawOuterPx = localConfig.overDrawOuterPx;
    final overDrawPx = localConfig.overDrawPx;

    final overDrawStartPx = (barGroupIndex == 0) && overDrawOuterPx != null
        ? overDrawOuterPx
        : overDrawPx;

    final overDrawEndPx =
        (barGroupIndex == numBarGroups - 1) && overDrawOuterPx != null
            ? overDrawOuterPx
            : overDrawPx;

    // Flip bar group index for calculating location on the domain axis if RTL.
    final adjustedBarGroupIndex =
        isRtl ? numBarGroups - barGroupIndex - 1 : barGroupIndex;

    // Calculate the start and end of the bar target line, taking into account
    // accumulated padding for grouped bars.
    final num previousAverageWidth = adjustedBarGroupIndex > 0
        ? ((domainWidth - spacingLoss) *
                (previousBarGroupWeight! / adjustedBarGroupIndex))
            .round()
        : 0;

    final domainStart = (domainAxis.getLocation(domainValue)! -
            (domainWidth / 2) +
            (previousAverageWidth + _barGroupInnerPaddingPx) *
                adjustedBarGroupIndex -
            overDrawStartPx)
        .round();

    final domainEnd = domainStart + barWidth + overDrawStartPx + overDrawEndPx;

    measureValue = measureValue ?? 0;

    // Calculate measure locations. Stacked bars should have their
    // offset calculated previously.
    final measureStart =
        measureAxis.getLocation(measureValue + measureOffsetValue)!.round();

    List<Point<int>> points;
    if (renderingVertically) {
      points = [
        Point<int>(domainStart, measureStart),
        Point<int>(domainEnd, measureStart)
      ];
    } else {
      points = [
        Point<int>(measureStart, domainStart),
        Point<int>(measureStart, domainEnd)
      ];
    }
    return points;
  }

  @override
  Rectangle<int> getBoundsForBar(_BarTargetLineRendererElement bar) {
    final points = bar.points;
    assert(points.isNotEmpty);
    var top = points.first.y;
    var bottom = points.first.y;
    var left = points.first.x;
    var right = points.first.x;
    for (final point in points.skip(1)) {
      top = min(top, point.y);
      left = min(left, point.x);
      bottom = max(bottom, point.y);
      right = max(right, point.x);
    }
    return Rectangle<int>(left, top, right - left, bottom - top);
  }
}

class _BarTargetLineRendererElement extends BaseBarRendererElement {
  _BarTargetLineRendererElement({required this.roundEndCaps});

  _BarTargetLineRendererElement.clone(_BarTargetLineRendererElement super.other)
      : points = List.of(other.points),
        roundEndCaps = other.roundEndCaps,
        super.clone();
  late List<Point<int>> points;

  bool roundEndCaps;

  @override
  void updateAnimationPercent(
    BaseBarRendererElement previous,
    BaseBarRendererElement target,
    double animationPercent,
  ) {
    final localPrevious = previous as _BarTargetLineRendererElement;
    final localTarget = target as _BarTargetLineRendererElement;

    final previousPoints = localPrevious.points;
    final targetPoints = localTarget.points;

    late Point<int> lastPoint;

    int pointIndex;
    for (pointIndex = 0; pointIndex < targetPoints.length; pointIndex++) {
      final targetPoint = targetPoints[pointIndex];

      // If we have more points than the previous line, animate in the new point
      // by starting its measure position at the last known official point.
      Point<int> previousPoint;
      if (previousPoints.length - 1 >= pointIndex) {
        previousPoint = previousPoints[pointIndex];
        lastPoint = previousPoint;
      } else {
        previousPoint = Point<int>(targetPoint.x, lastPoint.y);
      }

      final x = ((targetPoint.x - previousPoint.x) * animationPercent) +
          previousPoint.x;

      final y = ((targetPoint.y - previousPoint.y) * animationPercent) +
          previousPoint.y;

      if (points.length - 1 >= pointIndex) {
        points[pointIndex] = Point<int>(x.round(), y.round());
      } else {
        points.add(Point<int>(x.round(), y.round()));
      }
    }

    // Removing extra points that don't exist anymore.
    if (pointIndex < points.length) {
      points.removeRange(pointIndex, points.length);
    }

    strokeWidthPx =
        ((localTarget.strokeWidthPx! - localPrevious.strokeWidthPx!) *
                animationPercent) +
            localPrevious.strokeWidthPx!;

    roundEndCaps = localTarget.roundEndCaps;

    super.updateAnimationPercent(previous, target, animationPercent);
  }
}

class _AnimatedBarTargetLine<D>
    extends BaseAnimatedBar<D, _BarTargetLineRendererElement> {
  _AnimatedBarTargetLine({
    required super.key,
    required super.datum,
    required super.series,
    required super.domainValue,
  });

  @override
  void animateElementToMeasureAxisPosition(BaseBarRendererElement target) {
    final localTarget = target as _BarTargetLineRendererElement;

    final newPoints = <Point<int>>[];
    for (var index = 0; index < localTarget.points.length; index++) {
      final targetPoint = localTarget.points[index];

      newPoints.add(
        Point<int>(targetPoint.x, localTarget.measureAxisPosition!.round()),
      );
    }
    localTarget.points = newPoints;
  }

  @override
  _BarTargetLineRendererElement clone(_BarTargetLineRendererElement bar) =>
      _BarTargetLineRendererElement.clone(bar);
}
