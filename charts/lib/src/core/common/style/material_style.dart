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

import 'package:charts/core.dart';

class MaterialChartTheme implements ChartThemeData {
  const MaterialChartTheme();

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
    GraphicsFactory graphicsFactory,
    LineStyle? spec,
  ) {
    return const LineStyle(color: Colors.grey).merge(spec);
  }

  @override
  LineStyle createTickLineStyle(
    GraphicsFactory graphicsFactory,
    LineStyle? spec,
  ) {
    return const LineStyle(color: Colors.grey).merge(spec);
  }

  @override
  int get tickLength => 3;

  @override
  Color get tickColor => Colors.grey.shade800;

  @override
  LineStyle createGridlineStyle(
    GraphicsFactory graphicsFactory,
    LineStyle? spec,
  ) {
    return LineStyle(color: Colors.grey.shade300).merge(spec);
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

class MaterialPalette {
  // Lazily-instantiated iterable, to avoid allocating colors that are not used.
  static final Iterable<MaterialColor> _orderedPalettes = [
    () => Colors.blue,
    () => Colors.red,
    () => Colors.yellow,
    () => Colors.green,
    () => Colors.purple,
    () => Colors.cyan,
    () => Colors.deepOrange,
    () => Colors.lime,
    () => Colors.indigo,
    () => Colors.pink,
    () => Colors.teal
  ].map((f) => f());

  static List<MaterialColor> getOrderedPalettes(int count) {
    return _orderedPalettes.take(count).toList();
  }
}
