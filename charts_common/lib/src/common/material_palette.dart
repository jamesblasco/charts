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

import 'package:charts/charts.dart';

import 'color.dart' show Color;
import 'palette.dart' show Palette;

/// A canonical palette of colors from material.io.
///
/// @link https://material.io/guidelines/style/color.html#color-color-palette
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
