// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'package:charts/charts.dart';
import 'package:flutter/material.dart';

/// {@template charts}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
///
export 'package:flutter/material.dart' show Color, Colors, MaterialColor;

class Charts {
  /// {@macro charts}
  const Charts();
}

extension DarkerColor on Color {
  static const _darkerPercentOfOrig = 0.7;
  static const _lighterPercentOfOrig = 0.1;

  Color get darker => Color.fromARGB(
        alpha,
        (red * _darkerPercentOfOrig).round(),
        (green * _darkerPercentOfOrig).round(),
        (blue * _darkerPercentOfOrig).round(),
      );

  Color get lighter => Color.fromARGB(
        alpha,
        red + ((255 - red) * _lighterPercentOfOrig).round(),
        green + ((255 - green) * _lighterPercentOfOrig).round(),
        blue + ((255 - blue) * _lighterPercentOfOrig).round(),
      );
}

extension MaterialShades on MaterialColor {
  /// Returns a list of colors for this color palette.
  List<Color> makeShades(int colorCnt) {
    TextStyle
    final colors = <Color>[this];

    // If we need more than 2 colors, then [unselected] collides with one of the
    // generated colors. Otherwise divide the space between the top color
    // and white in half.
    final lighterColor = colorCnt < 3
        ? this.lighter
        : _getSteppedColor(this, (colorCnt * 2) - 1, colorCnt * 2);

    // Divide the space between 255 and c500 evenly according to the colorCnt.
    for (var i = 1; i < colorCnt; i++) {
      colors.add(_getSteppedColor(this, i, colorCnt,
          darker: this.darker, lighter: lighterColor));
    }

    colors.add(this);
    return colors;
  }

  Color _getSteppedColor(Color color, int index, int steps,
      {Color? darker, Color? lighter}) {
    final fraction = index / steps;
    return Color.fromARGB(
      color.alpha + ((255 - color.alpha) * fraction).round(),
      color.red + ((255 - color.red) * fraction).round(),
      color.green + ((255 - color.green) * fraction).round(),
      color.blue + ((255 - color.blue) * fraction).round(),
    );
  }
}
