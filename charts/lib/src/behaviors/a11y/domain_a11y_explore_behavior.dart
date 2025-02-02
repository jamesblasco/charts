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

/// Behavior that generates semantic nodes for each domain.
class DomainA11yExploreBehavior<D> extends ChartBehavior<D> {
  factory DomainA11yExploreBehavior({
    VocalizationCallback? vocalizationCallback,
    ExploreModeTrigger? exploreModeTrigger,
    double? minimumWidth,
    String? exploreModeEnabledAnnouncement,
    String? exploreModeDisabledAnnouncement,
  }) {
    final desiredGestures = <GestureType>{};
    exploreModeTrigger ??= ExploreModeTrigger.pressHold;

    switch (exploreModeTrigger) {
      case ExploreModeTrigger.pressHold:
        desiredGestures.add(GestureType.onLongPress);
        break;
      case ExploreModeTrigger.tap:
        desiredGestures.add(GestureType.onTap);
        break;
    }

    return DomainA11yExploreBehavior._internal(
      vocalizationCallback: vocalizationCallback,
      desiredGestures: desiredGestures,
      exploreModeTrigger: exploreModeTrigger,
      minimumWidth: minimumWidth,
      exploreModeEnabledAnnouncement: exploreModeEnabledAnnouncement,
      exploreModeDisabledAnnouncement: exploreModeDisabledAnnouncement,
    );
  }

  DomainA11yExploreBehavior._internal({
    this.vocalizationCallback,
    this.exploreModeTrigger,
    required this.desiredGestures,
    this.minimumWidth,
    this.exploreModeEnabledAnnouncement,
    this.exploreModeDisabledAnnouncement,
  });

  /// Returns a string for a11y vocalization from a list of series datum.
  final VocalizationCallback? vocalizationCallback;

  @override
  final Set<GestureType> desiredGestures;

  /// The gesture that activates explore mode. Defaults to long press.
  ///
  /// Turning on explore mode asks this [A11yBehavior] to generate nodes within
  /// this chart.
  final ExploreModeTrigger? exploreModeTrigger;

  /// Minimum width of the bounding box for the a11y focus.
  ///
  /// Must be 1 or higher because invisible semantic nodes should not be added.
  final double? minimumWidth;

  /// Optionally notify the OS when explore mode is enabled.
  final String? exploreModeEnabledAnnouncement;

  /// Optionally notify the OS when explore mode is disabled.
  final String? exploreModeDisabledAnnouncement;

  @override
  DomainA11yExploreBehaviorState<D> createBehaviorState() {
    return DomainA11yExploreBehaviorState<D>(
      vocalizationCallback: vocalizationCallback,
      exploreModeTrigger: exploreModeTrigger,
      minimumWidth: minimumWidth,
      exploreModeEnabledAnnouncement: exploreModeEnabledAnnouncement,
      exploreModeDisabledAnnouncement: exploreModeDisabledAnnouncement,
    );
  }

  

  @override
  String get role => 'DomainA11yExplore-$exploreModeTrigger';

  @override
  List<Object?> get props => [
        minimumWidth,
        vocalizationCallback,
        exploreModeTrigger,
        exploreModeEnabledAnnouncement,
        exploreModeDisabledAnnouncement
      ];
}
