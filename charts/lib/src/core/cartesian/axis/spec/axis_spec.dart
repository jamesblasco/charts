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

import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show immutable;

import 'package:charts/core.dart';

@immutable
class AxisSpec<D> extends Equatable {
  final bool? showAxisLine;
  final RenderSpec<D>? renderSpec;
  final TickProviderSpec<D>? tickProviderSpec;
  final TickFormatterSpec<D>? tickFormatterSpec;
  final ScaleSpec<D>? scaleSpec;

  const AxisSpec({
    this.renderSpec,
    this.tickProviderSpec,
    this.tickFormatterSpec,
    this.showAxisLine,
    this.scaleSpec,
  });

  factory AxisSpec.from(
    AxisSpec<D> other, {
    RenderSpec<D>? renderSpec,
    TickProviderSpec<D>? tickProviderSpec,
    TickFormatterSpec<D>? tickFormatterSpec,
    bool? showAxisLine,
    ScaleSpec<D>? scaleSpec,
  }) {
    return AxisSpec(
      renderSpec: renderSpec ?? other.renderSpec,
      tickProviderSpec: tickProviderSpec ?? other.tickProviderSpec,
      tickFormatterSpec: tickFormatterSpec ?? other.tickFormatterSpec,
      showAxisLine: showAxisLine ?? other.showAxisLine,
      scaleSpec: scaleSpec ?? other.scaleSpec,
    );
  }

  void configure(
      Axis<D> axis, ChartContext context, GraphicsFactory graphicsFactory) {
    axis.resetDefaultConfiguration();

    if (showAxisLine != null) {
      axis.forceDrawAxisLine = showAxisLine;
    }

    if (renderSpec != null) {
      axis.tickDrawStrategy =
          renderSpec!.createDrawStrategy(context, graphicsFactory);
    }

    if (tickProviderSpec != null) {
      axis.tickProvider = tickProviderSpec!.createTickProvider(context);
    }

    if (tickFormatterSpec != null) {
      axis.tickFormatter = tickFormatterSpec!.createTickFormatter(context);
    }

    if (scaleSpec != null) {
      axis.scale = scaleSpec!.createScale() as MutableScale<D>;
    }
  }

  /// Creates an appropriately typed [Axis].
  Axis<D>? createAxis() => null;

  @override
  List<Object?> get props => [
        renderSpec,
        tickProviderSpec,
        tickFormatterSpec,
        showAxisLine,
        scaleSpec
      ];
}

@immutable
abstract class TickProviderSpec<D> extends Equatable {
  const TickProviderSpec();
  TickProvider<D> createTickProvider(ChartContext context);
}

@immutable
abstract class TickFormatterSpec<D> extends Equatable {
  const TickFormatterSpec();
  TickFormatter<D> createTickFormatter(ChartContext context);
}

@immutable
abstract class ScaleSpec<D> extends Equatable {
  const ScaleSpec();
  Scale<D> createScale();
}

@immutable
abstract class RenderSpec<D> extends Equatable {
  const RenderSpec();

  TickDrawStrategy<D> createDrawStrategy(
      ChartContext context, GraphicsFactory graphicFactory);
}

enum TickLabelAnchor {
  before,
  centered,
  after,

  /// The top most tick draws all text under the location.
  /// The bottom most tick draws all text above the location.
  /// The rest of the ticks are centered.
  inside,
}

enum TickLabelJustification {
  inside,
  outside,
}
