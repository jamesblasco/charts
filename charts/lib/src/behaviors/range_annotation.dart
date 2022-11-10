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
import 'package:flutter/material.dart';

/// Chart behavior that annotations domain ranges with a solid fill color.
///
/// The annotations will be drawn underneath series data and chart axes.
///
/// This is typically used for line charts to call out sections of the data
/// range.
@immutable
class RangeAnnotation<D> extends ChartBehavior<D> {

  RangeAnnotation(this.annotations,
      {Color? defaultColor,
      this.defaultLabelAnchor,
      this.defaultLabelDirection,
      this.defaultLabelPosition,
      this.defaultLabelStyleSpec,
      this.extendAxis,
      this.labelPadding,
      this.layoutPaintOrder,})
      : defaultColor = defaultColor ?? Colors.grey.shade100;
  @override
  final desiredGestures = <GestureType>{};

  /// List of annotations to render on the chart.
  final List<AnnotationSegment<Object>> annotations;

  /// Configures where to anchor annotation label text.
  final AnnotationLabelAnchor? defaultLabelAnchor;

  /// Direction of label text on the annotations.
  final AnnotationLabelDirection? defaultLabelDirection;

  /// Configures where to place labels relative to the annotation.
  final AnnotationLabelPosition? defaultLabelPosition;

  /// Configures the style of label text.
  final TextStyleSpec? defaultLabelStyleSpec;

  /// Default color for annotations.
  final Color? defaultColor;

  /// Whether or not the range of the axis should be extended to include the
  /// annotation start and end values.
  final bool? extendAxis;

  /// Space before and after label text.
  final int? labelPadding;

  /// Configures the order in which the behavior should be painted.
  /// This value should be relative to LayoutPaintViewOrder.rangeAnnotation.
  /// (e.g. LayoutViewPaintOrder.rangeAnnotation + 1)
  final int? layoutPaintOrder;

  @override
  RangeAnnotationState<D> createBehaviorState() =>
      RangeAnnotationState<D>(annotations,
          
          defaultLabelAnchor: defaultLabelAnchor,
          defaultLabelDirection: defaultLabelDirection,
          defaultLabelPosition: defaultLabelPosition,
          defaultLabelStyleSpec: defaultLabelStyleSpec,
          extendAxis: extendAxis,
          labelPadding: labelPadding,
          layoutPaintOrder: layoutPaintOrder,);

  @override
  void updateBehaviorState(ChartBehaviorState commonBehavior) {}

  @override
  String get role => 'RangeAnnotation';

  @override
  List<Object?> get props => [
        annotations,
        defaultColor,
        extendAxis,
        defaultLabelAnchor,
        defaultLabelDirection,
        defaultLabelPosition,
        defaultLabelStyleSpec,
        labelPadding,
        layoutPaintOrder
      ];
}
