import 'package:example/axes/flipped_vertical_axis.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'flipped_vertical_axis',
    (context) => FlippedVerticalAxis.withSampleData(),
  );
}
