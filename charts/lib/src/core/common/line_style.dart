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

const String _kDefaultDebugLabel = 'unknown';

class LineStyle extends Equatable implements PaintStyle {
  const LineStyle({
    this.dashPattern,
    this.strokeWidth = 1,
    this.color,
    this.inherit = true,
    this.debugLabel,
  });

  final List<int>? dashPattern;

  final double strokeWidth;

  @override
  final Color? color;

  final String? debugLabel;

  final bool inherit;

  @override
  List<Object?> get props => [strokeWidth, color, dashPattern];

  LineStyle copyWith({
    List<int>? dashPattern,
    double? strokeWidth,
    Color? color,
    String? debugLabel,
    bool? inherit,
  }) {
    return LineStyle(
      dashPattern: dashPattern ?? this.dashPattern,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      color: color ?? this.color,
      debugLabel: debugLabel ?? this.debugLabel,
      inherit: inherit ?? this.inherit,
    );
  }

  LineStyle merge(LineStyle? other) {
    if (other == null) {
      return this;
    }
    if (!other.inherit) {
      return other;
    }

    String? mergedDebugLabel;
    assert(() {
      if (other.debugLabel != null || debugLabel != null) {
        mergedDebugLabel =
            '(${debugLabel ?? _kDefaultDebugLabel}).merge(${other.debugLabel ?? _kDefaultDebugLabel})';
      }
      return true;
    }());

    return copyWith(
      color: other.color,
      strokeWidth: other.strokeWidth,
      dashPattern: other.dashPattern,
      debugLabel: mergedDebugLabel,
    );
  }
}
