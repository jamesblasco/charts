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

/// [AxisSpec] specialized for ordinal/non-continuous axes typically for bars.
@immutable
class OrdinalAxisSpec extends AxisSpec<String> {

  /// Creates a [AxisSpec] that specialized for ordinal domain charts.
  ///
  /// [renderSpec] spec used to configure how the ticks and labels
  ///     actually render. Possible values are [GridlineRendererSpec],
  ///     [SmallTickRendererSpec] & [NoneRenderSpec]. Make sure that the <D>
  ///     given to the RenderSpec is of type [String] when using this spec.
  /// [tickProviderSpec] spec used to configure what ticks are generated.
  /// [tickFormatterSpec] spec used to configure how the tick labels are
  ///     formatted.
  /// [showAxisLine] override to force the axis to draw the axis line.
  const OrdinalAxisSpec({
    super.renderSpec,
    OrdinalTickProviderSpec? super.tickProviderSpec,
    OrdinalTickFormatterSpec? super.tickFormatterSpec,
    super.showAxisLine,
    OrdinalScaleSpec? super.scaleSpec,
    this.viewport,
  });
  /// Sets viewport for this Axis.
  ///
  /// If pan / zoom behaviors are set, this is the initial viewport.
  final OrdinalViewport? viewport;

  @override
  void configure(Axis<String> axis, ChartContext context,
      GraphicsFactory graphicsFactory,) {
    super.configure(axis, context, graphicsFactory);

    if (axis is OrdinalAxis && viewport != null) {
      axis.setScaleViewport(viewport!);
    }
  }

  @override
  OrdinalAxis createAxis() => OrdinalAxis();

  @override
  List<Object?> get props => [super.props, viewport];
}

abstract class OrdinalTickProviderSpec extends TickProviderSpec<String> {
  const OrdinalTickProviderSpec();
}

abstract class OrdinalTickFormatterSpec extends TickFormatterSpec<String> {
  const OrdinalTickFormatterSpec();
}

abstract class OrdinalScaleSpec extends ScaleSpec<String> {
  const OrdinalScaleSpec();
}

@immutable
class BasicOrdinalTickProviderSpec extends OrdinalTickProviderSpec {
  const BasicOrdinalTickProviderSpec();

  @override
  OrdinalTickProvider createTickProvider(ChartContext context) =>
      const OrdinalTickProvider();

  @override
  List<Object?> get props => [];
}

/// [TickProviderSpec] that allows you to specify the ticks to be used.
@immutable
class StaticOrdinalTickProviderSpec extends OrdinalTickProviderSpec {

  const StaticOrdinalTickProviderSpec(this.tickSpecs);
  final List<TickSpec<String>> tickSpecs;

  @override
  StaticTickProvider<String> createTickProvider(ChartContext context) =>
      StaticTickProvider<String>(tickSpecs);

  @override
  List<Object?> get props => [tickSpecs];
}

/// [TickProviderSpec] that tries different tick increments to avoid tick
/// collisions.
@immutable
class AutoAdjustingStaticOrdinalTickProviderSpec
    extends OrdinalTickProviderSpec {

  const AutoAdjustingStaticOrdinalTickProviderSpec(
      this.tickSpecs, this.allowedTickIncrements,);
  final List<TickSpec<String>> tickSpecs;
  final List<int> allowedTickIncrements;

  @override
  AutoAdjustingStaticTickProvider<String> createTickProvider(
          ChartContext context,) =>
      AutoAdjustingStaticTickProvider<String>(tickSpecs, allowedTickIncrements);

  @override
  List<Object?> get props => [tickSpecs];
}

/// [TickProviderSpec] that allows you to provide range ticks and normal ticks.
@immutable
class RangeOrdinalTickProviderSpec extends OrdinalTickProviderSpec {
  const RangeOrdinalTickProviderSpec(this.tickSpecs);
  final List<TickSpec<String>> tickSpecs;

  @override
  RangeTickProvider<String> createTickProvider(ChartContext context) =>
      RangeTickProvider<String>(tickSpecs);

  @override
  List<Object?> get props => [tickSpecs];
}

@immutable
class BasicOrdinalTickFormatterSpec extends OrdinalTickFormatterSpec {
  const BasicOrdinalTickFormatterSpec();

  @override
  OrdinalTickFormatter createTickFormatter(ChartContext context) =>
      const OrdinalTickFormatter();

  @override
  List<Object?> get props => [];
}

@immutable
class SimpleOrdinalScaleSpec extends OrdinalScaleSpec {
  const SimpleOrdinalScaleSpec();

  @override
  OrdinalScale createScale() => SimpleOrdinalScale();

  @override
  List<Object?> get props => [];
}

/// [OrdinalScaleSpec] which allows setting space between bars to be a fixed
/// pixel size.
@immutable
class FixedPixelSpaceOrdinalScaleSpec extends OrdinalScaleSpec {

  const FixedPixelSpaceOrdinalScaleSpec(this.pixelSpaceBetweenBars);
  final double pixelSpaceBetweenBars;

  @override
  OrdinalScale createScale() => SimpleOrdinalScale()
    ..rangeBandConfig =
        RangeBandConfig.fixedPixelSpaceBetweenStep(pixelSpaceBetweenBars);

  @override
  List<Object?> get props => [];
}

/// [OrdinalScaleSpec] which allows setting bar width to be a fixed pixel size.
@immutable
class FixedPixelOrdinalScaleSpec extends OrdinalScaleSpec {

  const FixedPixelOrdinalScaleSpec(this.pixels);
  final double pixels;

  @override
  OrdinalScale createScale() => SimpleOrdinalScale()
    ..rangeBandConfig = RangeBandConfig.fixedPixel(pixels);

  @override
  List<Object?> get props => [];
}
