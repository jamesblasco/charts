import 'package:example/axes/hidden_ticks_and_labels_axis.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'hidden_ticks_and_labels_axis_test',
    (context) => HiddenTicksAndLabelsAxis.withSampleData(),
  );
}
