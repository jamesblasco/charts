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

import 'dart:collection' show LinkedHashMap;

import 'package:charts/charts/scatter_plot.dart';

export 'comparison_points_decorator.dart';
export 'point_renderer_config.dart';
export 'widgets/scatter_plot_chart.dart';
export 'point_renderer_decorator.dart';
export 'point_renderer.dart';

export 'symbol_annotation_renderer_config.dart';
export 'symbol_annotation_renderer.dart';

/// A scatter plot draws series data as a collection of points in a two
/// dimensional Cartesian space, plotting two variables from each datum at a
/// point represented by (domain, measure).
///
/// A third and fourth metric can be represented by configuring the color and
/// radius of each datum.
///
/// Scatter plots render grid lines along both the domain and measure axes by
/// default.
class ScatterPlotRenderChart extends NumericCartesianRenderChart {
  /// Select data by relative Cartesian distance. Scatter plots draw potentially
  /// overlapping data in an arbitrary (x, y) space, and do not consider the
  /// domain axis to be more or  less important for data selection than the
  /// measure axis.
  @override
  bool get selectNearestByDomain => false;

  /// On scatter plots, overlapping points that contain the click/tap location
  /// are all added to the selection.
  @override
  bool get selectOverlappingPoints => true;

  ScatterPlotRenderChart(
      {bool? vertical,
      LayoutConfig? layoutConfig,
      NumericAxis? primaryMeasureAxis,
      NumericAxis? secondaryMeasureAxis,
      LinkedHashMap<String, NumericAxis>? disjointMeasureAxes})
      : super(
            vertical: vertical,
            layoutConfig: layoutConfig,
            primaryMeasureAxis: primaryMeasureAxis,
            secondaryMeasureAxis: secondaryMeasureAxis,
            disjointMeasureAxes: disjointMeasureAxes);

  @override
  SeriesRenderer<num> makeDefaultRenderer() {
    return PointRenderer<num>()..rendererId = SeriesRenderer.defaultRendererId;
  }

  @override
  void initDomainAxis() {
    domainAxis!.tickDrawStrategy = GridlineRendererSpec<num>()
        .createDrawStrategy(context, graphicsFactory!);
  }
}
