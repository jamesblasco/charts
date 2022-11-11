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

import 'dart:math' show Rectangle;

import 'package:charts/behaviors.dart';
import 'package:charts/core.dart';
import 'package:meta/meta.dart';

/// Chart behavior that adds a slider widget to a chart. When the slider is
/// dropped after drag, it will report its domain position and nearest datum
/// value. This behavior only supports charts that use continuous scales.
///
/// Input event types:
///   tapAndDrag - Mouse/Touch on the handle and drag across the chart.
///   pressHold - Mouse/Touch on the handle and drag across the chart instead of
///       panning.
///   longPressHold - Mouse/Touch for a while on the handle, then drag across
///       the data.
@immutable
class SliderBehavior<D> extends ChartBehavior<D> {
  /// Constructs a [SliderBehavior].
  ///
  /// [eventTrigger] sets the type of gesture handled by the slider.
  ///
  /// [handleRenderer] draws a handle for the slider. Defaults to a rectangle.
  ///
  /// [initialDomainValue] sets the initial position of the slider in domain
  /// units. The default is the center of the chart.
  ///
  /// [onChangeCallback] will be called when the position of the slider
  /// changes during a drag event.
  ///
  /// [snapToDatum] configures the slider to snap snap onto the nearest datum
  /// (by domain distance) when dragged. By default, the slider can be
  /// positioned anywhere along the domain axis.
  ///
  /// [style] configures the color and sizing of the slider line and handle.
  ///
  /// [layoutPaintOrder] configures the order in which the behavior should be
  /// painted. This value should be relative to LayoutPaintViewOrder.slider.
  /// (e.g. LayoutViewPaintOrder.slider + 1).
  factory SliderBehavior({
    SelectionTrigger? eventTrigger,
    SymbolRenderer? handleRenderer,
    dynamic? initialDomainValue,
    String? roleId,
    SliderListenerCallback? onChangeCallback,
    bool snapToDatum = false,
    SliderStyle? style,
    int layoutPaintOrder = LayoutViewPaintOrder.slider,
  }) {
    eventTrigger ??= SelectionTrigger.tapAndDrag;
    handleRenderer ??= const RectSymbolRenderer();
    // Default the handle size large enough to tap on a mobile device.
    style ??= SliderStyle(handleSize: const Rectangle<double>(0, 0, 20, 30));
    return SliderBehavior._internal(
      eventTrigger: eventTrigger,
      handleRenderer: handleRenderer,
      initialDomainValue: initialDomainValue,
      onChangeCallback: onChangeCallback,
      roleId: roleId,
      snapToDatum: snapToDatum,
      style: style,
      desiredGestures: SliderBehavior._getDesiredGestures(eventTrigger),
      layoutPaintOrder: layoutPaintOrder,
    );
  }

  SliderBehavior._internal({
    required this.eventTrigger,
    this.onChangeCallback,
    this.initialDomainValue,
    this.roleId,
    required this.snapToDatum,
    this.style,
    this.handleRenderer,
    required this.desiredGestures,
    this.layoutPaintOrder,
  });
  @override
  final Set<GestureType> desiredGestures;

  /// Type of input event for the slider.
  ///
  /// Input event types:
  ///   tapAndDrag - Mouse/Touch on the handle and drag across the chart.
  ///   pressHold - Mouse/Touch on the handle and drag across the chart instead
  ///       of panning.
  ///   longPressHold - Mouse/Touch for a while on the handle, then drag across
  ///       the data.
  final SelectionTrigger eventTrigger;

  /// The order to paint slider on the canvas.
  ///
  /// The smaller number is drawn first.  This value should be relative to
  /// LayoutPaintViewOrder.slider (e.g. LayoutViewPaintOrder.slider + 1).
  final int? layoutPaintOrder;

  /// Initial domain position of the slider, in domain units.
  final dynamic? initialDomainValue;

  /// Callback function that will be called when the position of the slider
  /// changes during a drag event.
  ///
  /// The callback will be given the current domain position of the slider.
  final SliderListenerCallback? onChangeCallback;

  /// Custom role ID for this slider
  final String? roleId;

  /// Whether or not the slider will snap onto the nearest datum (by domain
  /// distance) when dragged.
  final bool snapToDatum;

  /// Color and size styles for the slider.
  final SliderStyle? style;

  /// Renderer for the handle. Defaults to a rectangle.
  final SymbolRenderer? handleRenderer;

  static Set<GestureType> _getDesiredGestures(SelectionTrigger eventTrigger) {
    final desiredGestures = <GestureType>{};
    switch (eventTrigger) {
      case SelectionTrigger.tapAndDrag:
        desiredGestures
          ..add(GestureType.onTap)
          ..add(GestureType.onDrag);
        break;
      case SelectionTrigger.pressHold:
      case SelectionTrigger.longPressHold:
        desiredGestures
          ..add(GestureType.onTap)
          ..add(GestureType.onLongPress)
          ..add(GestureType.onDrag);
        break;
      default:
        throw ArgumentError(
          'Slider does not support the event trigger ' '"$eventTrigger"',
        );
    }
    return desiredGestures;
  }

  @override
  SliderState<D> createBehaviorState() => SliderState<D>(
        eventTrigger: eventTrigger,
        handleRenderer: handleRenderer,
        initialDomainValue: initialDomainValue as D,
        onChangeCallback: onChangeCallback,
        roleId: roleId,
        snapToDatum: snapToDatum,
        style: style,
      );


  @override
  String get role => 'Slider-${eventTrigger.toString()}';

  @override
  List<Object?> get props => [
        eventTrigger,
        handleRenderer,
        initialDomainValue,
        roleId,
        snapToDatum,
        style,
        layoutPaintOrder
      ];
}
