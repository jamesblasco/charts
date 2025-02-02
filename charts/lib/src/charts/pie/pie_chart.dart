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


import 'package:charts/charts/pie.dart';

export 'arc_label_decorator.dart';
export 'arc_renderer.dart';
export 'arc_renderer_config.dart';
export 'arc_renderer_config.dart';
export 'arc_renderer_decorator.dart';
export 'arc_renderer_element.dart';
export 'base_arc_renderer.dart';
export 'base_arc_renderer_config.dart';
export 'widgets/pie_chart.dart';
export 'widgets/pie_chart.dart';

class PieRenderChart<D> extends BaseRenderChart<D> {
  PieRenderChart({LayoutConfig? layoutConfig})
      : super(layoutConfig: layoutConfig ?? _defaultLayoutConfig);
  static final _defaultLayoutConfig = LayoutConfig(
    margin: LayoutMargin.all(LayoutValue.between(minPixel: 20)),
  );

  @override
  void drawInternal(
    List<MutableSeries<D>> seriesList, {
    bool? skipAnimation,
    bool? skipLayout,
  }) {
    if (seriesList.length > 1) {
      throw ArgumentError('PieChart can only render a single series');
    }
    super.drawInternal(
      seriesList,
      skipAnimation: skipAnimation,
      skipLayout: skipLayout,
    );
  }

  @override
  void updateConfig(LayoutConfig? layoutConfig) {
    super.updateConfig(layoutConfig ?? _defaultLayoutConfig);
  }

  @override
  SeriesRenderer<D> makeDefaultRenderer() {
    return ArcRenderer<D>()..rendererId = SeriesRenderer.defaultRendererId;
  }

  /// Returns a list of datum details from selection model of [type].
  @override
  List<DatumDetails<D>> getDatumDetails(SelectionModelType type) {
    final entries = <DatumDetails<D>>[];

    for (final seriesDatum in getSelectionModel(type).selectedDatum) {
      final rendererId = seriesDatum.series.getAttr(rendererIdKey);
      final renderer = getSeriesRenderer(rendererId);

      // This should never happen.
      if (renderer is! ArcRenderer<D>) {
        continue;
      }

      final details = renderer.getExpandedDatumDetails(seriesDatum);

      entries.add(details);
    }

    return entries;
  }

  Rect? get centerContentBounds {
    final defaultRenderer = this.defaultRenderer;
    if (defaultRenderer is ArcRenderer<D>) {
      return defaultRenderer.centerContentBounds;
    } else {
      return null;
    }
  }
}
