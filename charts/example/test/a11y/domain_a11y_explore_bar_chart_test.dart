import 'package:example/a11y/domain_a11y_explore_bar_chart.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'domain_a11y_explore_bar_chart',
    (context) => DomainA11yExploreBarChart.withSampleData(),
  );
}
