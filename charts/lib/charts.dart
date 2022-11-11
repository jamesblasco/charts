// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// A Very Good Project created by Very Good CLI.
library charts;

import 'dart:ui';

export 'core.dart';
export 'src/behaviors/behaviors.dart';
export 'src/charts/charts.dart';

extension RectContains on Rect {
  /// Tests whether [another] is inside or along the edges of `this`.
  /// Differs from [contains] as it includes any point at the bottom
  /// or right edge
  bool containsPoint(Offset point) {
    return point.dx >= left &&
        point.dx <= left + width &&
        point.dy >= top &&
        point.dy <= top + height;
  }
}

extension OffsetDistante on Offset {
  /// Tests whether [another] is inside or along the edges of `this`.
  /// Differs from [contains] as it includes any point at the bottom
  /// or right edge
  double distanceTo(Offset point) {
    return (point - this).distance;
  }
}
