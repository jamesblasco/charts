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

/// [TickProvider] that allows you to provide range ticks and normal ticks.
@immutable
class RangeOrdinalTickProvider extends OrdinalTickProvider {
  const RangeOrdinalTickProvider(this.tickSpecs);
  final List<Tick<String>> tickSpecs;

  @override
  RangeTickProviderElement<String> createElement(ChartContext context) =>
      RangeTickProviderElement<String>(tickSpecs);

  @override
  List<Object?> get props => [tickSpecs];
}

/// A strategy that provides normal ticks and range ticks.
class RangeTickProviderElement<D> extends TickStrategyElement<D> {
  const RangeTickProviderElement(this.tickSpec);
  final List<Tick<D>> tickSpec;

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
    final ticks = <TickElement<D>>[];

    var allTicksHaveLabels = true;

    for (final spec in tickSpec) {
      // When static ticks are being used with a numeric axis, extend the axis
      // with the values specified.
      if (scale is NumericScaleElement || scale is DateTimeScale) {
        scale.addDomain(spec.value);
        if (spec is RangeTickSpec<D>) {
          scale.addDomain(spec.rangeStartValue);
          scale.addDomain(spec.rangeEndValue);
        }
      }

      // Save off whether all ticks have labels.
      allTicksHaveLabels &= spec.label != null;
    }

    // Use the formatter's label if the tick spec does not provide one.
    List<String>? formattedValues;
    if (!allTicksHaveLabels) {
      formattedValues = formatter.format(
        tickSpec.map((spec) => spec.value).toList(),
        formatterValueCache,
        stepSize: scale.domainStepSize,
      );
    }

    for (var i = 0; i < tickSpec.length; i++) {
      final spec = tickSpec[i];
      TickElement<D>? tick;

      if (spec is RangeTickSpec<D>) {
        // If it is a range tick, we still check if the spec's start and end
        // points are within the viewport because we do not extend the axis for
        // OrdinalScale.
        if (scale.compareDomainValueToViewport(spec.rangeStartValue) == 0 &&
            scale.compareDomainValueToViewport(spec.rangeEndValue) == 0) {
          tick = RangeTickElement<D>(
            value: spec.value,
            textElement: graphicsFactory
                .createTextElement(spec.label ?? formattedValues![i]),
            locationPx: (scale[spec.rangeStartValue]! +
                    (scale[spec.rangeEndValue]! -
                            scale[spec.rangeStartValue]!) /
                        2)
                .toDouble(),
            rangeStartValue: spec.rangeStartValue,
            rangeStartLocationPx: scale[spec.rangeStartValue]!.toDouble(),
            rangeEndValue: spec.rangeEndValue,
            rangeEndLocationPx: scale[spec.rangeEndValue]!.toDouble(),
          );
        }
      } else {
        // If it is a normal tick, we still check if the spec is within the
        // viewport because we do not extend the axis for OrdinalScale.
        if (scale.compareDomainValueToViewport(spec.value) == 0) {
          tick = TickElement<D>(
            value: spec.value,
            textElement: graphicsFactory
                .createTextElement(spec.label ?? formattedValues![i]),
            locationPx: scale[spec.value]?.toDouble(),
          );
        }
      }

      if (tick != null) {
        final style = spec.style;
        if (style != null) {
          tick.textElement!.textStyle = style;
        }
        ticks.add(tick);
      }
    }

    // Allow draw strategy to decorate the ticks.
    tickDrawStrategy.decorateTicks(ticks);

    return ticks;
  }

  @override
  List<Object?> get props => [tickSpec];
}
