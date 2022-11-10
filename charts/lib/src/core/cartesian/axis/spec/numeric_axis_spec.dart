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

import 'package:charts/src/core/cartesian/axis/tick_formatter.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart' show immutable;
import 'package:charts/core.dart';

/// [AxisSpec] specialized for numeric/continuous axes like the measure axis.
@immutable
class NumericAxisSpec extends AxisSpec<num> {
  /// Sets viewport for this Axis.
  ///
  /// If pan / zoom behaviors are set, this is the initial viewport.
  final NumericExtents? viewport;

  /// Creates a [AxisSpec] that specialized for numeric data.
  ///
  /// [renderSpec] spec used to configure how the ticks and labels
  ///     actually render. Possible values are [GridlineRendererSpec],
  ///     [SmallTickRendererSpec] & [NoneRenderSpec]. Make sure that the <D>
  ///     given to the RenderSpec is of type [num] when using this spec.
  /// [tickProviderSpec] spec used to configure what ticks are generated.
  /// [tickFormatterSpec] spec used to configure how the tick labels are
  ///     formatted.
  /// [showAxisLine] override to force the axis to draw the axis line.
  const NumericAxisSpec({
    RenderSpec<num>? renderSpec,
    NumericTickProviderSpec? tickProviderSpec,
    NumericTickFormatterSpec? tickFormatterSpec,
    bool? showAxisLine,
    ScaleSpec<num>? scaleSpec,
    this.viewport,
  }) : super(
            renderSpec: renderSpec,
            tickProviderSpec: tickProviderSpec,
            tickFormatterSpec: tickFormatterSpec,
            showAxisLine: showAxisLine,
            scaleSpec: scaleSpec);

  factory NumericAxisSpec.from(
    NumericAxisSpec other, {
    RenderSpec<num>? renderSpec,
    TickProviderSpec<num>? tickProviderSpec,
    TickFormatterSpec<num>? tickFormatterSpec,
    bool? showAxisLine,
    ScaleSpec<num>? scaleSpec,
    NumericExtents? viewport,
  }) {
    return NumericAxisSpec(
      renderSpec: renderSpec ?? other.renderSpec,
      tickProviderSpec: (tickProviderSpec ?? other.tickProviderSpec)
          as NumericTickProviderSpec?,
      tickFormatterSpec: (tickFormatterSpec ?? other.tickFormatterSpec)
          as NumericTickFormatterSpec?,
      showAxisLine: showAxisLine ?? other.showAxisLine,
      scaleSpec: scaleSpec ?? other.scaleSpec,
      viewport: viewport ?? other.viewport,
    );
  }

  @override
  void configure(
      Axis<num> axis, ChartContext context, GraphicsFactory graphicsFactory) {
    super.configure(axis, context, graphicsFactory);

    if (axis is NumericAxis && viewport != null) {
      axis.setScaleViewport(viewport!);
    }
  }

  @override
  NumericAxis createAxis() => NumericAxis();

  @override
  List<Object?> get props => [...super.props, viewport];
}

abstract class NumericTickProviderSpec extends TickProviderSpec<num> {
  const NumericTickProviderSpec();
}

abstract class NumericTickFormatterSpec extends TickFormatterSpec<num> {
  const NumericTickFormatterSpec();
}

@immutable
class BasicNumericTickProviderSpec extends NumericTickProviderSpec {
  final bool? zeroBound;
  final bool? dataIsInWholeNumbers;
  final int? desiredTickCount;
  final int? desiredMinTickCount;
  final int? desiredMaxTickCount;

  /// Creates a [TickProviderSpec] that dynamically chooses the number of
  /// ticks based on the extents of the data.
  ///
  /// [zeroBound] automatically include zero in the data range.
  /// [dataIsInWholeNumbers] skip over ticks that would produce
  ///     fractional ticks that don't make sense for the domain (ie: headcount).
  /// [desiredTickCount] the fixed number of ticks to try to make. Convenience
  ///     that sets [desiredMinTickCount] and [desiredMaxTickCount] the same.
  ///     Both min and max win out if they are set along with
  ///     [desiredTickCount].
  /// [desiredMinTickCount] automatically choose the best tick
  ///     count to produce the 'nicest' ticks but make sure we have this many.
  /// [desiredMaxTickCount] automatically choose the best tick
  ///     count to produce the 'nicest' ticks but make sure we don't have more
  ///     than this many.
  const BasicNumericTickProviderSpec(
      {this.zeroBound,
      this.dataIsInWholeNumbers,
      this.desiredTickCount,
      this.desiredMinTickCount,
      this.desiredMaxTickCount});

  @override
  NumericTickProvider createTickProvider(ChartContext context) {
    final provider = NumericTickProvider();
    if (zeroBound != null) {
      provider.zeroBound = zeroBound!;
    }
    if (dataIsInWholeNumbers != null) {
      provider.dataIsInWholeNumbers = dataIsInWholeNumbers!;
    }

    if (desiredMinTickCount != null ||
        desiredMaxTickCount != null ||
        desiredTickCount != null) {
      provider.setTickCount(desiredMaxTickCount ?? desiredTickCount ?? 10,
          desiredMinTickCount ?? desiredTickCount ?? 2);
    }
    return provider;
  }

  @override
  List<Object?> get props => [
        desiredTickCount,
        zeroBound,
        desiredTickCount,
        desiredMinTickCount,
        desiredMaxTickCount
      ];
}

/// [TickProviderSpec] that sets up numeric ticks at the two end points of the
/// axis range.
@immutable
class NumericEndPointsTickProviderSpec extends NumericTickProviderSpec {
  /// Creates a [TickProviderSpec] that dynamically chooses numeric ticks at the
  /// two end points of the axis range
  const NumericEndPointsTickProviderSpec();

  @override
  EndPointsTickProvider<num> createTickProvider(ChartContext context) {
    return EndPointsTickProvider<num>();
  }

  @override
  List<Object?> get props => [];
}

/// [TickProviderSpec] that allows you to specific the ticks to be used.
@immutable
class StaticNumericTickProviderSpec extends NumericTickProviderSpec {
  final List<TickSpec<num>> tickSpecs;

  const StaticNumericTickProviderSpec(this.tickSpecs);

  @override
  StaticTickProvider<num> createTickProvider(ChartContext context) =>
      StaticTickProvider<num>(tickSpecs);

  @override
  List<Object?> get props => [tickSpecs];
}

@immutable
class BasicNumericTickFormatterSpec extends NumericTickFormatterSpec {
  final MeasureFormatter? formatter;
  final NumberFormat? numberFormat;

  /// Simple [TickFormatterSpec] that delegates formatting to the given
  /// [NumberFormat].
  const BasicNumericTickFormatterSpec(this.formatter) : numberFormat = null;

  const BasicNumericTickFormatterSpec.fromNumberFormat(this.numberFormat)
      : formatter = null;

  /// A formatter will be created with the number format if it is not null.
  /// Otherwise, it will create one with the [MeasureFormatter] callback.
  @override
  NumericTickFormatter createTickFormatter(ChartContext context) {
    return numberFormat != null
        ? NumericTickFormatter.fromNumberFormat(numberFormat!)
        : NumericTickFormatter(formatter: formatter);
  }

  @override
  List<Object?> get props => [formatter, numberFormat];
}
