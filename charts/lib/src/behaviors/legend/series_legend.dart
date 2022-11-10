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
import 'package:charts/core.dart';
import 'package:flutter/material.dart';

/// Series legend behavior for charts.
@immutable
class SeriesLegend<D> extends ChartBehavior<D> {

  /// Create a tabular layout legend.
  ///
  /// By default, the legend is place above the chart and horizontally aligned
  /// to the start of the draw area.
  ///
  /// [position] the legend will be positioned relative to the chart. Default
  /// position is top.
  ///
  /// [outsideJustification] justification of the legend relative to the chart
  /// if the position is top, bottom, left, right. Default to start of the draw
  /// area.
  ///
  /// [insideJustification] justification of the legend relative to the chart if
  /// the position is inside. Default to top of the chart, start of draw area.
  /// Start of draw area means left for LTR directionality, and right for RTL.
  ///
  /// [horizontalFirst] if true, legend entries will grow horizontally first
  /// instead of vertically first. If the position is top, bottom, or inside,
  /// this defaults to true. Otherwise false.
  ///
  /// [desiredMaxRows] the max rows to use before layout out items in a new
  /// column. By default there is no limit. The max columns created is the
  /// smaller of desiredMaxRows and number of legend entries.
  ///
  /// [desiredMaxColumns] the max columns to use before laying out items in a
  /// row. By default there is no limit. The max columns created is the
  /// smaller of desiredMaxColumns and number of legend entries.
  ///
  /// [defaultHiddenSeries] lists the IDs of series that should be hidden on
  /// first chart draw.
  ///
  /// [showMeasures] show measure values for each series.
  ///
  /// [legendDefaultMeasure] if measure should show when there is no selection.
  /// This is set to none by default (only shows measure for selected data).
  ///
  /// [measureFormatter] formats measure value if measures are shown.
  ///
  /// [secondaryMeasureFormatter] formats measures if measures are shown for the
  /// series that uses secondary measure axis.
  factory SeriesLegend({
    BehaviorPosition? position,
    OutsideJustification? outsideJustification,
    InsideJustification? insideJustification,
    bool? horizontalFirst,
    int? desiredMaxRows,
    int? desiredMaxColumns,
    EdgeInsets? cellPadding,
    List<String>? defaultHiddenSeries,
    bool? showMeasures,
    LegendDefaultMeasure? legendDefaultMeasure,
    MeasureFormatter? measureFormatter,
    MeasureFormatter? secondaryMeasureFormatter,
    TextStyleSpec? entryTextStyle,
  }) {
    // Set defaults if empty.
    position ??= defaultBehaviorPosition;
    outsideJustification ??= defaultOutsideJustification;
    insideJustification ??= defaultInsideJustification;
    cellPadding ??= defaultCellPadding;

    // Set the tabular layout settings to match the position if it is not
    // specified.
    horizontalFirst ??= position == BehaviorPosition.top ||
        position == BehaviorPosition.bottom ||
        position == BehaviorPosition.inside;
    final layoutBuilder = horizontalFirst
        ? TabularLegendLayout.horizontalFirst(
            desiredMaxColumns: desiredMaxColumns, cellPadding: cellPadding,)
        : TabularLegendLayout.verticalFirst(
            desiredMaxRows: desiredMaxRows, cellPadding: cellPadding,);

    return SeriesLegend._internal(
        contentBuilder:
            TabularLegendContentBuilder(legendLayout: layoutBuilder),
        selectionModelType: SelectionModelType.info,
        position: position,
        outsideJustification: outsideJustification,
        insideJustification: insideJustification,
        defaultHiddenSeries: defaultHiddenSeries,
        showMeasures: showMeasures ?? false,
        legendDefaultMeasure: legendDefaultMeasure ?? LegendDefaultMeasure.none,
        measureFormatter: measureFormatter,
        secondaryMeasureFormatter: secondaryMeasureFormatter,
        entryTextStyle: entryTextStyle,);
  }

  /// Create a legend with custom layout.
  ///
  /// By default, the legend is place above the chart and horizontally aligned
  /// to the start of the draw area.
  ///
  /// [contentBuilder] builder for the custom layout.
  ///
  /// [position] the legend will be positioned relative to the chart. Default
  /// position is top.
  ///
  /// [outsideJustification] justification of the legend relative to the chart
  /// if the position is top, bottom, left, right. Default to start of the draw
  /// area.
  ///
  /// [insideJustification] justification of the legend relative to the chart if
  /// the position is inside. Default to top of the chart, start of draw area.
  /// Start of draw area means left for LTR directionality, and right for RTL.
  ///
  /// [defaultHiddenSeries] lists the IDs of series that should be hidden on
  /// first chart draw.
  ///
  /// [showMeasures] show measure values for each series.
  ///
  /// [legendDefaultMeasure] if measure should show when there is no selection.
  /// This is set to none by default (only shows measure for selected data).
  ///
  /// [measureFormatter] formats measure value if measures are shown.
  ///
  /// [secondaryMeasureFormatter] formats measures if measures are shown for the
  /// series that uses secondary measure axis.
  factory SeriesLegend.customLayout(
    LegendContentBuilder contentBuilder, {
    BehaviorPosition? position,
    OutsideJustification? outsideJustification,
    InsideJustification? insideJustification,
    List<String>? defaultHiddenSeries,
    bool? showMeasures,
    LegendDefaultMeasure? legendDefaultMeasure,
    MeasureFormatter? measureFormatter,
    MeasureFormatter? secondaryMeasureFormatter,
    TextStyleSpec? entryTextStyle,
  }) {
    // Set defaults if empty.
    position ??= defaultBehaviorPosition;
    outsideJustification ??= defaultOutsideJustification;
    insideJustification ??= defaultInsideJustification;

    return SeriesLegend._internal(
      contentBuilder: contentBuilder,
      selectionModelType: SelectionModelType.info,
      position: position,
      outsideJustification: outsideJustification,
      insideJustification: insideJustification,
      defaultHiddenSeries: defaultHiddenSeries,
      showMeasures: showMeasures ?? false,
      legendDefaultMeasure: legendDefaultMeasure ?? LegendDefaultMeasure.none,
      measureFormatter: measureFormatter,
      secondaryMeasureFormatter: secondaryMeasureFormatter,
      entryTextStyle: entryTextStyle,
    );
  }

