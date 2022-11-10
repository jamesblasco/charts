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

/// Behavior that sets initial selection.
class InitialSelectionState<D> implements ChartBehaviorState<D> {
  final SelectionModelType selectionModelType;

  /// List of series id of initially selected series.
  final List<String>? selectedSeriesConfig;

  /// List of [SeriesDatumConfig] that represents the initially selected datums.
  final List<SeriesDatumConfig<D>>? selectedDataConfig;

  /// Preserve selection on every draw. False by default and only preserves
  /// selection until the fist draw or redraw call.
  final bool shouldPreserveSelectionOnDraw;

  BaseRenderChart<D>? _chart;
  late LifecycleListener<D> _lifecycleListener;
  bool _firstDraw = true;

  // TODO : When the series changes, if the user does not also
  // change the index the wrong item could be highlighted.
  InitialSelectionState(
      {this.selectionModelType = SelectionModelType.info,
      this.selectedDataConfig,
      this.selectedSeriesConfig,
      this.shouldPreserveSelectionOnDraw = false}) {
    _lifecycleListener = LifecycleListener<D>(onData: _setInitialSelection);
  }

  void _setInitialSelection(List<MutableSeries<D>> seriesList) {
    if (!_firstDraw && !shouldPreserveSelectionOnDraw) {
      return;
    }
    _firstDraw = false;

    final immutableModel = SelectionModel<D>.fromConfig(
        selectedDataConfig, selectedSeriesConfig, seriesList);

    _chart!.getSelectionModel(selectionModelType).updateSelection(
        immutableModel.selectedDatum, immutableModel.selectedSeries,
        notifyListeners: false);
  }

  @override
  void attachTo(BaseRenderChart<D> chart) {
    _chart = chart;
    chart.addLifecycleListener(_lifecycleListener);
  }

  @override
  void removeFrom(BaseRenderChart<D> chart) {
    chart.removeLifecycleListener(_lifecycleListener);
    _chart = null;
  }

  @override
  String get role => 'InitialSelection-$selectionModelType';
}
