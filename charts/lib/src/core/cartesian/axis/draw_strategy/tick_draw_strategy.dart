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
import 'package:meta/meta.dart';

@immutable
abstract class AxisDecoration<D> extends Equatable {
  const AxisDecoration();

  static const NoneAxisDecoration<dynamic> none = NoneAxisDecoration();

  TickDrawStrategy<D> createDrawStrategy(
    ChartContext context,
    GraphicsFactory graphicFactory,
  );
}

/// Strategy for drawing ticks and checking for collisions.
abstract class TickDrawStrategy<D> {
  /// Decorate the existing list of ticks.
  ///
  /// This can be used to further modify ticks after they have been generated
  /// with location data and formatted labels.
  void decorateTicks(List<TickElement<D>> ticks);

  /// Returns a [CollisionReport] indicating if there are any collisions.
  CollisionReport<D> collides(
    List<TickElement<D>>? ticks,
    AxisOrientation? orientation,
  );

  /// Returns measurement of ticks drawn vertically.
  ViewMeasuredSizes measureVerticallyDrawnTicks(
    List<TickElement<D>> ticks,
    double maxWidth,
    double maxHeight, {
    bool collision = false,
  });

  /// Returns measurement of ticks drawn horizontally.
  ViewMeasuredSizes measureHorizontallyDrawnTicks(
    List<TickElement<D>> ticks,
    double maxWidth,
    double maxHeight, {
    bool collision = false,
  });

  /// Updates max tick width to match fit max size.
  void updateTickWidth(
    List<TickElement<D>> ticks,
    double maxWidth,
    double maxHeight,
    AxisOrientation orientation, {
    bool collision = false,
  });

  /// Draws tick onto [ChartCanvas].
  ///
  /// [orientation] the orientation of the axis that this [tick] belongs to.
  /// [axisBounds] the bounds of the axis.
  /// [drawAreaBounds] the bounds of the chart draw area adjacent to the axis.
  /// [collision] whether or not this [tick] should be drawn in such a way to
  /// avoid colliding into other ticks.
  void draw(
    ChartCanvas canvas,
    TickElement<D> tick, {
    required AxisOrientation orientation,
    required Rect axisBounds,
    required Rect drawAreaBounds,
    required bool isFirst,
    required bool isLast,
    bool collision = false,
  });

  void drawAxisLine(
    ChartCanvas canvas,
    AxisOrientation orientation,
    Rect axisBounds,
  );
}
