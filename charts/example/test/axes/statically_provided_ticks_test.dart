import 'package:example/axes/statically_provided_ticks.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'statically_provided_ticks',
    (context) => StaticallyProvidedTicks.withSampleData(),
  );
}
