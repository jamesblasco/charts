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
import 'package:flutter/material.dart' hide TextStyle;

class FlutterGraphicsFactory implements GraphicsFactory {

  FlutterGraphicsFactory(BuildContext context,
      {GraphicsFactoryHelper helper = const GraphicsFactoryHelper(),})
      : textScaleFactor = helper.getTextScaleFactorOf(context),
        defaultTextStyle = DefaultTextStyle.of(context);
  final double textScaleFactor;
  final DefaultTextStyle defaultTextStyle;

  /// Returns a [TextPaintStyle] object.
  @override
  TextPaintStyle createTextPaint() =>
      FlutterTextStyle()..fontFamily = defaultTextStyle.style.fontFamily;

  /// Returns a text element from [text].
  @override
  TextElement createTextElement(String text) {
    return FlutterTextElement(text, textScaleFactor: textScaleFactor)
      ..textStyle = createTextPaint();
  }

  @override
  LineStyle createLinePaint() => FlutterLineStyle();
}

/// Wraps the MediaQuery function to allow for testing.
class GraphicsFactoryHelper {
  const GraphicsFactoryHelper();

  double getTextScaleFactorOf(BuildContext context) =>
      MediaQuery.textScaleFactorOf(context);
}
