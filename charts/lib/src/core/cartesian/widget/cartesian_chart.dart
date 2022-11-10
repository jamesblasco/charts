import 'dart:collection';

import 'package:charts/core.dart';
import 'package:meta/meta.dart';

@immutable
abstract class CartesianChart<D> extends BaseChart<D> {
  final AxisSpec? domainAxis;
  final NumericAxisSpec? primaryMeasureAxis;
  final NumericAxisSpec? secondaryMeasureAxis;
  final LinkedHashMap<String, NumericAxisSpec>? disjointMeasureAxes;
  final bool? flipVerticalAxis;

  CartesianChart(
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

  @override
  void updateRenderChart(BaseRenderChart<D> baseChart, BaseChart<D>? oldWidget,
      BaseChartState<D> chartState) {
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
  LinkedHashMap<String, NumericAxis>? createDisjointMeasureAxes() {
    if (disjointMeasureAxes != null) {
      final disjointAxes = LinkedHashMap<String, NumericAxis>();

      disjointMeasureAxes!.forEach((String axisId, NumericAxisSpec axisSpec) {
        disjointAxes[axisId] = axisSpec.createAxis();
      });

      return disjointAxes;
    } else {
      return null;
    }
  }
}
