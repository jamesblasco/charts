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

import 'package:charts/charts/bar.dart';
export 'widgets/bar_chart.dart';
export 'bar_error_decorator.dart';
export 'bar_label_decorator.dart';
export 'bar_lane_renderer.dart';
export 'bar_lane_renderer_config.dart';
export 'bar_renderer.dart';
export 'bar_renderer_config.dart';
export 'bar_renderer_decorator.dart';
export 'bar_target_line_renderer.dart';
export 'bar_target_line_renderer_config.dart';
export 'base_bar_renderer.dart';
export 'base_bar_renderer_config.dart';
export 'base_bar_renderer_element.dart';

class BarRenderChart extends OrdinalCartesianRenderChart {
  BarRenderChart(
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
  SeriesRenderer<String> makeDefaultRenderer() {
    return BarRenderer<String>()..rendererId = SeriesRenderer.defaultRendererId;
  }
}
