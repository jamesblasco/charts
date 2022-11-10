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

import 'package:meta/meta.dart' show immutable;
import 'package:charts/core.dart';

/// [AxisSpec] specialized for ordinal/non-continuous axes typically for bars.
@immutable
class OrdinalAxisSpec extends AxisSpec<String> {
  /// Sets viewport for this Axis.
  ///
  /// If pan / zoom behaviors are set, this is the initial viewport.
  final OrdinalViewport? viewport;

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
    RenderSpec<String>? renderSpec,
    OrdinalTickProviderSpec? tickProviderSpec,
    OrdinalTickFormatterSpec? tickFormatterSpec,
    bool? showAxisLine,
    OrdinalScaleSpec? scaleSpec,
    this.viewport,
  }) : super(
          renderSpec: renderSpec,
          tickProviderSpec: tickProviderSpec,
          tickFormatterSpec: tickFormatterSpec,
          showAxisLine: showAxisLine,
          scaleSpec: scaleSpec,
        );

  @override
  void configure(Axis<String> axis, ChartContext context,
      GraphicsFactory graphicsFactory) {
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
      OrdinalTickProvider();

  @override
  List<Object?> get props => [];
}

/// [TickProviderSpec] that allows you to specify the ticks to be used.
@immutable
class StaticOrdinalTickProviderSpec extends OrdinalTickProviderSpec {
  final List<TickSpec<String>> tickSpecs;

  const StaticOrdinalTickProviderSpec(this.tickSpecs);

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
  final List<TickSpec<String>> tickSpecs;
  final List<int> allowedTickIncrements;

  const AutoAdjustingStaticOrdinalTickProviderSpec(
      this.tickSpecs, this.allowedTickIncrements);

  @override
  AutoAdjustingStaticTickProvider<String> createTickProvider(
          ChartContext context) =>
      AutoAdjustingStaticTickProvider<String>(tickSpecs, allowedTickIncrements);

  @override
  List<Object?> get props => [tickSpecs];
}

/// [TickProviderSpec] that allows you to provide range ticks and normal ticks.
@immutable
class RangeOrdinalTickProviderSpec extends OrdinalTickProviderSpec {
  final List<TickSpec<String>> tickSpecs;
  const RangeOrdinalTickProviderSpec(this.tickSpecs);

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
      OrdinalTickFormatter();

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
  final double pixelSpaceBetweenBars;

  const FixedPixelSpaceOrdinalScaleSpec(this.pixelSpaceBetweenBars);

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
  final double pixels;

  const FixedPixelOrdinalScaleSpec(this.pixels);

  @override
  OrdinalScale createScale() => SimpleOrdinalScale()
    ..rangeBandConfig = RangeBandConfig.fixedPixel(pixels);

  @override
  List<Object?> get props => [];
}
