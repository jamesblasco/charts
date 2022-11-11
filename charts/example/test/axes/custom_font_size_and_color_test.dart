import 'package:example/axes/custom_font_size_and_color.dart';

import '../test_case_golden.dart';

void main() {
  testChart(
    'custom_font_size_and_color',
    (context) => CustomFontSizeAndColor.withSampleData(),
  );
}
