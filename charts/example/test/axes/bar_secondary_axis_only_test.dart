import 'package:example/axes/bar_secondary_axis_only.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'bar_chart_with_secondary_axis_only',
    (context) => BarChartWithSecondaryAxisOnly.withSampleData(),
  );
}
