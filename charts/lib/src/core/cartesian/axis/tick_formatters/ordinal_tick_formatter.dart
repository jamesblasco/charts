import 'package:charts/charts.dart';
import 'package:meta/meta.dart';

abstract class OrdinalTickFormatter extends TickFormatter<String> {
  const factory OrdinalTickFormatter() = BasicOrdinalTickFormatter;
  const OrdinalTickFormatter.base();
}

@immutable
class BasicOrdinalTickFormatter extends OrdinalTickFormatter {
  const BasicOrdinalTickFormatter() : super.base();

  @override
  OrdinalTickFormatterElement createElement(ChartContext context) {
    return const OrdinalTickFormatterElement();
  }

  @override
  List<Object?> get props => [];
}

/// A strategy that converts tick labels using toString().
class OrdinalTickFormatterElement
    extends BaseSimpleTickFormatterElement<String> {
  const OrdinalTickFormatterElement();

  @override
  String formatValue(String value) => value;
}