  SeriesLegend._internal({
    required this.contentBuilder,
    this.selectionModelType,
    required this.position,
    required this.outsideJustification,
    required this.insideJustification,
    this.defaultHiddenSeries,
    required this.showMeasures,
    this.legendDefaultMeasure,
    this.measureFormatter,
    this.secondaryMeasureFormatter,
    this.entryTextStyle,
  });
  static const defaultBehaviorPosition = BehaviorPosition.top;
  static const defaultOutsideJustification = OutsideJustification.startDrawArea;
  static const defaultInsideJustification = InsideJustification.topStart;

  @override
  final desiredGestures = <GestureType>{};

  final SelectionModelType? selectionModelType;

  /// Builder for creating custom legend content.
  final LegendContentBuilder contentBuilder;

  /// Position of the legend relative to the chart.
  final BehaviorPosition position;

  /// Justification of the legend relative to the chart
  final OutsideJustification outsideJustification;
  final InsideJustification insideJustification;

  /// Whether or not the legend should show measures.
  ///
  /// By default this is false, measures are not shown. When set to true, the
  /// default behavior is to show measure only if there is selected data.
  /// Please set [legendDefaultMeasure] to something other than none to enable
  /// showing measures when there is no selection.
  ///
  /// This flag is used by the [contentBuilder], so a custom content builder
  /// has to choose if it wants to use this flag.
  final bool showMeasures;

  /// Option to show measures when selection is null.
  ///
  /// By default this is set to none, so no measures are shown when there is
  /// no selection.
  final LegendDefaultMeasure? legendDefaultMeasure;

  /// Formatter for measure value(s) if the measures are shown on the legend.
  final MeasureFormatter? measureFormatter;

  /// Formatter for secondary measure value(s) if the measures are shown on the
  /// legend and the series uses the secondary axis.
  final MeasureFormatter? secondaryMeasureFormatter;

  /// Styles for legend entry label text.
  final TextStyleSpec? entryTextStyle;

  static const defaultCellPadding = EdgeInsets.all(8);

  final List<String>? defaultHiddenSeries;

  @override
  SeriesLegendBehaviorState<D> createBehaviorState() =>
      _FlutterSeriesLegend<D>(this);

  @override
  void updateBehaviorState(ChartBehaviorState commonBehavior) {
    (commonBehavior as _FlutterSeriesLegend).config = this;
  }

  /// All Legend behaviors get the same role ID, because you should only have
  /// one legend on a chart.
  @override
  String get role => 'legend';

  @override
  List<Object?> get props => [
        selectionModelType,
        contentBuilder,
        position,
        outsideJustification,
        insideJustification,
        defaultHiddenSeries,
        showMeasures,
        legendDefaultMeasure,
        measureFormatter,
        secondaryMeasureFormatter,
        entryTextStyle
      ];
}

/// Flutter specific wrapper on the common Legend for building content.
class _FlutterSeriesLegend<D> extends SeriesLegendBehaviorState<D>
    implements BuildableBehavior, TappableLegend {

  _FlutterSeriesLegend(this.config)
      : super(
          selectionModelType: config.selectionModelType,
          measureFormatter: config.measureFormatter,
          secondaryMeasureFormatter: config.secondaryMeasureFormatter,
          legendDefaultMeasure: config.legendDefaultMeasure,
        ) {
    super.defaultHiddenSeries = config.defaultHiddenSeries;
    super.entryTextStyle = config.entryTextStyle;
  }
  SeriesLegend config;

  @override
  void updateLegend() {
    (chartContext as ChartContainerRenderObject).requestRebuild();
  }

  @override
  BehaviorPosition get position => config.position;

  @override
  OutsideJustification get outsideJustification => config.outsideJustification;

  @override
  InsideJustification get insideJustification => config.insideJustification;

  @override
  Widget build(BuildContext context) {
    final hasSelection =
        legendState.legendEntries.any((entry) => entry.isSelected);

    // Show measures if [showMeasures] is true and there is a selection or if
    // showing measures when there is no selection.
    final showMeasures = config.showMeasures &&
        (hasSelection || legendDefaultMeasure != LegendDefaultMeasure.none);

    return config.contentBuilder
        .build(context, legendState, this, showMeasures: showMeasures);
  }

  @override
  onLegendEntryTapUp(LegendEntry detail) {
    switch (legendTapHandling) {
      case LegendTapHandling.hide:
        _hideSeries(detail);
        break;

      case LegendTapHandling.none:
      default:
        break;
    }
  }

  /// Handles tap events by hiding or un-hiding entries tapped in the legend.
  ///
  /// Tapping on a visible series in the legend will hide it. Tapping on a
  /// hidden series will make it visible again.
  void _hideSeries(LegendEntry detail) {
    final seriesId = detail.series.id;

    // Handle the event by toggling the hidden state of the target.
    if (isSeriesHidden(seriesId)) {
      showSeries(seriesId);
    } else {
      hideSeries(seriesId);
    }

    // Redraw the chart to actually hide hidden series.
    chart.redraw(skipLayout: true);
  }
}
