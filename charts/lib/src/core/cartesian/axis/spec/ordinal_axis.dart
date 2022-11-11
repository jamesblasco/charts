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
import 'package:meta/meta.dart' show immutable;

/// [AxisData] specialized for ordinal/non-continuous axes typically for bars.
@immutable
class OrdinalAxis extends AxisData<String> {
  /// Creates a [AxisData] that specialized for ordinal domain charts.
  ///
  /// [decoration] spec used to configure how the ticks and labels
  ///     actually render. Possible values are [GridlineAxisDecoration],
  ///     [SmallTickAxisDecoration] & [NoneAxisDecoration]. Make sure that the <D>
  ///     given to the RenderSpec is of type [String] when using this spec.
  /// [tickProvider] spec used to configure what ticks are generated.
  /// [tickFormatter] spec used to configure how the tick labels are
  ///     formatted.
  /// [showAxisLine] override to force the axis to draw the axis line.
  const OrdinalAxis({
    super.decoration,
    OrdinalTickProvider? super.tickProvider,
    OrdinalTickFormatter? super.tickFormatter,
    super.showAxisLine,
    OrdinalScale? super.scale,
    this.viewport,
  });

  /// Sets viewport for this Axis.
  ///
  /// If pan / zoom behaviors are set, this is the initial viewport.
  final OrdinalViewport? viewport;

  @override
  void configure(
    MutableAxisElement<String> axis,
    ChartContext context,
    GraphicsFactory graphicsFactory,
  ) {
    super.configure(axis, context, graphicsFactory);

    if (axis is OrdinalAxisElement && viewport != null) {
      axis.setScaleViewport(viewport!);
    }
  }

  @override
  OrdinalAxisElement createElement() => OrdinalAxisElement();

  @override
  List<Object?> get props => [super.props, viewport];
}
