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
import 'package:meta/meta.dart' show immutable;

/// Chart behavior that listens to the given eventTrigger and updates the
/// specified [SelectionModel]. This is used to pair input events to behaviors
/// that listen to selection changes.
///
/// Input event types:
///   hover (default) - Mouse over/near data.
///   tap - Mouse/Touch on/near data.
///   pressHold - Mouse/Touch and drag across the data instead of panning.
///   longPressHold - Mouse/Touch for a while in one place then drag across the data.
///
/// SelectionModels that can be updated:
///   info - To view the details of the selected items (ie: hover for web).
///   action - To select an item as an input, drill, or other selection.
///
/// Other options available
///   selectionMode - Optional mode for expanding the selection beyond the
///       nearest datum. Defaults to expandToDomain.
///   selectClosestSeries - mark the series for the closest data point as
///       selected. (Default: true)
///
/// You can add one SelectNearest for each model type that you are updating.
/// Any previous SelectNearest behavior for that selection model will be
/// removed.
@immutable
class SelectNearest<D> extends ChartBehavior<D> {
  final Set<GestureType> desiredGestures;

  final SelectionModelType selectionModelType;
  final SelectionTrigger eventTrigger;
  final SelectionMode selectionMode;
  final bool selectAcrossAllDrawAreaComponents;
  final bool selectClosestSeries;
  final int? maximumDomainDistancePx;

  SelectNearest._internal(
      {required this.selectionModelType,
      this.selectionMode = SelectionMode.expandToDomain,
      this.selectAcrossAllDrawAreaComponents = false,
      this.selectClosestSeries = true,
      required this.eventTrigger,
      required this.desiredGestures,
      this.maximumDomainDistancePx});

  factory SelectNearest(
      {SelectionModelType selectionModelType = SelectionModelType.info,
      SelectionMode selectionMode = SelectionMode.expandToDomain,
      bool selectAcrossAllDrawAreaComponents = false,
      bool selectClosestSeries = true,
      SelectionTrigger eventTrigger = SelectionTrigger.tap,
      int? maximumDomainDistancePx}) {
    return SelectNearest._internal(
        selectionModelType: selectionModelType,
        selectionMode: selectionMode,
        selectAcrossAllDrawAreaComponents: selectAcrossAllDrawAreaComponents,
        selectClosestSeries: selectClosestSeries,
        eventTrigger: eventTrigger,
        desiredGestures: SelectNearest._getDesiredGestures(eventTrigger),
        maximumDomainDistancePx: maximumDomainDistancePx);
  }

  static Set<GestureType> _getDesiredGestures(SelectionTrigger eventTrigger) {
    final desiredGestures = Set<GestureType>();
    switch (eventTrigger) {
      case SelectionTrigger.tap:
        desiredGestures..add(GestureType.onTap);
        break;
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
      case SelectionTrigger.hover:
      default:
        desiredGestures..add(GestureType.onHover);
        break;
    }
    return desiredGestures;
  }

  @override
  SelectNearestState<D> createBehaviorState() {
    return SelectNearestState<D>(
        selectionModelType: selectionModelType,
        eventTrigger: eventTrigger,
        selectionMode: selectionMode,
        selectClosestSeries: selectClosestSeries,
        maximumDomainDistancePx: maximumDomainDistancePx);
  }

  @override
  void updateBehaviorState(ChartBehaviorState commonBehavior) {}

  // TODO: Explore the performance impact of calculating this once
  // at the constructor for this and common ChartBehaviors.
  @override
  String get role => 'SelectNearest-${selectionModelType.toString()}}';

  @override
  List<Object?> get props => [
        selectionModelType,
        eventTrigger,
        selectClosestSeries,
        selectionMode,
        maximumDomainDistancePx
      ];
}
