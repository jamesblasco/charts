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

import 'package:charts/charts.dart';

/// A report that contains a list of ticks and if they collide.

class CollisionReport<D> {
  const CollisionReport({
    required this.ticksCollide,
    required List<TickElement<D>>? ticks,
    bool? alternateTicksUsed,
  })  : ticks = ticks ?? const [],
        alternateTicksUsed = alternateTicksUsed ?? false;

  CollisionReport.empty()
      : ticksCollide = false,
        ticks = [],
        alternateTicksUsed = false;

  /// If [ticks] collide.
  final bool ticksCollide;

  final List<TickElement<D>> ticks;

  final bool alternateTicksUsed;
}
