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
import 'package:flutter/widgets.dart' show BuildContext, Widget;
import 'package:meta/meta.dart' show immutable;

/// Flutter wrapper for chart behaviors.
@immutable
abstract class ChartBehavior<D> extends Equatable {
  Set<GestureType> get desiredGestures;

  ChartBehaviorState<D> createBehaviorState();

  void updateBehaviorState(ChartBehaviorState<D> behaviorState) {}

  String get role;
}

/// A chart behavior that depends on Flutter [State].
abstract class ChartStateBehavior<B extends ChartBehaviorState> {
  set chartState(BaseChartState chartState);
}

/// A chart behavior that can build a Flutter [Widget].
abstract class BuildableBehavior<B extends ChartBehaviorState> {
  /// Builds a [Widget] based on the information passed in.
  ///
  /// [context] Flutter build context for extracting inherited properties such
  /// as Directionality.
  Widget build(BuildContext context);

  /// The position on the widget.
  BehaviorPosition get position;

  /// Justification of the widget, if [position] is top, bottom, start, or end.
  OutsideJustification get outsideJustification;

  /// Justification of the widget if [position] is [BehaviorPosition.inside].
  InsideJustification get insideJustification;

  /// Chart's draw area bounds are used for positioning.
  Rect? get drawAreaBounds;
}

/// Types of gestures accepted by a chart.
enum GestureType {
  onLongPress,
  onTap,
  onHover,
  onDrag,
}
