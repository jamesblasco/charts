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
import 'package:charts/charts/link.dart' hide GraphLink;
import 'package:charts/src/core/render/chart_canvas.dart';

const linkElementsKey =
    AttributeKey<List<LinkRendererElement>>('LinkRenderer.elements');

class LinkRenderer<D> extends BaseSeriesRenderer<D> {
  factory LinkRenderer({String? rendererId, LinkRendererConfig<D>? config}) {
    return LinkRenderer._internal(
      rendererId: rendererId ?? defaultRendererID,
      config: config ?? LinkRendererConfig(),
    );
  }

  LinkRenderer._internal({required super.rendererId, required this.config})
      : super(
          layoutPaintOrder: config.layoutPaintOrder,
          symbolRenderer: config.symbolRenderer,
        );

  /// Default renderer ID for the Sankey Chart
  static const defaultRendererID = 'sankey';

  // List of renderer elements to be drawn on the canvas
  final _seriesLinkMap = <String, List<LinkRendererElement>>{};

  /// Link Renderer Config
  final LinkRendererConfig<D> config;

  @override
  void preprocessSeries(List<MutableSeries<D>> seriesList) {
    for (final series in seriesList) {
      final elements = <LinkRendererElement>[];
      for (var linkIndex = 0; linkIndex < series.data.length; linkIndex++) {
        final data = series.data[linkIndex] as LinkRendererElement;
        final element =
            LinkRendererElement(data.link, data.orientation, data.fillColor);
        elements.add(element);
      }
      series.setAttr(linkElementsKey, elements);
    }
  }

  @override
  void update(List<ImmutableSeries<D>> seriesList, bool isAnimating) {
    for (final series in seriesList) {
      final elementsList =
          series.getAttr(linkElementsKey) as List<LinkRendererElement>;
      _seriesLinkMap.putIfAbsent(series.id, () => elementsList);
    }
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {
    /// Paint the renderer elements on the canvas using drawLink.
    _seriesLinkMap.forEach((k, v) => _drawAllLinks(v, canvas));
  }

  void _drawAllLinks(List<LinkRendererElement> links, ChartCanvas canvas) {
    for (final element in links) {
      canvas.drawLink(element.link, element.orientation, element.fillColor);
    }
  }

  @override
  DatumDetails<D> addPositionToDetailsForSeriesDatum(
    DatumDetails<D> details,
    SeriesDatum<D> seriesDatum,
  ) {
    const chartPosition = Point<double>(0, 0);
    return DatumDetails.from(
      details,
      chartPosition: NullablePoint.from(chartPosition),
    );
  }

  /// Datum details of nearest link.
  @override
  List<DatumDetails<D>> getNearestDatumDetailPerSeries(
    Point<double> chartPoint,
    bool byDomain,
    Rectangle<double>? boundsOverride, {
    bool selectOverlappingPoints = false,
    bool selectExactEventLocation = false,
  }) {
    return <DatumDetails<D>>[];
  }
}

class LinkRendererElement {
  LinkRendererElement(this.link, this.orientation, this.fillColor);
  final Link link;
  final LinkOrientation orientation;
  final Color fillColor;
}
