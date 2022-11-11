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

export 'axis_tick.dart';
export 'range_axis_tick.dart';
export 'range_tick.dart';

/// Definition for a tick.
///
/// Used to define a tick that is used by static tick provider.
class Tick<D> {
  /// [value] the value of this tick
  /// [label] optional label for this tick. If not set, uses the tick formatter
  /// of the axis.
  /// [style] optional style for this tick. If not set, uses the style of the
  /// axis.
  const Tick(this.value, {this.label, this.style});
  final D value;
  final String? label;
  final TextStyle? style;
}

/// A labeled point on an axis.
///
/// [D] is the type of the value this tick is associated with.
class TickElement<D> {
  TickElement({
    required this.value,
    required this.textElement,
    this.location,
    this.labelOffset,
  });

  /// The value that this tick represents
  final D value;

  /// [TextElement] for this tick.
  TextElement? textElement;

  /// Location on the axis where this tick is rendered (in canvas coordinates).
  double? location;

  /// Offset of the label for this tick from its location.
  ///
  /// This is a vertical offset for ticks on a vertical axis, or horizontal
  /// offset for ticks on a horizontal axis.
  double? labelOffset;

  @override
  String toString() => 'Tick(value: $value, location: $location, '
      'labelOffset: $labelOffset)';
}
