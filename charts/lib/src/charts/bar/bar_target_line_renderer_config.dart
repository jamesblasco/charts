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

import 'package:charts/charts/bar.dart';

/// Configuration for a bar target line renderer.
class BarTargetLineRendererConfig<D> extends BaseBarRendererConfig<D> {
  BarTargetLineRendererConfig({
    super.barGroupInnerPadding,
    super.customRendererId,
    super.dashPattern,
    super.groupingType,
    int super.layoutPaintOrder = LayoutViewPaintOrder.barTargetLine,
    super.minBarLength,
    this.overDrawOuter,
    this.overDraw = 0,
    this.roundEndCaps = true,
    super.strokeWidth = 3.0,
    SymbolRenderer? symbolRenderer,
    super.weightPattern,
  }) : super(
          symbolRenderer: symbolRenderer ?? const LineSymbolRenderer(),
        );

  /// The number of pixels that the line will extend beyond the bandwidth at the
  /// edges of the bar group.
  ///
  /// If set, this overrides overDraw for the beginning side of the first bar
  /// target line in the group, and the ending side of the last bar target line.
  /// overDraw will be used for overdrawing the target lines for interior
  /// sides of the bars.
  final int? overDrawOuter;

  /// The number of pixels that the line will extend beyond the bandwidth for
  /// every bar in a group.
  final int overDraw;

  /// Whether target lines should have round end caps, or square if false.
  final bool roundEndCaps;

  @override
  BarTargetLineRenderer<D> build() {
    return BarTargetLineRenderer<D>(config: this, rendererId: customRendererId);
  }

  @override
  List<Object?> get props => [
        super.props,
        overDrawOuter,
        overDraw,
        roundEndCaps,
      ];
}
