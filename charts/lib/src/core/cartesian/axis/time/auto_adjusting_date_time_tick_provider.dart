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

/// Tick provider for date and time.
///
/// When determining the ticks for a given domain, the provider will use choose
/// one of the internal tick providers appropriate to the size of the data's
/// domain range.  It does this in an attempt to ensure there are at least 3
/// ticks, before jumping to the next more fine grain provider.  The 3 tick
/// minimum is not a hard rule as some of the ticks might be eliminated because
/// of collisions, but the data was within the targeted range.
///
/// Once a tick provider is chosen the selection of ticks is done by the child
/// tick provider.
class AutoAdjustingDateTimeTickProvider extends TickStrategyElement<DateTime> {
  AutoAdjustingDateTimeTickProvider._internal(
    List<TimeRangeTickProviderElement> tickProviders,
  )   : assert(tickProviders.isNotEmpty),
        _potentialTickProviders = tickProviders;

  /// Creates a default [AutoAdjustingDateTimeTickProvider] for day and time.
  factory AutoAdjustingDateTimeTickProvider.createDefault(
    DateTimeFactory dateTimeFactory,
  ) {
    return AutoAdjustingDateTimeTickProvider._internal([
      createYearTickProvider(dateTimeFactory),
      createMonthTickProvider(dateTimeFactory),
      createDayTickProvider(dateTimeFactory),
      createHourTickProvider(dateTimeFactory),
      createMinuteTickProvider(dateTimeFactory)
    ]);
  }

  /// Creates a default [AutoAdjustingDateTimeTickProvider] for day only.
  factory AutoAdjustingDateTimeTickProvider.createWithoutTime(
    DateTimeFactory dateTimeFactory,
  ) {
    return AutoAdjustingDateTimeTickProvider._internal([
      createYearTickProvider(dateTimeFactory),
      createMonthTickProvider(dateTimeFactory),
      createDayTickProvider(dateTimeFactory)
    ]);
  }

  /// Creates [AutoAdjustingDateTimeTickProvider] with custom tick providers.
  ///
  /// [potentialTickProviders] must have at least one [TimeRangeTickProviderElement]
  /// and this list of tick providers are used in the order they are provided.
  factory AutoAdjustingDateTimeTickProvider.createWith(
    List<TimeRangeTickProviderElement> potentialTickProviders,
  ) {
    if (potentialTickProviders.isEmpty) {
      throw ArgumentError('At least one TimeRangeTickProvider is required');
    }

    return AutoAdjustingDateTimeTickProvider._internal(potentialTickProviders);
  }

  /// List of tick providers to be selected from.
  final List<TimeRangeTickProviderElement> _potentialTickProviders;

  /// Generates a list of ticks for the given data which should not collide
  /// unless the range is not large enough.
  @override
  List<TickElement<DateTime>> getTicks({
    required ChartContext? context,
    required GraphicsFactory graphicsFactory,
    required DateTimeScale scale,
    required TickFormatterElement<DateTime> formatter,
    required Map<DateTime, String> formatterValueCache,
    required TickDrawStrategy<DateTime> tickDrawStrategy,
    required AxisOrientation? orientation,
    bool viewportExtensionEnabled = false,
    TickHint<DateTime>? tickHint,
  }) {
    List<TimeRangeTickProviderElement> tickProviders;

    /// If tick hint is provided, use the closest tick provider, otherwise
    /// look through the tick providers for one that provides sufficient ticks
    /// for the viewport.
    if (tickHint != null) {
      tickProviders = [_getClosestTickProvider(tickHint)];
    } else {
      tickProviders = _potentialTickProviders;
    }

    final lastTickProvider = tickProviders.last;

    final viewport = scale.viewportDomain;
    for (final tickProvider in tickProviders) {
      final isLastProvider = tickProvider == lastTickProvider;
      if (isLastProvider ||
          tickProvider.providesSufficientTicksForRange(viewport)) {
        return tickProvider.getTicks(
          context: context,
          graphicsFactory: graphicsFactory,
          scale: scale,
          formatter: formatter,
          formatterValueCache: formatterValueCache,
          tickDrawStrategy: tickDrawStrategy,
          orientation: orientation,
        );
      }
    }

    return <TickElement<DateTime>>[];
  }

  /// Find the closest tick provider based on the tick hint.
  TimeRangeTickProviderElement _getClosestTickProvider(
      TickHint<DateTime> tickHint,) {
    final stepSize = ((tickHint.end.difference(tickHint.start).inMilliseconds) /
            (tickHint.tickCount - 1))
        .round();

    int? minDifference;
    late TimeRangeTickProviderElement closestTickProvider;

    assert(_potentialTickProviders.isNotEmpty);
    for (final tickProvider in _potentialTickProviders) {
      final difference =
          (stepSize - tickProvider.getClosestStepSize(stepSize)).abs();
      if (minDifference == null || minDifference > difference) {
        minDifference = difference;
        closestTickProvider = tickProvider;
      }
    }
    assert(minDifference != null);
    return closestTickProvider;
  }

  static TimeRangeTickProviderElement createYearTickProvider(
    DateTimeFactory dateTimeFactory,
  ) =>
      TimeRangeTickProviderImplElement(YearTimeStepper(dateTimeFactory));

  static TimeRangeTickProviderElement createMonthTickProvider(
    DateTimeFactory dateTimeFactory,
  ) =>
      TimeRangeTickProviderImplElement(MonthTimeStepper(dateTimeFactory));

  static TimeRangeTickProviderElement createDayTickProvider(
    DateTimeFactory dateTimeFactory,
  ) =>
      TimeRangeTickProviderImplElement(DayTimeStepper(dateTimeFactory));

  static TimeRangeTickProviderElement createHourTickProvider(
    DateTimeFactory dateTimeFactory,
  ) =>
      TimeRangeTickProviderImplElement(HourTimeStepper(dateTimeFactory));

  static TimeRangeTickProviderElement createMinuteTickProvider(
    DateTimeFactory dateTimeFactory,
  ) =>
      TimeRangeTickProviderImplElement(MinuteTimeStepper(dateTimeFactory));

  @override
  List<Object?> get props => [_potentialTickProviders];
}
