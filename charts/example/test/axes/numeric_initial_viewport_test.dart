import 'package:example/axes/numeric_initial_viewport.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'numeric_initial_viewport',
    (context) => NumericInitialViewport.withSampleData(),
  );
}
