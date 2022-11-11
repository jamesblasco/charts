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

import 'package:charts/charts/bar.dart';

/// Decorates bars with error whiskers.
///
/// Used to represent confidence intervals for bar charts.
class BarErrorDecorator<D> extends BarRendererDecorator<D> {
  BarErrorDecorator({
    this.strokeColor = _defaultStrokeColor,
    this.strokeWidth = _defaultStrokeWidth,
    this.endpointLength = _defaultEndpointLength,
    this.outlineWidth = _defaultOutlineWidth,
    this.outlineColor = _defaultOutlineColor,
  });
  static const Color _defaultStrokeColor = Colors.black;
  static const double _defaultStrokeWidth = 1;
  static const double _defaultEndpointLength = 16;

  static const Color _defaultOutlineColor = Colors.white;
  static const double _defaultOutlineWidth = 0;

  final double strokeWidth;
  final double endpointLength;
  final double outlineWidth;

  final Color strokeColor;
  final Color outlineColor;

  @override
  void decorate(
    Iterable<ImmutableBarRendererElement<D>> barElements,
    ChartCanvas canvas,
    GraphicsFactory graphicsFactory, {
    required Rectangle<num> drawBounds,
    required double animationPercent,
    required bool renderingVertically,
    bool rtl = false,
  }) {
    // Only decorate the bars when animation is at 100%.
    if (animationPercent != 1.0) {
      return;
    }

    for (final element in barElements) {
      final bounds = element.bounds!;
      final datumIndex = element.index;

      final series = element.series!;

      final measureLowerBoundFn = series.measureLowerBoundFn;
      final measureUpperBoundFn = series.measureUpperBoundFn;

      if (measureLowerBoundFn != null && measureUpperBoundFn != null) {
        final measureOffsetFn = series.measureOffsetFn!;
        final measureAxis =
            series.getAttr(measureAxisKey) as ImmutableAxisElement<num>;

        if (renderingVertically) {
          final startY = measureAxis.getLocation(
            (measureLowerBoundFn(datumIndex) ?? 0) +
                measureOffsetFn(datumIndex)!,
          )!;
          final endY = measureAxis.getLocation(
            (measureUpperBoundFn(datumIndex) ?? 0) +
                measureOffsetFn(datumIndex)!,
          )!;

          if (startY != endY) {
            final barWidth = bounds.right - bounds.left;
            final x = (bounds.left + bounds.right) / 2;
            final rectWidth =
                min(this.strokeWidth + 2 * outlineWidth, barWidth);
            final strokeWidth = rectWidth - 2 * outlineWidth;
            final rectEndpointLength =
                min(this.endpointLength + 2 * outlineWidth, barWidth.toDouble());
            final endpointLength = rectEndpointLength - 2 * outlineWidth;

            if (outlineWidth > 0) {
              // Draw rectangle rendering the outline for the vertical line.
              canvas.drawRect(
                Rectangle.fromPoints(
                  Point(x - rectWidth / 2, startY),
                  Point(x + rectWidth / 2, endY),
                ),
                fill: outlineColor,
                strokeWidth: outlineWidth,
              );

              // Draw rectangle rendering the outline for the horizontal
              // endpoint representing the lower bound.
              canvas.drawRect(
                Rectangle(
                  x - rectEndpointLength / 2,
                  startY - rectWidth / 2,
                  rectEndpointLength,
                  rectWidth,
                ),
                fill: outlineColor,
                strokeWidth: outlineWidth,
              );

              // Draw rectangle rendering the outline for the horizontal
              // endpoint representing the upper bound.
              canvas.drawRect(
                Rectangle(
                  x - rectEndpointLength / 2,
                  endY - rectWidth / 2,
                  rectEndpointLength,
                  rectWidth,
                ),
                fill: outlineColor,
                strokeWidth: outlineWidth,
              );
            }

            // Draw vertical whisker line.
            canvas.drawLine(
              points: [Point(x, startY), Point(x, endY)],
              stroke: strokeColor,
              strokeWidth: strokeWidth,
            );

            // Draw horizontal whisker line for the lower bound.
            canvas.drawLine(
              points: [
                Point(x - endpointLength / 2, startY),
                Point(x + endpointLength / 2, startY)
              ],
              stroke: strokeColor,
              strokeWidth: strokeWidth,
            );

            // Draw horizontal whisker line for the upper bound.
            canvas.drawLine(
              points: [
                Point(x - endpointLength / 2, endY),
                Point(x + endpointLength / 2, endY)
              ],
              stroke: strokeColor,
              strokeWidth: strokeWidth,
            );
          }
        } else {
          final startX = measureAxis.getLocation(
            (measureLowerBoundFn(datumIndex) ?? 0) +
                measureOffsetFn(datumIndex)!,
          )!;
          final endX = measureAxis.getLocation(
            (measureUpperBoundFn(datumIndex) ?? 0) +
                measureOffsetFn(datumIndex)!,
          )!;

          if (startX != endX) {
            final barWidth = bounds.bottom - bounds.top;
            final y = (bounds.top + bounds.bottom) / 2;
            final rectWidth =
                min(this.strokeWidth + 2 * outlineWidth, barWidth.toDouble());
            final strokeWidth = rectWidth - 2 * outlineWidth;
            final rectEndpointLength =
                min(this.endpointLength + 2 * outlineWidth, barWidth.toDouble());
            final endpointLength = rectEndpointLength - 2 * outlineWidth;

            if (outlineWidth > 0) {
              // Draw rectangle rendering the outline for the horizontal line.
              canvas.drawRect(
                Rectangle.fromPoints(
                  Point(startX, y - rectWidth / 2),
                  Point(endX, y + rectWidth / 2),
                ),
                fill: outlineColor,
                strokeWidth: outlineWidth,
              );

              // Draw rectangle rendering the outline for the vertical
              // endpoint representing the lower bound.
              canvas.drawRect(
                Rectangle(
                  startX - rectWidth / 2,
                  y - rectEndpointLength / 2,
                  rectWidth,
                  rectEndpointLength,
                ),
                fill: outlineColor,
                strokeWidth: outlineWidth,
              );

              // Draw rectangle rendering the outline for the vertical
              // endpoint representing the upper bound.
              canvas.drawRect(
                Rectangle(
                  endX - rectWidth / 2,
                  y - rectEndpointLength / 2,
                  rectWidth,
                  rectEndpointLength,
                ),
                fill: outlineColor,
                strokeWidth: outlineWidth,
              );
            }

            // Draw horizontal whisker line.
            canvas.drawLine(
              points: [Point(startX, y), Point(endX, y)],
              stroke: strokeColor,
              strokeWidth: strokeWidth,
            );

            // Draw vertical whisker line for the lower bound.
            canvas.drawLine(
              points: [
                Point(startX, y - endpointLength / 2),
                Point(startX, y + endpointLength / 2)
              ],
              stroke: strokeColor,
              strokeWidth: strokeWidth,
            );

            // Draw vertical whisker line for the upper bound.
            canvas.drawLine(
              points: [
                Point(endX, y - endpointLength / 2),
                Point(endX, y + endpointLength / 2)
              ],
              stroke: strokeColor,
              strokeWidth: strokeWidth,
            );
          }
        }
      }
    }
  }
}
