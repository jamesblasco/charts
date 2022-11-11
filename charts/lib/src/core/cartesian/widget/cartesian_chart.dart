import 'dart:collection';

import 'package:charts/core.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CartesianChart<D> extends BaseChart<D> {
  const CartesianChart(
    super.seriesList, {
    super.animate,
    super.animationDuration,
    this.domainAxis,
    this.primaryMeasureAxis,
    this.secondaryMeasureAxis,
    this.disjointMeasureAxes,
    super.defaultRenderer,
    super.customSeriesRenderers,
    super.behaviors,
    super.selectionModels,
    super.rtlSpec,
    super.defaultInteractions = true,
    super.layoutConfig,
    super.userManagedState,
    this.flipVerticalAxis,
  });
  final AxisData? domainAxis;
  final NumericAxis? primaryMeasureAxis;
  final NumericAxis? secondaryMeasureAxis;
  final LinkedHashMap<String, NumericAxis>? disjointMeasureAxes;
  final bool? flipVerticalAxis;

  @override
  void updateRenderChart(
    BaseRenderChart<D> baseChart,
    BaseChart<D>? oldWidget,
    BaseChartState<D> chartState,
  ) {
    super.updateRenderChart(baseChart, oldWidget, chartState);

    final prev = oldWidget as CartesianChart?;
    final chart = baseChart as CartesianRenderChart;

    if (flipVerticalAxis != null) {
      chart.flipVerticalAxisOutput = flipVerticalAxis!;
    }

    if (domainAxis != null && domainAxis != prev?.domainAxis) {
      chart.domainAxisSpec = domainAxis!;
      chartState.markChartDirty();
    }

    if (primaryMeasureAxis != prev?.primaryMeasureAxis) {
      chart.primaryMeasureAxisSpec = primaryMeasureAxis;
      chartState.markChartDirty();
    }

    if (secondaryMeasureAxis != prev?.secondaryMeasureAxis) {
      chart.secondaryMeasureAxisSpec = secondaryMeasureAxis;
      chartState.markChartDirty();
    }

    if (disjointMeasureAxes != prev?.disjointMeasureAxes) {
      chart.disjointMeasureAxisSpecs = disjointMeasureAxes;
      chartState.markChartDirty();
    }
  }

  @protected
  LinkedHashMap<String, NumericAxisElement>? createDisjointMeasureAxes() {
    if (disjointMeasureAxes != null) {
      final disjointAxes = <String, NumericAxisElement>{};

      disjointMeasureAxes!.forEach((String axisId, NumericAxis axisSpec) {
        disjointAxes[axisId] = axisSpec.createElement();
      });

      return LinkedHashMap.from(disjointAxes);
    } else {
      return null;
    }
  }
}
