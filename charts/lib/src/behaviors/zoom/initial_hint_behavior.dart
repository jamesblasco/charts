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
import 'package:flutter/widgets.dart' show AnimationController, immutable;

@immutable
class InitialHintBehavior<D> extends ChartBehavior<D> {
  final desiredGestures = Set<GestureType>();

  final Duration? hintDuration;
  final double? maxHintTranslate;
  final double? maxHintScaleFactor;

  InitialHintBehavior(
      {this.hintDuration, this.maxHintTranslate, this.maxHintScaleFactor});

  @override
  InitialHintBehaviorState<D> createBehaviorState() {
    final behavior = FlutterInitialHintBehavior<D>();

    if (hintDuration != null) {
      behavior.hintDuration = hintDuration!;
    }

    if (maxHintTranslate != null) {
      behavior.maxHintTranslate = maxHintTranslate!;
    }

    if (maxHintScaleFactor != null) {
      behavior.maxHintScaleFactor = maxHintScaleFactor!;
    }

    return behavior;
  }

  @override
  void updateBehaviorState(ChartBehaviorState commonBehavior) {}

  @override
  String get role => 'InitialHint';

  @override
  List<Object?> get props => [hintDuration];
}

/// Adds a native animation controller required for [InitialHintBehavior]
/// to function.
class FlutterInitialHintBehavior<D> extends InitialHintBehaviorState<D>
    implements ChartStateBehavior {
  AnimationController? _hintAnimator;

  BaseChartState? _chartState;

  set chartState(BaseChartState chartState) {
    _chartState = chartState;

    _hintAnimator = chartState.getAnimationController(this);
    _hintAnimator?.addListener(onHintTick);
  }

  @override
  void startHintAnimation() {
    super.startHintAnimation();

    _hintAnimator!
      ..duration = hintDuration
      ..forward(from: 0.0);
  }

  @override
  void stopHintAnimation() {
    super.stopHintAnimation();

    _hintAnimator?.stop();
    // Hint animation occurs only on the first draw. The hint animator is no
    // longer needed after the hint animation stops and is removed.
    _chartState!.disposeAnimationController(this);
    _hintAnimator = null;
  }

  @override
  double get hintAnimationPercent => _hintAnimator!.value;

  bool _skippedFirstTick = true;

  @override
  void onHintTick() {
    // Skip the first tick on Flutter because the widget rebuild scheduled
    // during onAnimation fails on an assert on render object in the framework.
    if (_skippedFirstTick) {
      _skippedFirstTick = false;
      return;
    }

    super.onHintTick();
  }

  @override
  removeFrom(BaseRenderChart<D> chart) {
    _chartState!.disposeAnimationController(this);
    _hintAnimator = null;
    super.removeFrom(chart);
  }
}
