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
import 'package:charts/charts/line.dart';

class TimeSeriesChart extends CartesianChart<DateTime> {
  /// Create a [TimeSeriesChart].
  ///
  /// [dateTimeFactory] allows specifying a factory that creates [DateTime] to
  /// be used for the time axis. If none specified, local date time is used.
  const TimeSeriesChart(
    super.seriesList, {
    super.animate,
    super.animationDuration,
    super.domainAxis,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
    super.defaultRenderer,
    super.customSeriesRenderers,
    super.behaviors,
    super.selectionModels,
    super.layoutConfig,
    this.dateTimeFactory,
    super.defaultInteractions = true,
    super.flipVerticalAxis,
    super.userManagedState,
  });
  final DateTimeFactory? dateTimeFactory;

  @override
  TimeSeriesRenderChart createRenderChart(BaseChartState chartState) {
    // Optionally create primary and secondary measure axes if the chart was
    // configured with them. If no axes were configured, then the chart will
    // use its default types (usually a numeric axis).
    return TimeSeriesRenderChart(
      layoutConfig: layoutConfig,
      primaryMeasureAxis: primaryMeasureAxis?.createAxis(),
      secondaryMeasureAxis: secondaryMeasureAxis?.createAxis(),
      disjointMeasureAxes: createDisjointMeasureAxes(),
      dateTimeFactory: dateTimeFactory ?? const LocalDateTimeFactory(),
    );
  }

  @override
  void addDefaultInteractions(List<ChartBehavior<DateTime>> behaviors) {
    super.addDefaultInteractions(behaviors);

    behaviors.add(LinePointHighlighter<DateTime>());
  }
}

class TimeSeriesRenderChart extends CartesianRenderChart<DateTime> {
  TimeSeriesRenderChart({
    super.vertical,
    super.layoutConfig,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
    this.dateTimeFactory = const LocalDateTimeFactory(),
  }) : super(
          domainAxis: DateTimeAxis(dateTimeFactory),
        );
  final DateTimeFactory dateTimeFactory;

  @override
  void initDomainAxis() {
    domainAxis!.tickDrawStrategy = const SmallTickRendererSpec<DateTime>()
        .createDrawStrategy(context, graphicsFactory!);
  }

  @override
  SeriesRenderer<DateTime> makeDefaultRenderer() {
    return LineRenderer<DateTime>()
      ..rendererId = SeriesRenderer.defaultRendererId;
  }

  @override
  Axis<DateTime> createDomainAxisFromSpec(AxisSpec<DateTime> axisSpec) {
    return (axisSpec as DateTimeAxisSpec).createDateTimeAxis(dateTimeFactory);
  }
}
