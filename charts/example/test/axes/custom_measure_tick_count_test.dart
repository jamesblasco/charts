import 'package:example/axes/custom_measure_tick_count.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'custom_measure_tick_count',
    (context) => CustomMeasureTickCount.withSampleData(),
  );
}
