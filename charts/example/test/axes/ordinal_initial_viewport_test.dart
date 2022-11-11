import 'package:example/axes/ordinal_initial_viewport.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'ordinal_initial_viewport',
    (context) => OrdinalInitialViewport.withSampleData(),
  );
}
