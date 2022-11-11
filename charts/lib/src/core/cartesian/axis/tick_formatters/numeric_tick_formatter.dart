import 'package:charts/charts.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

abstract class NumericTickFormatter extends TickFormatter<num> {
  const factory NumericTickFormatter(
    MeasureFormatter? formatter,
  ) = BasicNumericTickFormatter;
  const factory NumericTickFormatter.fromFormat(
    NumberFormat format,
  ) = IntlNumericTickFormatter;
  const NumericTickFormatter.base();
}

@immutable
class BasicNumericTickFormatter extends NumericTickFormatter {
  /// Simple [TickFormatter] that delegates formatting to the given
  /// [NumberFormat].
  const BasicNumericTickFormatter(this.formatter) : super.base();

  final MeasureFormatter? formatter;

  /// A formatter will be created with the number format if it is not null.
  /// Otherwise, it will create one with the [MeasureFormatter] callback.
  @override
  NumericTickFormatterElement createElement(ChartContext context) {
    return NumericTickFormatterElement(formatter: formatter);
  }

  @override
  List<Object?> get props => [formatter];
}

@immutable
class IntlNumericTickFormatter extends NumericTickFormatter {
  const IntlNumericTickFormatter(this.numberFormat) : super.base();

  final NumberFormat numberFormat;

  /// A formatter will be created with the number format if it is not null.
  /// Otherwise, it will create one with the [MeasureFormatter] callback.
  @override
  NumericTickFormatterElement createElement(ChartContext context) {
    return NumericTickFormatterElement.fromNumberFormat(numberFormat);
  }

  @override
  List<Object?> get props => [numberFormat];
}

/// A strategy for formatting the labels on numeric ticks using [NumberFormat].
///
/// The default format is [NumberFormat.decimalPattern].
class NumericTickFormatterElement extends BaseSimpleTickFormatterElement<num> {
  /// Construct a a new [NumericTickFormatterElement].
  ///
  /// [formatter] optionally specify a formatter to be used. Defaults to using
  /// [NumberFormat.decimalPattern] if none is specified.
  factory NumericTickFormatterElement({MeasureFormatter? formatter}) {
    formatter ??= _getFormatter(NumberFormat.decimalPattern());
    return NumericTickFormatterElement._internal(formatter);
  }

  /// Constructs a new [NumericTickFormatterElement] that formats using [numberFormat].
  factory NumericTickFormatterElement.fromNumberFormat(
    NumberFormat numberFormat,
  ) {
    return NumericTickFormatterElement._internal(_getFormatter(numberFormat));
  }

  const NumericTickFormatterElement._internal(this.formatter);
  final MeasureFormatter formatter;

  /// Returns a [MeasureFormatter] that calls format on [numberFormat].
  static MeasureFormatter _getFormatter(NumberFormat numberFormat) {
    return (num? value) => (value == null) ? '' : numberFormat.format(value);
  }

  @override
  String formatValue(num value) => formatter(value);
}
