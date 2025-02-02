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

import 'package:charts/charts/scatter_plot.dart';

class ScatterPlotChart extends CartesianChart<num> {
  const ScatterPlotChart(
    super.seriesList, {
    super.animate,
    super.animationDuration,
    super.domainAxis,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
    PointRendererConfig<num>? defaultRenderer,
    super.customSeriesRenderers,
    super.behaviors,
    super.selectionModels,
    super.rtlSpec,
    super.layoutConfig,
    super.defaultInteractions = true,
    super.flipVerticalAxis,
    super.userManagedState,
  }) : super(
          defaultRenderer: defaultRenderer,
        );

  @override
  ScatterPlotRenderChart createRenderChart(BaseChartState chartState) {
    // Optionally create primary and secondary measure axes if the chart was
    // configured with them. If no axes were configured, then the chart will
    // use its default types (usually a numeric axis).
    return ScatterPlotRenderChart(
      layoutConfig: layoutConfig,
      primaryMeasureAxis: primaryMeasureAxis?.createElement(),
      secondaryMeasureAxis: secondaryMeasureAxis?.createElement(),
      disjointMeasureAxes: createDisjointMeasureAxes(),
    );
  }
}
