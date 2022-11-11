import 'package:charts/charts.dart';
import 'package:flutter/material.dart';

/// Tick provider that generates ticks for a [BucketingNumericAxisElement].
///
/// An example illustration of a bucketing measure axis on a point chart
/// follows. In this case, values such as "6%" and "3%" are drawn in the bucket
/// of the axis, since they are less than the [threshold] value of 10%.
///
///  100% ┠─────────────────────────
///       ┃                  *
///       ┃         *
///   50% ┠──────*──────────────────
///       ┃
///       ┠─────────────────────────
/// < 10% ┃   *          *
///       ┗┯━━━━━━━━━━┯━━━━━━━━━━━┯━
///       0         50          100
///
/// This tick provider will generate ticks using the same strategy as
/// [NumericTickProviderElement], except that any ticks that are smaller than
/// [threshold] will be hidden with an empty label. A special tick will be added
/// at the [threshold] position, with a label offset that moves its label down
/// to the middle of the bucket.
@immutable
class BucketingNumericTickProvider extends BasicNumericTickProvider {
  /// Creates a [TickProvider] that generates ticks for a bucketing axis.
  ///
  /// [zeroBound] automatically include zero in the data range.
  /// [dataIsInWholeNumbers] skip over ticks that would produce
  ///     fractional ticks that don't make sense for the domain (ie: headcount).
  /// [desiredTickCount] the fixed number of ticks to try to make. Convenience
  ///     that sets [desiredMinTickCount] and [desiredMaxTickCount] the same.
  ///     Both min and max win out if they are set along with
  ///     [desiredTickCount].
  /// [desiredMinTickCount] automatically choose the best tick
  ///     count to produce the 'nicest' ticks but make sure we have this many.
  /// [desiredMaxTickCount] automatically choose the best tick
  ///     count to produce the 'nicest' ticks but make sure we don't have more
  ///     than this many.
  const BucketingNumericTickProvider({
    bool? zeroBound,
    bool? dataIsInWholeNumbers,
    super.desiredTickCount,
    super.desiredMinTickCount,
    super.desiredMaxTickCount,
  }) : super(
          zeroBound: zeroBound ?? true,
          dataIsInWholeNumbers: dataIsInWholeNumbers ?? false,
        );

  @override
  BucketingNumericTickProviderElement createElement(ChartContext context) {
    final provider = BucketingNumericTickProviderElement()
      ..zeroBound = zeroBound!
      ..dataIsInWholeNumbers = dataIsInWholeNumbers!;

    if (desiredMinTickCount != null ||
        desiredMaxTickCount != null ||
        desiredTickCount != null) {
      provider.setTickCount(
        desiredMaxTickCount ?? desiredTickCount ?? 10,
        desiredMinTickCount ?? desiredTickCount ?? 2,
      );
    }
    return provider;
  }

  @override
  List<Object?> get props => [];
}

/// Tick provider that generates ticks for a [BucketingNumericAxisElement].
///
/// An example illustration of a bucketing measure axis on a point chart
/// follows. In this case, values such as "6%" and "3%" are drawn in the bucket
/// of the axis, since they are less than the [threshold] value of 10%.
///
///  100% ┠─────────────────────────
///       ┃                  *
///       ┃         *
///   50% ┠──────*──────────────────
///       ┃
///       ┠─────────────────────────
/// < 10% ┃   *          *
///       ┗┯━━━━━━━━━━┯━━━━━━━━━━━┯━
///       0         50          100
///
/// This tick provider will generate ticks using the same strategy as
/// [NumericTickProviderElement], except that any ticks that are smaller than
/// [threshold] will be hidden with an empty label. A special tick will be added
/// at the [threshold] position, with a label offset that moves its label down
/// to the middle of the bucket.
class BucketingNumericTickProviderElement extends NumericTickProviderElement {
  /// All values smaller than the threshold will be bucketed into the same
  /// position in the reserved space on the axis.
  num? _threshold;

  set threshold(num threshold) {
    _threshold = threshold;
  }

  /// Whether or not measure values bucketed below the [threshold] should be
  /// visible on the chart, or collapsed.
  bool? _showBucket;

  set showBucket(bool showBucket) {
    _showBucket = showBucket;
  }

  @override
  List<TickElement<num>> getTicks({
    required ChartContext? context,
    required GraphicsFactory graphicsFactory,
    required NumericScaleElement scale,
    required TickFormatterElement<num> formatter,
    required Map<num, String> formatterValueCache,
    required TickDrawStrategy<num> tickDrawStrategy,
    required AxisOrientation? orientation,
    bool viewportExtensionEnabled = false,
    TickHint<num>? tickHint,
  }) {
    final threshold = _threshold;
    final showBucket = _showBucket;

    if (threshold == null) {
      throw ArgumentError(
        'Bucketing threshold must be set before getting ticks.',
      );
    }

    if (showBucket == null) {
      throw ArgumentError(
        'The showBucket flag must be set before getting ticks.',
      );
    }

    final localFormatter = _BucketingFormatter(
      threshold: threshold,
      originalFormatter: formatter as BaseSimpleTickFormatterElement<num>,
    );

    final ticks = super.getTicks(
      context: context,
      graphicsFactory: graphicsFactory,
      scale: scale,
      formatter: localFormatter,
      formatterValueCache: formatterValueCache,
      tickDrawStrategy: tickDrawStrategy,
      orientation: orientation,
      viewportExtensionEnabled: viewportExtensionEnabled,
    );

    // Create a tick for the threshold.
    final thresholdTick = TickElement<num>(
      value: threshold,
      textElement: graphicsFactory
          .createTextElement(localFormatter.formatValue(threshold)),
      locationPx: (showBucket ? scale[threshold] : scale[0])!.toDouble(),
      labelOffsetPx: showBucket ? -0.5 * (scale[threshold]! - scale[0]!) : 0.0,
    );
    tickDrawStrategy.decorateTicks(<TickElement<num>>[thresholdTick]);

    // Filter out ticks that sit below the threshold.
    ticks.removeWhere(
      (TickElement<num> tick) =>
          tick.value <= thresholdTick.value && tick.value != 0.0,
    );

    // Finally, add our threshold tick to the list.
    ticks.add(thresholdTick);

    // Make sure they are sorted by increasing value.
    ticks.sort((a, b) => a.value.compareTo(b.value));
    return ticks;
  }

  @override
  List<Object?> get props => [this];
}

class _BucketingFormatter extends BaseSimpleTickFormatterElement<num> {
  const _BucketingFormatter({
    required this.threshold,
    required this.originalFormatter,
  });

  /// All values smaller than the threshold will be formatted into an empty
  /// string.
  final num threshold;

  final BaseSimpleTickFormatterElement<num> originalFormatter;

  /// Formats a single tick value.
  @override
  String formatValue(num value) {
    if (value < threshold) {
      return '';
    } else if (value == threshold) {
      return '< ${originalFormatter.formatValue(value)}';
    } else {
      return originalFormatter.formatValue(value);
    }
  }

  @override
  List<Object?> get props => [originalFormatter, threshold];
}
