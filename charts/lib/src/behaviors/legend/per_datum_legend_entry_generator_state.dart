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
import 'package:equatable/equatable.dart';

/// A strategy for generating a list of [LegendEntry] per series data drawn.
///
/// [D] the domain class type for the datum.
class PerDatumLegendEntryGenerator<D> extends Equatable
    implements LegendEntryGenerator<D> {
  @override
  TextStyle? entryTextStyle;

  @override
  MeasureFormatter? measureFormatter;

  @override
  MeasureFormatter? secondaryMeasureFormatter;

  @override
  late bool showOverlaySeries;

  /// Option for showing measures when there is no selection.
  @override
  late LegendDefaultMeasure legendDefaultMeasure;

  @override
  List<LegendEntry<D>> getLegendEntries(List<MutableSeries<D>> seriesList) {
    final legendEntries = <LegendEntry<D>>[];

    final series = seriesList[0];
    for (var i = 0; i < series.data.length; i++) {
      legendEntries.add(
        LegendEntry<D>(
          series,
          series.domainFn(i).toString(),
          color: series.colorFn!(i),
          datum: series.data[i],
          datumIndex: i,
          textStyle: entryTextStyle,
        ),
      );
    }

    // Update with measures only if showing measure on no selection.
    if (legendDefaultMeasure != LegendDefaultMeasure.none) {
      _updateEntries(legendEntries);
    }

    return legendEntries;
  }

  @override
  void updateLegendEntries(
    List<LegendEntry<D>> legendEntries,
    SelectionModel<D> selectionModel,
    List<MutableSeries<D>> seriesList,
  ) {
    if (selectionModel.hasAnySelection) {
      _updateFromSelection(legendEntries, selectionModel);
    } else {
      // Update with measures only if showing measure on no selection.
      if (legendDefaultMeasure != LegendDefaultMeasure.none) {
        _updateEntries(legendEntries);
      } else {
        _resetLegendEntryMeasures(legendEntries);
      }
    }
  }

  /// Update legend entries with measures of the selected datum
  void _updateFromSelection(
    List<LegendEntry<D>> legendEntries,
    SelectionModel<D> selectionModel,
  ) {
    // Given that each legend entry only has one datum associated with it, any
    // option for [legendDefaultMeasure] essentially boils down to just showing
    // the measure value.
    if (legendDefaultMeasure != LegendDefaultMeasure.none) {
      for (final entry in legendEntries) {
        final series = entry.series;
        final measure = series.measureFn(entry.datumIndex);
        entry.value = measure!.toDouble();
        entry.formattedValue = _getFormattedMeasureValue(series, measure);

        entry.isSelected = selectionModel.selectedSeries
            .any((selectedSeries) => series.id == selectedSeries.id);
      }
    }
  }

  void _resetLegendEntryMeasures(List<LegendEntry<D>> legendEntries) {
    for (final entry in legendEntries) {
      entry.value = null;
      entry.formattedValue = null;
      entry.isSelected = false;
    }
  }

  /// Update each legend entry by calculating measure values for its series.
  ///
  /// This method calculates the legend's measure value to show when there is no
  /// selection. The type of calculation is based on the [legendDefaultMeasure]
  /// value.
  void _updateEntries(List<LegendEntry<D>> legendEntries) {
    // Given that each legend entry only has one datum associated with it, any
    // option for [legendDefaultMeasure] essentially boils down to just showing
    // the measure value.
    if (legendDefaultMeasure != LegendDefaultMeasure.none) {
      for (final entry in legendEntries) {
        final series = entry.series;
        final measure = series.measureFn(entry.datumIndex);
        entry.value = measure!.toDouble();
        entry.formattedValue = _getFormattedMeasureValue(series, measure);
        entry.isSelected = false;
      }
    }
  }

  /// Formats the measure value using the appropriate measure formatter
  /// function for the series.
  String _getFormattedMeasureValue(ImmutableSeries<D> series, num measure) {
    return (series.getAttr(measureAxisIdKey) ==
            MutableAxisElement.secondaryMeasureAxisId)
        ? secondaryMeasureFormatter!(measure)
        : measureFormatter!(measure);
  }

  @override
  List<Object?> get props => [
        measureFormatter,
        secondaryMeasureFormatter,
        legendDefaultMeasure,
        entryTextStyle
      ];
}
