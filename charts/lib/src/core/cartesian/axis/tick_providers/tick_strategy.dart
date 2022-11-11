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
import 'package:meta/meta.dart';

@immutable
abstract class TickProvider<D> extends Equatable {
  const TickProvider();
  TickStrategyElement<D> createElement(ChartContext context);
}

/// A strategy for selecting values for axis ticks based on the domain values.
///
/// [D] is the domain type.
abstract class TickStrategyElement<D> {
  const TickStrategyElement();

  /// Returns a list of ticks in value order that should be displayed.
  ///
  /// If no ticks are desired an empty list should be returned.
  ///
  /// [graphicsFactory] The graphics factory used for text measurement.
  /// [scale] The scale of the data.
  /// [formatter] The formatter to use for generating tick labels.
  /// [orientation] Orientation of this axis ticks.
  /// [tickDrawStrategy] Draw strategy for ticks.
  /// [viewportExtensionEnabled] allow extending the viewport for 'niced' ticks.
  /// [tickHint] tick values for provider to calculate a desired tick range.
  List<TickElement<D>> getTicks({
    required ChartContext? context,
    required GraphicsFactory graphicsFactory,
    required covariant MutableScaleElement<D> scale,
    required TickFormatterElement<D> formatter,
    required Map<D, String> formatterValueCache,
    required TickDrawStrategy<D> tickDrawStrategy,
    required AxisOrientation? orientation,
    bool viewportExtensionEnabled = false,
    TickHint<D>? tickHint,
  });
}

/// A base tick provider.
abstract class BaseTickStrategyElement<D> extends TickStrategyElement<D> {
  const BaseTickStrategyElement();

  /// Create ticks from [domainValues].
  List<TickElement<D>> createTicks(
    List<D> domainValues, {
    required ChartContext? context,
    required GraphicsFactory graphicsFactory,
    required MutableScaleElement<D> scale,
    required TickFormatterElement<D> formatter,
    required Map<D, String> formatterValueCache,
    required TickDrawStrategy<D> tickDrawStrategy,
    num? stepSize,
  }) {
    final ticks = <TickElement<D>>[];
    final labels =
        formatter.format(domainValues, formatterValueCache, stepSize: stepSize);

    for (var i = 0; i < domainValues.length; i++) {
      final value = domainValues[i];
      final tick = TickElement(
        value: value,
        textElement: graphicsFactory.createTextElement(labels[i]),
        locationPx: scale[value]?.toDouble(),
      );

      ticks.add(tick);
    }

    // Allow draw strategy to decorate the ticks.
    tickDrawStrategy.decorateTicks(ticks);

    return ticks;
  }
}

/// A hint for the tick provider to determine step size and tick count.
class TickHint<D> {
  TickHint(this.start, this.end, {required this.tickCount});

  /// The starting hint tick value.
  final D start;

  /// The ending hint tick value.
  final D end;

  /// Number of ticks.
  final int tickCount;
}
