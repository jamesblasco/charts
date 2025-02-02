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

/// Chart behavior that centers the viewport on the selected domain.
///
/// It is used in combination with SelectNearest to update the selection model
/// and notify this behavior to update the viewport on selection change.
///
/// This behavior can only be used on [CartesianRenderChart].
class SlidingViewportState<D> implements ChartBehaviorState<D> {
  SlidingViewportState([this.selectionModelType = SelectionModelType.info]);
  final SelectionModelType selectionModelType;

  late CartesianRenderChart<D> _chart;

  void _selectionChanged(SelectionModel<D> selectionModel) {
    if (selectionModel.hasAnySelection == false) {
      return;
    }

    // Calculate current viewport center and determine the translate pixels
    // needed based on the selected domain value's location and existing amount
    // of translate pixels.
    final domainAxis = _chart.domainAxis!;
    final selectedDatum = selectionModel.selectedDatum.first;
    final domainLocation = domainAxis
        .getLocation(selectedDatum.series.domainFn(selectedDatum.index))!;
    final viewportCenter =
        domainAxis.range!.start + (domainAxis.range!.width / 2);
    final translate =
        domainAxis.viewportTranslate + (viewportCenter - domainLocation);
    domainAxis.setViewportSettings(
      domainAxis.viewportScalingFactor,
      translate,
    );

    _chart.redraw();
  }

  @override
  void attachTo(BaseRenderChart<D> chart) {
    assert(chart is CartesianRenderChart);
    _chart = chart as CartesianRenderChart<D>;
    chart
        .getSelectionModel(selectionModelType)
        .addSelectionChangedListener(_selectionChanged);
  }

  @override
  void removeFrom(BaseRenderChart<D> chart) {
    chart
        .getSelectionModel(selectionModelType)
        .removeSelectionChangedListener(_selectionChanged);
  }

  @override
  String get role => 'slidingViewport-$selectionModelType';
}
