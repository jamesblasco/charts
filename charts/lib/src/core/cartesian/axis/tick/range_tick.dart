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

/// Definition for a range tick.
///
/// Used to define a tick that is used by range tick provider.
class RangeTickSpec<D> extends Tick<D> {
  /// Creates a range tick for [value].
  /// A [label] optionally labels this tick. If not set, the tick formatter
  /// formatter of the axis is used.
  /// A [style] optionally sets the style for this tick. If not set, the style
  /// of the axis is used.
  /// A [rangeStartValue] represents value of this range tick's starting point.
  /// A [rangeEndValue] represents the value of this range tick's ending point.
  const RangeTickSpec(
    super.value, {
    super.label,
    super.style,
    required this.rangeStartValue,
    required this.rangeEndValue,
  });
  final D rangeStartValue;
  final D rangeEndValue;
}

/// A labeled range on an axis.
///
/// [D] is the type of the value this tick is associated with.
class RangeTickElement<D> extends TickElement<D> {
  RangeTickElement({
    required super.value,
    required TextElement super.textElement,
    super.location,
    super.labelOffset,
    required this.rangeStartValue,
    required this.rangeStartLocation,
    required this.rangeEndValue,
    required this.rangeEndLocation,
  });

  /// The value that this range tick starting point represents
  final D rangeStartValue;

  /// Position of the range tick starting point.
  double rangeStartLocation;

  /// The value that this range tick ending point represents.
  final D rangeEndValue;

  /// Position of the range tick ending point.
  double rangeEndLocation;

  @override
  String toString() => 'RangeTick(value: $value, location: $location, '
      'labelOffset: $labelOffset, rangeStartValue: $rangeStartValue, '
      'rangeStartLocation: $rangeStartLocation, '
      'rangeEndValue: $rangeEndValue,  rangeEndLocation: $rangeEndLocation)';
}
