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

import 'package:charts/charts/bar.dart';

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
export 'widgets/bar_chart.dart';

class BarRenderChart extends OrdinalCartesianRenderChart {
  BarRenderChart(
      {super.vertical,
      super.layoutConfig,
      super.primaryMeasureAxis,
      super.secondaryMeasureAxis,
      super.disjointMeasureAxes,});

  @override
  SeriesRenderer<String> makeDefaultRenderer() {
    return BarRenderer<String>()..rendererId = SeriesRenderer.defaultRendererId;
  }
}
