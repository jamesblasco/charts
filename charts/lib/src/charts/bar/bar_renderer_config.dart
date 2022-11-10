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
import 'package:equatable/equatable.dart';

/// Configuration for a bar renderer.
class BarRendererConfig<D> extends BaseBarRendererConfig<D> {

  BarRendererConfig({
    super.barGroupInnerPaddingPx,
    super.customRendererId,
    CornerStrategy? cornerStrategy,
    super.fillPattern,
    BarGroupingType? groupingType,
    int super.layoutPaintOrder = LayoutViewPaintOrder.bar,
    super.minBarLengthPx,
    super.maxBarWidthPx,
    super.stackedBarPaddingPx,
    super.strokeWidthPx,
    this.barRendererDecorator,
    super.symbolRenderer,
    super.weightPattern,
  })  : cornerStrategy = cornerStrategy ?? const ConstCornerStrategy(2),
        super(
          groupingType: groupingType ?? BarGroupingType.grouped,
        );
  /// Strategy for determining the corner radius of a bar.
  final CornerStrategy cornerStrategy;

  /// Decorator for optionally decorating painted bars.
  final BarRendererDecorator<D>? barRendererDecorator;

  @override
  BarRenderer<D> build() {
    return BarRenderer<D>(config: this, rendererId: customRendererId);
  }

  @override
  List<Object?> get props => [super.props, cornerStrategy];
}

abstract class CornerStrategy extends Equatable {
  const CornerStrategy();

  /// Returns the radius of the rounded corners in pixels.
  int getRadius(int barWidth);
}

/// Strategy for constant corner radius.
class ConstCornerStrategy extends CornerStrategy {

  const ConstCornerStrategy(this.radius);
  final int radius;

  @override
  int getRadius(_) => radius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ConstCornerStrategy && other.radius == radius;
  }

  @override
  List<Object?> get props => [radius];




}

/// Strategy for no corner radius.
class NoCornerStrategy extends ConstCornerStrategy {
  const NoCornerStrategy() : super(0);

}
