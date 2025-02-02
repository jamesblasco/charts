// Copyright 2019 the Charts project authors. Please see the AUTHORS file
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

/// Chart behavior that monitors the specified [SelectionModel] and outlines the
/// selected data.
///
/// This is typically used for treemap charts to highlight nodes.
/// For bars and pies, prefers to use [DomainHighlighter] for UX consistency.
class DomainOutlinerState<D> implements ChartBehaviorState<D> {
  DomainOutlinerState({
    this.selectionType = SelectionModelType.info,
    double? defaultStroke,
    double? strokePadding,
  })  : defaultStroke = defaultStroke ?? 2.0,
        strokePadding = strokePadding ?? 1.0 {
    _lifecycleListener = LifecycleListener<D>(onPostprocess: _outline);
  }
  final SelectionModelType selectionType;

  /// Default stroke width of the outline if the series has no stroke width
  /// function.
  ///
  /// When no stroke width function is provided, this value will be used as
  /// is. [strokePadding] will not be added to [defaultStroke].
  final double defaultStroke;

  /// Additional stroke width added to the outline of the selected data.
  ///
  /// This value is only used when the series has a stroke width function
  /// defined.
  final double strokePadding;

  late BaseRenderChart<D> _chart;

  late LifecycleListener<D> _lifecycleListener;

  void _selectionChange(SelectionModel<D> selectionModel) {
    _chart.redraw(skipLayout: true, skipAnimation: true);
  }

  void _outline(List<MutableSeries<D>> seriesList) {
    final selectionModel = _chart.getSelectionModel(selectionType);

    for (final series in seriesList) {
      final strokeWidthFn = series.strokeWidthFn;
      final colorFn = series.colorFn;

      if (colorFn != null) {
        series.colorFn = (int? index) {
          final color = colorFn(index);
          return selectionModel.isDatumSelected(series, index)
              ? color.darker
              : color;
        };
      }

      if (strokeWidthFn != null) {
        series.strokeWidthFn = (int? index) {
          final strokeWidth = strokeWidthFn(index);
          if (!selectionModel.isDatumSelected(series, index)) {
            return strokeWidth;
          }
          return strokeWidth == null
              ? defaultStroke
              : strokeWidth + strokePadding;
        };
      }
    }
  }

  @override
  void attachTo(BaseRenderChart<D> chart) {
    _chart = chart;
    chart.addLifecycleListener(_lifecycleListener);
    chart
        .getSelectionModel(selectionType)
        .addSelectionChangedListener(_selectionChange);
  }

  @override
  void removeFrom(BaseRenderChart<D> chart) {
    chart
        .getSelectionModel(selectionType)
        .removeSelectionChangedListener(_selectionChange);
    chart.removeLifecycleListener(_lifecycleListener);
  }

  @override
  String get role => 'domainOutliner-$selectionType';
}
