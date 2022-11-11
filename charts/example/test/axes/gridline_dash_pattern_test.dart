import 'package:example/axes/gridline_dash_pattern.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'gridline_dash_pattern',
    (context) => GridlineDashPattern.withSampleData(),
  );
}
