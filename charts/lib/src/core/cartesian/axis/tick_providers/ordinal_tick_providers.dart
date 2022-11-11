import 'package:charts/charts.dart';
import 'package:meta/meta.dart';

abstract class OrdinalTickProvider extends TickProvider<String> {
  const OrdinalTickProvider();
}

@immutable
class BasicOrdinalTickProvider extends OrdinalTickProvider {
  const BasicOrdinalTickProvider();

  @override
  OrdinalTickProviderElement createElement(ChartContext context) =>
      const OrdinalTickProviderElement();

  @override
  List<Object?> get props => [];
}

/// A strategy for selecting ticks to draw given ordinal domain values.
class OrdinalTickProviderElement extends BaseTickStrategyElement<String> {
  const OrdinalTickProviderElement();

  @override
  List<TickElement<String>> getTicks({
    required ChartContext? context,
    required GraphicsFactory graphicsFactory,
    required OrdinalScaleElement scale,
    required TickFormatterElement<String> formatter,
    required Map<String, String> formatterValueCache,
    required TickDrawStrategy<String> tickDrawStrategy,
    required AxisOrientation? orientation,
    bool viewportExtensionEnabled = false,
    TickHint<String>? tickHint,
  }) {
    return createTicks(
      scale.domain.domains,
      context: context,
      graphicsFactory: graphicsFactory,
      scale: scale,
      formatter: formatter,
      formatterValueCache: formatterValueCache,
      tickDrawStrategy: tickDrawStrategy,
    );
  }
}
