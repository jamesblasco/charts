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

/// A numeric combo chart supports rendering each series of data with different
/// series renderers.
///
/// Note that if you have DateTime data, you should use [TimeSeriesChart]. We do
/// not expose a separate DateTimeComboChart because it would just be a copy of
/// that chart.
class NumericComboChart extends CartesianChart<num> {
  NumericComboChart(
    List<Series<dynamic, num>> seriesList, {
    bool? animate,
    Duration? animationDuration,
    AxisSpec? domainAxis,
    NumericAxisSpec? primaryMeasureAxis,
    NumericAxisSpec? secondaryMeasureAxis,
    SeriesRendererConfig<num>? defaultRenderer,
    List<SeriesRendererConfig<num>>? customSeriesRenderers,
    List<ChartBehavior<num>>? behaviors,
    List<SelectionModelConfig<num>>? selectionModels,
    RTLSpec? rtlSpec,
    LayoutConfig? layoutConfig,
    bool defaultInteractions = true,
  }) : super(
          seriesList,
          animate: animate,
          animationDuration: animationDuration,
          domainAxis: domainAxis,
          primaryMeasureAxis: primaryMeasureAxis,
          secondaryMeasureAxis: secondaryMeasureAxis,
          defaultRenderer: defaultRenderer,
          customSeriesRenderers: customSeriesRenderers,
          behaviors: behaviors,
          selectionModels: selectionModels,
          rtlSpec: rtlSpec,
          layoutConfig: layoutConfig,
          defaultInteractions: defaultInteractions,
        );

  @override
  NumericCartesianRenderChart createRenderChart(
      BaseChartState chartState) {
    // Optionally create primary and secondary measure axes if the chart was
    // configured with them. If no axes were configured, then the chart will
    // use its default types (usually a numeric axis).
    return NumericCartesianRenderChart(
        layoutConfig: layoutConfig,
        primaryMeasureAxis: primaryMeasureAxis?.createAxis(),
        secondaryMeasureAxis: secondaryMeasureAxis?.createAxis());
  }
}

/// An ordinal combo chart supports rendering each series of data with different
/// series renderers.
class OrdinalComboChart extends CartesianChart<String> {
  OrdinalComboChart(
    List<Series<dynamic, String>> seriesList, {
    bool? animate,
    Duration? animationDuration,
    AxisSpec? domainAxis,
    NumericAxisSpec? primaryMeasureAxis,
    NumericAxisSpec? secondaryMeasureAxis,
    SeriesRendererConfig<String>? defaultRenderer,
    List<SeriesRendererConfig<String>>? customSeriesRenderers,
    List<ChartBehavior<String>>? behaviors,
    List<SelectionModelConfig<String>>? selectionModels,
    RTLSpec? rtlSpec,
    LayoutConfig? layoutConfig,
    bool defaultInteractions = true,
  }) : super(
          seriesList,
          animate: animate,
          animationDuration: animationDuration,
          domainAxis: domainAxis,
          primaryMeasureAxis: primaryMeasureAxis,
          secondaryMeasureAxis: secondaryMeasureAxis,
          defaultRenderer: defaultRenderer,
          customSeriesRenderers: customSeriesRenderers,
          behaviors: behaviors,
          selectionModels: selectionModels,
          rtlSpec: rtlSpec,
          layoutConfig: layoutConfig,
          defaultInteractions: defaultInteractions,
        );

  @override
  OrdinalCartesianRenderChart createRenderChart(
      BaseChartState chartState) {
    // Optionally create primary and secondary measure axes if the chart was
    // configured with them. If no axes were configured, then the chart will
    // use its default types (usually a numeric axis).
    return OrdinalCartesianRenderChart(
        layoutConfig: layoutConfig,
        primaryMeasureAxis: primaryMeasureAxis?.createAxis(),
        secondaryMeasureAxis: secondaryMeasureAxis?.createAxis());
  }
}
