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
import 'package:meta/meta.dart' show protected;

/// Adds domain axis panning support to a chart.
///
/// Panning is supported by clicking and dragging the mouse for web, or tapping
/// and dragging on the chart for mobile devices.
class PanBehaviorState<D> implements ChartBehaviorState<D> {
  PanBehaviorState() {
    _listener = GestureListener(
      onTapTest: onTapTest,
      onDragStart: onDragStart,
      onDragUpdate: onDragUpdate,
      onDragEnd: onDragEnd,
    );
  }

  /// Listens for drag gestures.
  late GestureListener _listener;

  /// Wrapped domain tick provider for pan and zoom behavior.
  late PanningTickProvider<D> _domainAxisTickProvider;

  @protected
  PanningTickProvider<D> get domainAxisTickProvider => _domainAxisTickProvider;

  @override
  String get role => 'Pan';

  /// The chart to which the behavior is attached.
  CartesianRenderChart<D>? _chart;

  @protected
  CartesianRenderChart<D>? get chart => _chart;

  /// Flag which is enabled to indicate that the user is "panning" the chart.
  bool _isPanning = false;

  @protected
  bool get isPanning => _isPanning;

  /// Last position of the mouse/tap that was used to adjust the scale translate
  /// factor.
  Offset? _lastPosition;

  @protected
  Offset? get lastPosition => _lastPosition;

  /// Optional callback that is invoked at the end of panning ([onPanEnd]).
  PanningCompletedCallback? _panningCompletedCallback;

  set panningCompletedCallback(PanningCompletedCallback? callback) {
    _panningCompletedCallback = callback;
  }

  /// Injects the behavior into a chart.
  @override
  void attachTo(BaseRenderChart<D> chart) {
    if (chart is! CartesianRenderChart<D>) {
      throw ArgumentError(
        'PanBehavior can only be attached to a CartesianChart<D>',
      );
    }

    _chart = chart;
    chart.addGestureListener(_listener);

    // Disable the autoViewport feature to enable panning.
    chart.domainAxis!.autoViewport = false;

    // Wrap domain axis tick provider with the panning behavior one.
    _domainAxisTickProvider =
        PanningTickProvider<D>(chart.domainAxis!.tickProvider!);
    chart.domainAxis!.tickProvider = _domainAxisTickProvider;
  }

  /// Removes the behavior from a chart.
  @override
  void removeFrom(BaseRenderChart<D> chart) {
    if (chart is! CartesianRenderChart<D>) {
      throw ArgumentError(
        'PanBehavior can only be attached to a CartesianChart<D>',
      );
    }

    _chart = chart;
    chart.removeGestureListener(_listener);

    // Restore the default autoViewport state.
    chart.domainAxis!.autoViewport = true;

    // Restore the original tick providers
    chart.domainAxis!.tickProvider = _domainAxisTickProvider.tickProvider;

    _chart = null;
  }

  @protected
  bool onTapTest(Offset localPosition) {
    if (_chart == null) {
      return false;
    }

    return _chart!.withinDrawArea(localPosition);
  }

  @protected
  bool onDragStart(Offset localPosition) {
    if (_chart == null) {
      return false;
    }

    onPanStart();

    _lastPosition = localPosition;
    _isPanning = true;
    return true;
  }

  @protected
  bool onDragUpdate(Offset localPosition, double scale) {
    if (!_isPanning || _lastPosition == null || _chart == null) {
      return false;
    }

    // Pinch gestures should be handled by the [PanAndZoomBehavior].
    if (scale != 1.0) {
      _isPanning = false;
      return false;
    }

    // Update the domain axis's viewport translate to pan the chart.
    final domainAxis = _chart!.domainAxis;

    if (domainAxis == null) {
      return false;
    }

    // This is set during onDragUpdate and NOT onDragStart because we don't yet
    // know during onDragStart whether pan/zoom behavior is panning or zooming.
    // During panning, domain tick provider set to generate ticks with locked
    // steps.
    _domainAxisTickProvider.mode = PanningTickProviderMode.stepSizeLocked;

    final domainScalingFactor = domainAxis.viewportScalingFactor;

    var domainChange = 0.0;
    if (domainAxis.isVertical) {
      domainChange =
          domainAxis.viewportTranslate + localPosition.dy - _lastPosition!.dy;
    } else {
      domainChange =
          domainAxis.viewportTranslate + localPosition.dx - _lastPosition!.dx;
    }

    final chart = this.chart!;
    domainAxis.setViewportSettings(
      domainScalingFactor,
      domainChange,
      drawAreaWidth: chart.drawAreaBounds.width,
      drawAreaHeight: chart.drawAreaBounds.height,
    );

    _lastPosition = localPosition;

    chart.redraw(skipAnimation: true, skipLayout: true);
    return true;
  }

  @protected
  bool onDragEnd(
    Offset localPosition,
    double scale,
    double pixelsPerSec,
  ) {
    onPanEnd();
    return true;
  }

  @protected
  void onPanStart() {
    // When panning starts, measure tick provider should not update ticks.
    // This is still needed because axis internally updates the tick location
    // after the tick provider generates the ticks. If we do not tell the axis
    // not to update the location of the measure axes, we get a jittery effect
    // as the measure axes location changes ever so slightly during pan/zoom.
    _chart!.getMeasureAxis().lockAxis = true;
    _chart!
        .getMeasureAxis(axisId: MutableAxisElement.secondaryMeasureAxisId)
        .lockAxis = true;
  }

  @protected
  void onPanEnd() {
    cancelPanning();

    // When panning stops, allow tick provider to update ticks, and then
    // request redraw.
    _domainAxisTickProvider.mode = PanningTickProviderMode.passThrough;

    final chart = _chart!;
    chart.getMeasureAxis().lockAxis = false;
    chart
        .getMeasureAxis(axisId: MutableAxisElement.secondaryMeasureAxisId)
        .lockAxis = false;
    chart.redraw();

    _panningCompletedCallback?.call();
  }

  /// Cancels the handling of any current panning event.
  void cancelPanning() {
    _isPanning = false;
  }
}

/// Callback for when panning is completed.
typedef PanningCompletedCallback = void Function();
