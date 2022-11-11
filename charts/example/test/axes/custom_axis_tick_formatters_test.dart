import 'package:example/axes/custom_axis_tick_formatters.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'custom_axis_tick_formatters',
    (context) => CustomAxisTickFormatters.withSampleData(),
  );
}
