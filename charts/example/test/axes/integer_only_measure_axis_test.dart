import 'package:example/axes/integer_only_measure_axis.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'integer_only_measure_axis',
    (context) => IntegerOnlyMeasureAxis.withSampleData(),
  );
}
