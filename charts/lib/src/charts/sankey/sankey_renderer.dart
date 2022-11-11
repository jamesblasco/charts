// Copyright 2021 the Charts project authors. Please see the AUTHORS file
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

import 'dart:math' show Point, Rectangle;
import 'package:charts/charts/sankey.dart';

/// Sankey Renderer for the Sankey Chart using Graph data structure
class SankeyRenderer<D> extends BaseSeriesRenderer<D> {
  factory SankeyRenderer({
    String? rendererId,
    SankeyRendererConfig<D>? config,
  }) {
    return SankeyRenderer._internal(
      rendererId: rendererId ?? defaultRendererID,
      config: config ?? SankeyRendererConfig(),
    );
  }

  SankeyRenderer._internal({required super.rendererId, required this.config})
      : super(
          layoutPaintOrder: config.layoutPaintOrder,
          symbolRenderer: config.symbolRenderer,
        );

  /// Default renderer ID for the Sankey Chart
  static const defaultRendererID = 'sankey';

  /// Sankey Renderer Config
  final SankeyRendererConfig<D> config;

  @override
  void preprocessSeries(List<MutableSeries<D>> seriesList) {
    // TODO Populate renderer elements.
  }

  @override
  void update(List<ImmutableSeries<D>> seriesList, bool isAnimating) {
    // TODO Calculate node and link renderer element positions.
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {
    // TODO Paint the renderer elements on the canvas.
  }

  @override
  DatumDetails<D> addPositionToDetailsForSeriesDatum(
    DatumDetails<D> details,
    SeriesDatum<D> seriesDatum,
  ) {
    const chartPosition = Offset(0, 0);
    return DatumDetails.from(
      details,
      chartPosition: NullablePoint.from(chartPosition),
    );
  }

  /// Datum details of nearest links or nodes in the sankey chart.
  @override
  List<DatumDetails<D>> getNearestDatumDetailPerSeries(
    Offset chartPoint,
    bool byDomain,
    Rect? boundsOverride, {
    bool selectOverlappingPoints = false,
    bool selectExactEventLocation = false,
  }) {
    return <DatumDetails<D>>[];
  }
}
