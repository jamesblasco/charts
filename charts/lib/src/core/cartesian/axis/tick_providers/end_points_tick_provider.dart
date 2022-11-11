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

/// [TickProvider] that sets up numeric ticks at the two end points of the
/// axis range.
@immutable
class NumericEndPointsTickProvider extends NumericTickProvider {
  /// Creates a [TickProvider] that dynamically chooses numeric ticks at the
  /// two end points of the axis range
  const NumericEndPointsTickProvider() : super.base();

  @override
  EndPointsTickProviderElement<num> createElement(ChartContext context) {
    return EndPointsTickProviderElement<num>();
  }

  @override
  List<Object?> get props => [];
}

/// Tick provider that provides ticks at the two end points of the axis range.
class EndPointsTickProviderElement<D> extends BaseTickStrategyElement<D> {
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

    // Check to see if the axis has been configured with some domain values.
    //
    // An un-configured axis has no domain step size, and its scale defaults to
    // infinity.
    if (scale.domainStepSize.abs() != double.infinity) {
      final start = _getStartValue(tickHint, scale);
      final end = _getEndValue(tickHint, scale);

      final labels = formatter.format(
        [start, end],
        formatterValueCache,
        stepSize: scale.domainStepSize,
      );

      if (start != null) {
        ticks.add(
          TickElement(
            value: start,
            textElement: graphicsFactory.createTextElement(labels[0]),
            locationPx: scale[start]?.toDouble(),
          ),
        );
      }

      if (end != null) {
        ticks.add(
          TickElement(
            value: end,
            textElement: graphicsFactory.createTextElement(labels[1]),
            locationPx: scale[end]?.toDouble(),
          ),
        );
      }

      // Allow draw strategy to decorate the ticks.
      tickDrawStrategy.decorateTicks(ticks);
    }

    return ticks;
  }

  /// Get the start value from the scale.
  D _getStartValue(TickHint<D>? tickHint, MutableScaleElement<D> mutableScale) {
    Object? start;

    if (tickHint != null) {
      start = tickHint.start;
    } else {
      // Upcast to allow type promotion.
      // See https://github.com/dart-lang/sdk/issues/34018.
      // ignore: unnecessary_cast
      final scale = mutableScale as ScaleElement;
      if (scale is NumericScaleElement) {
        start = scale.viewportDomain.min;
      } else if (scale is DateTimeScale) {
        start = scale.viewportDomain.start;
      } else if (scale is OrdinalScaleElement) {
        start = scale.domain.first;
      } else {
        throw UnsupportedError('Unrecognized scale: {scale.runtimeType}');
      }
    }

    return start as D;
  }

  /// Get the end value from the scale.
  D _getEndValue(TickHint<D>? tickHint, MutableScaleElement<D> mutableScale) {
    Object? end;

    if (tickHint != null) {
      end = tickHint.end;
    } else {
      // Upcast to allow type promotion.
      // See https://github.com/dart-lang/sdk/issues/34018.
      // ignore: unnecessary_cast
      final scale = mutableScale as ScaleElement;
      if (scale is NumericScaleElement) {
        end = scale.viewportDomain.max;
      } else if (scale is DateTimeScale) {
        end = scale.viewportDomain.end;
      } else if (scale is OrdinalScaleElement) {
        end = scale.domain.last;
      } else {
        throw UnsupportedError('Unrecognized scale: {scale.runtimeType}');
      }
    }

    return end as D;
  }
}
