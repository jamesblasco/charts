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

import 'package:charts/behaviors.dart';
import 'package:charts/core.dart';
import 'package:meta/meta.dart';

@immutable
class PanAndZoomBehavior<D> extends ChartBehavior<D> {
  PanAndZoomBehavior({this.panningCompletedCallback});
  final _desiredGestures = <GestureType>{
    GestureType.onDrag,
  };

  @override
  Set<GestureType> get desiredGestures => _desiredGestures;

  /// Optional callback that is called when pan / zoom is completed.
  ///
  /// When flinging this callback is called after the fling is completed.
  /// This is because panning is only completed when the flinging stops.
  final PanningCompletedCallback? panningCompletedCallback;

  @override
  PanAndZoomBehaviorState<D> createBehaviorState() {
    return FlutterPanAndZoomBehavior<D>()
      ..panningCompletedCallback = panningCompletedCallback;
  }

  @override
  void updateBehaviorState(ChartBehaviorState commonBehavior) {}

  @override
  String get role => 'PanAndZoom';

  @override
  List<Object?> get props => [panningCompletedCallback];
}

/// Adds fling gesture support to [PanAndZoomBehavior], by way of
/// [FlutterPanBehaviorMixin].
class FlutterPanAndZoomBehavior<D> extends PanAndZoomBehaviorState<D>
    with FlutterPanBehaviorMixin {}
