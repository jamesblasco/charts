import 'package:example/axes/short_tick_length_axis.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'short_tick_length_axis',
    (context) => ShortTickLengthAxis.withSampleData(),
  );
}
