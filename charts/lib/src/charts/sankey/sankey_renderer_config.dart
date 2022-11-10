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

import 'package:charts/charts/sankey.dart';

/// Configuration for a [SankeyRenderer].
class SankeyRendererConfig<D> extends LayoutViewConfig
    implements SeriesRendererConfig<D> {
  SankeyRendererConfig({
    this.customRendererId,
    this.layoutPaintOrder = LayoutViewPaintOrder.sankey,
    SymbolRenderer? symbolRenderer,
  }) : symbolRenderer = symbolRenderer ?? const RectSymbolRenderer();
  @override
  final String? customRendererId;

  @override
  final SymbolRenderer symbolRenderer;

  @override
  final rendererAttributes = RendererAttributes();

  /// The order to paint this renderer on the canvas.
  final int layoutPaintOrder;

  @override
  SankeyRenderer<D> build() {
    return SankeyRenderer<D>(config: this, rendererId: customRendererId);
  }

  @override
  List<Object?> get props => [
        super.props,
        customRendererId,
        symbolRenderer,
        layoutPaintOrder,
      ];
}
