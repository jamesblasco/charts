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
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show immutable;

@immutable
class AxisData<D> extends Equatable {
  const AxisData({
    this.decoration,
    this.tickProvider,
    this.tickFormatter,
    this.showAxisLine,
    this.scale,
  });

  final bool? showAxisLine;
  final AxisDecoration<D>? decoration;
  final TickProvider<D>? tickProvider;
  final TickFormatter<D>? tickFormatter;
  final Scale<D>? scale;

  void configure(
    MutableAxisElement<D> axis,
    ChartContext context,
    GraphicsFactory graphicsFactory,
  ) {
    axis.resetDefaultConfiguration();

    if (showAxisLine != null) {
      axis.forceDrawAxisLine = showAxisLine;
    }

    if (decoration != null) {
      axis.tickDrawStrategy =
          decoration!.createDrawStrategy(context, graphicsFactory);
    }

    if (tickProvider != null) {
      axis.tickProvider = tickProvider!.createElement(context);
    }

    if (tickFormatter != null) {
      axis.tickFormatter = tickFormatter!.createElement(context);
    }

    if (scale != null) {
      axis.scale = scale!.createElement() as MutableScaleElement<D>;
    }
  }

  /// Creates an appropriately typed [MutableAxisElement].
  MutableAxisElement<D>? createElement() => null;

  @override
  List<Object?> get props => [
        decoration,
        tickProvider,
        tickFormatter,
        showAxisLine,
        scale,
      ];

  AxisData<D> copyWith({
    bool? showAxisLine,
    AxisDecoration<D>? decoration,
    TickProvider<D>? tickProvider,
    TickFormatter<D>? tickFormatter,
    Scale<D>? scale,
  }) {
    return AxisData<D>(
      showAxisLine: showAxisLine ?? this.showAxisLine,
      decoration: decoration ?? this.decoration,
      tickProvider: tickProvider ?? this.tickProvider,
      tickFormatter: tickFormatter ?? this.tickFormatter,
      scale: scale ?? this.scale,
    );
  }
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
