// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import '../../../common.dart';
import '../../chart/cartesian/axis/spec/axis_spec.dart' show LineStyleSpec;
import '../color.dart' show Color;
import '../graphics_factory.dart' show GraphicsFactory;
import '../line_style.dart' show LineStyle;
import '../material_palette.dart' show Colors, MaterialPalette;
import '../palette.dart' show Palette;
import 'style.dart' show Style;

class MaterialStyle implements Style {
  const MaterialStyle();

  @override
  Color get black => Colors.black;

  @override
  Color get transparent => Colors.transparent;

  @override
  Color get white => Colors.white;

  @override
  List<MaterialColor> getOrderedPalettes(int count) =>
      MaterialPalette.getOrderedPalettes(count);

  @override
  LineStyle createAxisLineStyle(
      GraphicsFactory graphicsFactory, LineStyleSpec? spec) {
    return graphicsFactory.createLinePaint()
      ..color = spec?.color ?? Colors.grey
      ..dashPattern = spec?.dashPattern
      ..strokeWidth = spec?.thickness ?? 1;
  }

  @override
  LineStyle createTickLineStyle(
      GraphicsFactory graphicsFactory, LineStyleSpec? spec) {
    return graphicsFactory.createLinePaint()
      ..color = spec?.color ?? Colors.grey
      ..dashPattern = spec?.dashPattern
      ..strokeWidth = spec?.thickness ?? 1;
  }

  @override
  int get tickLength => 3;

  @override
  Color get tickColor => Colors.grey.shade800;

  @override
  LineStyle createGridlineStyle(
      GraphicsFactory graphicsFactory, LineStyleSpec? spec) {
    return graphicsFactory.createLinePaint()
      ..color = spec?.color ?? Colors.grey.shade300
      ..dashPattern = spec?.dashPattern
      ..strokeWidth = spec?.thickness ?? 1;
  }

  @override
  Color get arcLabelOutsideLeaderLine => Colors.grey.shade600;

  @override
  Color get defaultSeriesColor => Colors.grey;

  @override
  Color get arcStrokeColor => Colors.white;

  @override
  Color get legendEntryTextColor => Colors.grey.shade800;

  @override
  Color get legendTitleTextColor => Colors.grey.shade800;

  @override
  Color get linePointHighlighterColor => Colors.grey.shade600;

  @override
  Color get noDataColor => Colors.grey.shade200;

  @override
  Color get rangeAnnotationColor => Colors.grey.shade100;

  @override
  Color get sliderFillColor => Colors.white;

  @override
  Color get sliderStrokeColor => Colors.grey.shade600;

  @override
  Color get chartBackgroundColor => Colors.white;

  @override
  double get rangeBandSize => 0.65;
}
