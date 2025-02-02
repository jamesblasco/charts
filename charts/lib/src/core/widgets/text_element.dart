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

import 'dart:ui' show Color, TextAlign, TextDirection;

import 'package:charts/core.dart';
import 'package:flutter/rendering.dart'
    show TextBaseline, TextPainter, TextSpan, TextStyle;

/// Flutter implementation for text measurement and painter.
class FlutterTextElement implements TextElement {
  FlutterTextElement(this.text, {TextStyle? style, this.textScaleFactor})
      : _textStyle = style;
  static const ellipsis = '\u{2026}';

  @override
  final String text;

  final double? textScaleFactor;

  var _painterReady = false;
  TextStyle? _textStyle;
  TextDirectionAligment _textDirection = TextDirectionAligment.ltr;

  double? _maxWidth;
  MaxWidthStrategy? _maxWidthStrategy;

  late TextPainter _textPainter;

  late TextMeasurement _measurement;

  double? _opacity;

  @override
  TextStyle? get textStyle => _textStyle;

  @override
  set textStyle(TextStyle? value) {
    if (_textStyle == value) {
      return;
    }
    _textStyle = value;
    _painterReady = false;
  }

  @override
  set textDirection(TextDirectionAligment direction) {
    if (_textDirection == direction) {
      return;
    }
    _textDirection = direction;
    _painterReady = false;
  }

  @override
  TextDirectionAligment get textDirection => _textDirection;

  @override
  double? get maxWidth => _maxWidth;

  @override
  set maxWidth(double? value) {
    if (_maxWidth == value) {
      return;
    }
    _maxWidth = value;
    _painterReady = false;
  }

  @override
  MaxWidthStrategy? get maxWidthStrategy => _maxWidthStrategy;

  @override
  set maxWidthStrategy(MaxWidthStrategy? maxWidthStrategy) {
    if (_maxWidthStrategy == maxWidthStrategy) {
      return;
    }
    _maxWidthStrategy = maxWidthStrategy;
    _painterReady = false;
  }

  double? get opacity => _opacity;

  @override
  set opacity(double? opacity) {
    if (opacity != _opacity) {
      _painterReady = false;
      _opacity = opacity;
    }
  }

  @override
  TextMeasurement get measurement {
    if (!_painterReady) {
      _refreshPainter();
    }

    return _measurement;
  }

  /// The estimated distance between where we asked to draw the text (top, left)
  /// and where it visually started (top + verticalFontShift, left).
  ///
  /// 10% of reported font height seems to be about right.
  int get verticalFontShift {
    if (!_painterReady) {
      _refreshPainter();
    }

    return (_textPainter.height * 0.1).ceil();
  }

  TextPainter? get textPainter {
    if (!_painterReady) {
      _refreshPainter();
    }
    return _textPainter;
  }

  /// Create text painter and measure based on current settings
  void _refreshPainter() {
    _opacity ??= 1.0;
    final effectiveTextStyle =
        textStyle?.copyWith(color: textStyle?.color?.withOpacity(opacity!));

    _textPainter = TextPainter(
      text: TextSpan(text: text, style: effectiveTextStyle),
    )
      ..textDirection = TextDirection.ltr
      // TODO Flip once textAlign works
      ..textAlign = TextAlign.left
      // ..textAlign = _textDirection == TextDirection.rtl ?
      //     TextAlign.right : TextAlign.left
      ..ellipsis =
          maxWidthStrategy == MaxWidthStrategy.ellipsize ? ellipsis : null;

    if (textScaleFactor != null) {
      _textPainter.textScaleFactor = textScaleFactor!;
    }

    _textPainter.layout(maxWidth: maxWidth?.toDouble() ?? double.infinity);

    final baseline =
        _textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

    // Estimating the actual draw height to 70% of measures size.
    //
    // The font reports a size larger than the drawn size, which makes it
    // difficult to shift the text around to get it to visually line up
    // vertically with other components.
    _measurement = TextMeasurement(
      horizontalSliceWidth: _textPainter.width,
      verticalSliceWidth: _textPainter.height * 0.70,
      baseline: baseline,
    );

    _painterReady = true;
  }
}
