// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

/// A Very Good Project created by Very Good CLI.
library charts;

import 'dart:math';
import 'dart:ui';

export 'core.dart';
export 'src/behaviors/behaviors.dart';
export 'src/charts/charts.dart';

extension OffsetPoint on Point<double> {
  Offset get offset => Offset(x, y);
}

extension OffsetPoint2 on Offset {
  Point<double> get point => Point<double>(dx, dy);
}

extension OffsetPointNum on Point<num> {
  Offset get offset => Offset(x.toDouble(), y.toDouble());
}

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
