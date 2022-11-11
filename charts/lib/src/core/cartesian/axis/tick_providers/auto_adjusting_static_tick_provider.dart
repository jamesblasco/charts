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
import 'package:meta/meta.dart';

/// [TickProvider] that tries different tick increments to avoid tick
/// collisions.
@immutable
class AutoAdjustingStaticOrdinalTickProvider extends OrdinalTickProvider {
  const AutoAdjustingStaticOrdinalTickProvider(
    this.tickSpecs,
    this.allowedTickIncrements,
  );
  final List<Tick<String>> tickSpecs;
  final List<int> allowedTickIncrements;

  @override
  AutoAdjustingStaticTickProviderElement<String> createElement(
    ChartContext context,
  ) =>
      AutoAdjustingStaticTickProviderElement<String>(
        tickSpecs,
        allowedTickIncrements,
      );

  @override
  List<Object?> get props => [tickSpecs];
}

/// A strategy that selects ticks without them colliding.
///
/// It selects every Nth tick, where N is the smallest tick increment from
/// [allowedTickIncrements] such that ticks do not collide. If no such increment
/// exists, ticks for the first step increment are returned;
///
/// The [TextStyle] is not overridden during
/// [TickDrawStrategy.decorateTicks].
/// If the [Tick] style is null, then the default [TextStyle] is used.
class AutoAdjustingStaticTickProviderElement<D> extends TickStrategyElement<D> {
  const AutoAdjustingStaticTickProviderElement(
    this.tickSpec,
    this.allowedTickIncrements,
  );
  final List<Tick<D>> tickSpec;
  final List<int> allowedTickIncrements;

  @override
  List<TickElement<D>> getTicks({
    required ChartContext? context,
    required GraphicsFactory graphicsFactory,
    required MutableScaleElement<D> scale,
    required TickFormatterElement<D> formatter,
    required Map<D, String> formatterValueCache,
    required TickDrawStrategy<D> tickDrawStrategy,
    required AxisOrientation? orientation,
    bool viewportExtensionEnabled = false,
    TickHint<D>? tickHint,
  }) {
    var ticksForTheFirstIncrement = <TickElement<D>>[];
    for (final tickIncrement in allowedTickIncrements) {
      final staticTickProvider =
          StaticTickProviderElement(tickSpec, tickIncrement: tickIncrement);
      final ticks = staticTickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: formatterValueCache,
        tickDrawStrategy: tickDrawStrategy,
        orientation: orientation,
        viewportExtensionEnabled: viewportExtensionEnabled,
        tickHint: tickHint,
      );
      if (ticksForTheFirstIncrement.isEmpty) {
        ticksForTheFirstIncrement = ticks;
      }
      final collisionReport = tickDrawStrategy.collides(ticks, orientation);
      if (!collisionReport.ticksCollide) {
        // Return the first non colliding ticks.
        return ticks;
      }
    }
    return ticksForTheFirstIncrement;
  }
}
