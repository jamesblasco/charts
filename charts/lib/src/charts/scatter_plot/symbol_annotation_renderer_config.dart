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

import 'package:charts/charts/scatter_plot.dart';

/// Configuration for [SymbolAnnotationRenderer].
///
/// This renderer is configured with a [ComparisonPointsDecorator] by default,
/// used to draw domain ranges. This decorator will draw a rectangular shape
/// between the points (domainLowerBound, measureLowerBound) and
/// (domainUpperBound, measureUpperBound), beneath the primary point for each
/// series.
class SymbolAnnotationRendererConfig<D> extends PointRendererConfig<D> {
  SymbolAnnotationRendererConfig({
    super.customRendererId,
    List<PointRendererDecorator<D>>? pointRendererDecorators,
    super.radius = 5.0,
    super.symbolRenderer,
    super.customSymbolRenderers,
    this.showBottomSeparatorLine = false,
    this.showSeparatorLines = true,
    this.verticalSymbolBottomPadding = 5.0,
    this.verticalSymbolTopPadding = 5.0,
  }) : super(
          pointRendererDecorators: pointRendererDecorators ??
              [
                ComparisonPointsDecorator<D>(
                  symbolRenderer: RectangleRangeSymbolRenderer(),
                )
              ],
        );

  /// Whether a separator line should be drawn between the bottom row of
  /// rendered symbols and the axis ticks/labels.
  final bool showBottomSeparatorLine;

  /// Whether or not separator lines will be rendered between rows of rendered
  /// symbols.
  final bool showSeparatorLines;

  /// Space reserved at the bottom of each row where the symbol should not
  /// render into.
  final double verticalSymbolBottomPadding;

  /// Space reserved at the top of each row where the symbol should not render
  /// into.
  final double verticalSymbolTopPadding;

  @override
  SymbolAnnotationRenderer<D> build() {
    return SymbolAnnotationRenderer<D>(
      config: this,
      rendererId: customRendererId,
    );
  }
}
