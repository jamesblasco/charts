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
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart' show BuildContext, hashValues, Widget;

/// Strategy for building a legend content widget.
abstract class LegendContentBuilder {
  const LegendContentBuilder();

  Widget build(
      BuildContext context, LegendState legendState, LegendBehaviorState legend,
      {bool showMeasures,});
}

/// Base strategy for building a legend content widget.
///
/// Each legend entry is passed to a [LegendLayout] strategy to create a widget
/// for each legend entry. These widgets are then passed to a
/// [LegendEntryLayout] strategy to create the legend widget.
abstract class BaseLegendContentBuilder extends Equatable
    implements LegendContentBuilder {
  /// Strategy for creating one widget or each legend entry.
  LegendEntryLayout get legendEntryLayout;

  /// Strategy for creating the legend content widget from a list of widgets.
  ///
  /// This is typically the list of widgets from legend entries.
  LegendLayout get legendLayout;

  @override
  Widget build(
      BuildContext context, LegendState legendState, LegendBehaviorState legend,
      {bool showMeasures = false,}) {
    final entryWidgets = legendState.legendEntries.map((entry) {
      var isHidden = false;
      if (legend is SeriesLegendBehaviorState) {
        isHidden = legend.isSeriesHidden(entry.series.id);
      }

      return legendEntryLayout.build(
          context, entry, legend as TappableLegend, isHidden,
          showMeasures: showMeasures,);
    }).toList();

    return legendLayout.build(context, entryWidgets);
  }
}

// TODO: Expose settings for tabular layout.
/// Strategy that builds a tabular legend.
///
/// [legendEntryLayout] custom strategy for creating widgets for each legend
/// entry.
/// [legendLayout] custom strategy for creating legend widget from list of
/// widgets that represent a legend entry.
class TabularLegendContentBuilder extends BaseLegendContentBuilder {

  TabularLegendContentBuilder(
      {LegendEntryLayout? legendEntryLayout, LegendLayout? legendLayout,})
      : legendEntryLayout =
            legendEntryLayout ?? const SimpleLegendEntryLayout(),
        legendLayout =
            legendLayout ?? TabularLegendLayout.horizontalFirst();
  @override
  final LegendEntryLayout legendEntryLayout;
  @override
  final LegendLayout legendLayout;

  @override
  List<Object?> get props => [legendEntryLayout, legendLayout];
}
