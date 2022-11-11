// Copyright 2019 the Charts project authors. Please see the AUTHORS file
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

import 'dart:math' show Rectangle, pi;
import 'package:charts/charts/treemap.dart';

/// Decorator that renders label for treemap renderer element.
class TreeMapLabelDecorator<D> extends TreeMapRendererDecorator<D> {
  TreeMapLabelDecorator({
    TextStyle? labelStyleSpec,
    this.labelPadding = _defaultLabelPadding,
    this.allowLabelOverflow = true,
    this.enableMultiline = false,
  }) : labelStyleSpec = labelStyleSpec ?? _defaultLabelStyle;
  // Default configuration
  static const _defaultLabelPadding = 4.0;
  static const _defaultFontSize = 12.0;
  static const _defaultLabelStyle =
      TextStyle(fontSize: _defaultFontSize, color: Colors.black);

  /// Rotation value of 90 degrees clockwise.
  static const k90DegreeClockwise = pi / 2;

  /// Text style spec for labels.
  final TextStyle labelStyleSpec;

  /// Padding of the label text.
  final double labelPadding;

  /// Whether or not to allow labels to draw outside of their bounding box.
  final bool allowLabelOverflow;

  /// Whether or not drawing a label in multiple lines if there is enough
  /// space.
  final bool enableMultiline;

  @override
  void decorate(
    TreeMapRendererElement<D> rendererElement,
    ChartCanvas canvas,
    GraphicsFactory graphicsFactory, {
    required Rect drawBounds,
    required double animationPercent,
    bool rtl = false,
    bool renderVertically = false,
    bool renderMultiline = false,
  }) {
    // Decorates the renderer elements when animation is completed.
    if (animationPercent != 1.0) return;

    // Creates [TextStyle] from [TextStyle] to be used by all the elements.
    // The [GraphicsFactory] is needed since it cannot be created earlier.
    final labelStyle = _asTextStyle(graphicsFactory, labelStyleSpec);

    final labelFn = rendererElement.series.labelAccessorFn;
    final datumIndex = rendererElement.index;
    final label = labelFn != null ? labelFn(datumIndex) : null;

    // Skips if this element has no label.
    if (label == null || label.isEmpty) return;

    // Uses datum specific label style if provided.
    final datumLabelStyle = _datumStyle(
      rendererElement.series.insideLabelStyleAccessorFn,
      datumIndex,
      graphicsFactory,
      defaultStyle: labelStyle,
    );
    final rect = rendererElement.boundingRect;
    final labelElement = graphicsFactory.createTextElement(label)
      ..textStyle = datumLabelStyle
      ..textDirection =
          rtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
    final labelHeight = labelElement.measurement.verticalSliceWidth;
    final maxLabelHeight =
        (renderVertically ? rect.width : rect.height) - (labelPadding * 2);
    final maxLabelWidth =
        (renderVertically ? rect.height : rect.width) - (labelPadding * 2);
    final multiline = enableMultiline && renderMultiline;
    final parts = wrapLabelLines(
      labelElement,
      graphicsFactory,
      maxLabelWidth,
      maxLabelHeight,
      allowLabelOverflow: allowLabelOverflow,
      multiline: multiline,
    );

    for (var index = 0; index < parts.length; index++) {
      final segment = _createLabelSegment(
        rect,
        labelHeight,
        parts[index],
        index,
        rtl: rtl,
        rotate: renderVertically,
      );

      // Draws a label inside of a treemap renderer element.
      canvas.drawText(
        segment.text,
        segment.xOffet,
        segment.yOffset,
        rotation: segment.rotationAngle,
      );
    }
  }

  /// Converts [TextStyle] to [TextStyle].
  TextStyle _asTextStyle(
    GraphicsFactory graphicsFactory,
    TextStyle labelSpec,
  ) =>
      graphicsFactory
          .createTextPaint()
          .merge(
            const TextStyle(color: Colors.black, fontSize: _defaultFontSize),
          )
          .merge(labelSpec);

  /// Gets datum specific style.
  TextStyle _datumStyle(
    AccessorFn<TextStyle>? labelStyleFn,
    int datumIndex,
    GraphicsFactory graphicsFactory, {
    required TextStyle defaultStyle,
  }) {
    final styleSpec = labelStyleFn?.call(datumIndex);
    return (styleSpec != null)
        ? _asTextStyle(graphicsFactory, styleSpec)
        : defaultStyle;
  }

  _TreeMapLabelSegment _createLabelSegment(
    Rect elementBoundingRect,
    num labelHeight,
    TextElement labelElement,
    int position, {
    bool rtl = false,
    bool rotate = false,
  }) {
    double xOffset;
    double yOffset;

    // Set x offset for each line.
    if (rotate) {
      xOffset = elementBoundingRect.right -
          labelPadding -
          2 * labelElement.textStyle!.fontSize! -
          labelHeight * position;
    } else if (rtl) {
      xOffset = elementBoundingRect.right - labelPadding;
    } else {
      xOffset = elementBoundingRect.left + labelPadding;
    }

    // Set y offset for each line.
    if (!rotate) {
      yOffset =
          elementBoundingRect.top + labelPadding + (labelHeight * position);
    } else if (rtl) {
      yOffset = elementBoundingRect.bottom - labelPadding;
    } else {
      yOffset = elementBoundingRect.top + labelPadding;
    }

    return _TreeMapLabelSegment(
      labelElement,
      xOffset,
      yOffset,
      rotate ? k90DegreeClockwise : 0.0,
    );
  }
}

/// Represents a segment of a label that will be drawn in a single line.
class _TreeMapLabelSegment {
  _TreeMapLabelSegment(
    this.text,
    this.xOffet,
    this.yOffset,
    this.rotationAngle,
  );

  /// Text to be drawn on the canvas.
  final TextElement text;

  /// x-coordinate offset for [text].
  final double xOffet;

  /// y-coordinate offset for [text].
  final double yOffset;

  /// Rotation angle for drawing [text].
  final double rotationAngle;
}
