import 'package:example/axes/nonzero_bound_measure_axis.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'nonezero_bound_measure_axis',
    (context) => NonzeroBoundMeasureAxis.withSampleData(),
  );
}
