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
import 'package:meta/meta.dart' show immutable;

/// Chart behavior that sets the initial selection for a [selectionModelType].
@immutable
class InitialSelection<D> extends ChartBehavior<D> {

  InitialSelection(
      {this.selectionModelType = SelectionModelType.info,
      this.selectedSeriesConfig,
      this.selectedDataConfig,
      this.shouldPreserveSelectionOnDraw = false,});
  @override
  final desiredGestures = <GestureType>{};

  final SelectionModelType selectionModelType;
  final List<String>? selectedSeriesConfig;
  final List<SeriesDatumConfig<D>>? selectedDataConfig;
  final bool shouldPreserveSelectionOnDraw;

  @override
  InitialSelectionState<D> createBehaviorState() => InitialSelectionState<D>(
      selectionModelType: selectionModelType,
      selectedDataConfig: selectedDataConfig,
      selectedSeriesConfig: selectedSeriesConfig,
      shouldPreserveSelectionOnDraw: shouldPreserveSelectionOnDraw,);

  @override
  void updateBehaviorState(ChartBehaviorState commonBehavior) {}

  @override
  String get role => 'InitialSelection-${selectionModelType.toString()}';

  @override
  List<Object?> get props =>
      [selectionModelType, selectedSeriesConfig, selectedDataConfig];
}
