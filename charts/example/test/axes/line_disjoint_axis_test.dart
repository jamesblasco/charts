import 'package:example/axes/line_disjoint_axis.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'disjoint_measure_axis_line_chart',
    (context) => DisjointMeasureAxisLineChart.withSampleData(),
  );
}
