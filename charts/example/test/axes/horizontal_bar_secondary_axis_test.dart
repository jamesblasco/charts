import 'package:example/axes/horizontal_bar_secondary_axis.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'horizontal_bar_chart_with_secondary_axis',
    (context) => HorizontalBarChartWithSecondaryAxis.withSampleData(),
  );
}
