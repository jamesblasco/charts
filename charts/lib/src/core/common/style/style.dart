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

import 'package:charts/core.dart';

// TODO: Implementation of style will change drastically, see bug
// for more details. This is an intermediate step in order to allow overriding
// the default style using style factory.

/// A set of styling rules that determines the default look and feel of charts.
///
/// Get or set the [ChartThemeData] that is used for the app using [StyleFactory.style].
abstract class ChartThemeData {
  Color get black;

  Color get transparent;

  Color get white;

  /// Gets list with [count] of palettes.
  List<MaterialColor> getOrderedPalettes(int count);

  /// Creates [LineStyle] for axis line from spec.
  ///
  /// Fill missing value(s) with default.
  LineStyle createAxisLineStyle(
    GraphicsFactory graphicsFactory,
    LineStyle? spec,
  );

  /// Creates [LineStyle] for tick lines from spec.
  ///
  /// Fill missing value(s) with default.
  LineStyle createTickLineStyle(
    GraphicsFactory graphicsFactory,
    LineStyle? spec,
  );

  /// Default tick length.
  double get tickLength;

  /// Default tick color.
  Color get tickColor;

  ///
  /// Creates [LineStyle] for axis gridlines from spec.
  ///
  /// Fill missing value(s) with default.
  LineStyle createGridlineStyle(
    GraphicsFactory graphicsFactory,
    LineStyle? spec,
  );

  /// Default color for outside label leader lines for [ArcLabelDecorator].
  Color get arcLabelOutsideLeaderLine;

  /// Default series color for legends, used as a fallback when a series has no
  /// data.
  Color get defaultSeriesColor;

  /// Default color for strokes for [ArcRendererConfig].
  Color get arcStrokeColor;

  /// Default color for entry text for [Legend].
  Color get legendEntryTextColor;

  /// Default color for title text for [Legend].
  Color get legendTitleTextColor;

  /// Default color for [LinePointHighlighter].
  Color get linePointHighlighterColor;

  /// Default color for "no data" states on charts.
  Color get noDataColor;

  /// Default color for [RangeAnnotation].
  Color get rangeAnnotationColor;

  /// Default fill color for [Slider].
  Color get sliderFillColor;

  /// Default stroke color for [Slider].
  Color get sliderStrokeColor;

  /// Default background color for the chart.
  Color get chartBackgroundColor;

  /// The width of the band specified as fraction of step.
  double get rangeBandSize;
}
