import 'package:example/axes/bar_secondary_axis.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_case_golden.dart';

void main() {
  testChart(
    'bar_secondary_axis',
    (context) => BarChartWithSecondaryAxis.withSampleData(),
  );
}
