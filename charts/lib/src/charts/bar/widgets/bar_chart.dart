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

import 'package:charts/behaviors.dart';
import 'package:charts/charts/bar.dart';
import 'package:meta/meta.dart';

@immutable
class BarChart extends CartesianChart<String> {
  BarChart(
    super.seriesList, {
    super.animate,
    super.animationDuration,
    super.domainAxis,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
    BarGroupingType? barGroupingType,
    SeriesRendererConfig<String>? defaultRenderer,
    super.customSeriesRenderers,
    super.behaviors,
    super.selectionModels,
    super.rtlSpec,
    this.vertical = true,
    super.defaultInteractions = true,
    super.layoutConfig,
    super.userManagedState,
    this.barRendererDecorator,
    super.flipVerticalAxis,
  }) : super(
          defaultRenderer: defaultRenderer ??
              BarRendererConfig<String>(
                groupingType: barGroupingType,
                barRendererDecorator: barRendererDecorator,
              ),
        );

  final bool vertical;
  final BarRendererDecorator<String>? barRendererDecorator;

  @override
  BarRenderChart createRenderChart(BaseChartState chartState) {
    // Optionally create primary and secondary measure axes if the chart was
    // configured with them. If no axes were configured, then the chart will
    // use its default types (usually a numeric axis).
    return BarRenderChart(
      vertical: vertical,
      layoutConfig: layoutConfig,
      primaryMeasureAxis: primaryMeasureAxis?.createAxis(),
      secondaryMeasureAxis: secondaryMeasureAxis?.createAxis(),
      disjointMeasureAxes: createDisjointMeasureAxes(),
    );
  }

  @override
  void addDefaultInteractions(List<ChartBehavior<String>> behaviors) {
    super.addDefaultInteractions(behaviors);
    behaviors.add(DomainHighlighter<String>());
  }
}
