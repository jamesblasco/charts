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

import 'package:charts/behaviors.dart';
import 'package:charts/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Strategy for building one widget from one [LegendEntry].
abstract class LegendEntryLayout extends Equatable {
  const LegendEntryLayout();
  Widget build(
    BuildContext context,
    LegendEntry legendEntry,
    TappableLegend legend,
    bool isHidden, {
    bool showMeasures,
  });
}

/// Builds one legend entry as a row with symbol and label from the series.
///
/// If directionality from the chart context indicates RTL, the symbol is placed
/// to the right of the text instead of the left of the text.
class SimpleLegendEntryLayout extends LegendEntryLayout {
  const SimpleLegendEntryLayout();

  Widget createSymbol(
    BuildContext context,
    LegendEntry legendEntry,
    TappableLegend legend,
    bool isHidden,
  ) {
    // TODO: Consider allowing scaling the size for the symbol.
    // A custom symbol renderer can ignore this size and use their own.
    const materialSymbolSize = Size(12, 12);

    final entryColor = legendEntry.color;
    final color = entryColor;

    // Get the SymbolRendererBuilder wrapping a SymbolRenderer if needed.
    final symbolRendererBuilder =
        legendEntry.symbolRenderer! is SymbolRendererBuilder
            ? legendEntry.symbolRenderer! as SymbolRendererBuilder
            : SymbolRendererCanvas(
                legendEntry.symbolRenderer!,
                legendEntry.dashPattern,
              );

    return GestureDetector(
      onTapUp: makeTapUpCallback(context, legendEntry, legend),
      child: symbolRendererBuilder.build(
        context,
        size: materialSymbolSize,
        color: color,
        enabled: !isHidden,
      ),
    );
  }

  Widget createLabel(
    BuildContext context,
    LegendEntry legendEntry,
    TappableLegend legend,
    bool isHidden,
  ) {
    final style = _convertTextStyle(isHidden, context, legendEntry.textStyle);

    return GestureDetector(
      onTapUp: makeTapUpCallback(context, legendEntry, legend),
      child: Text(legendEntry.label, style: style),
    );
  }

  Widget createMeasureValue(
    BuildContext context,
    LegendEntry legendEntry,
    TappableLegend legend,
    bool isHidden,
  ) {
    return GestureDetector(
      onTapUp: makeTapUpCallback(context, legendEntry, legend),
      child: Text(legendEntry.formattedValue!),
    );
  }

  @override
  Widget build(
    BuildContext context,
    LegendEntry legendEntry,
    TappableLegend legend,
    bool isHidden, {
    bool showMeasures = false,
  }) {
    final rowChildren = <Widget>[];

    // TODO: Allow setting to configure the padding.
    const padding = EdgeInsets.only(right: 8); // Material default.
    final symbol = createSymbol(context, legendEntry, legend, isHidden);
    final label = createLabel(context, legendEntry, legend, isHidden);

    final measure = showMeasures
        ? createMeasureValue(context, legendEntry, legend, isHidden)
        : null;

    rowChildren.add(symbol);
    rowChildren.add(Container(padding: padding));
    rowChildren.add(label);
    if (measure != null) {
      rowChildren.add(Container(padding: padding));
      rowChildren.add(measure);
    }

    // Row automatically reverses the content if Directionality is rtl.
    return Row(children: rowChildren);
  }

  GestureTapUpCallback makeTapUpCallback(
    BuildContext context,
    LegendEntry legendEntry,
    TappableLegend legend,
  ) {
    return (TapUpDetails d) {
      legend.onLegendEntryTapUp(legendEntry);
    };
  }

  @override
  List<Object?> get props => [];

  /// Convert the charts common TextStlyeSpec into a standard TextStyle, while
  /// reducing the color opacity to 26% if the entry is hidden.
  ///
  /// For non-specified values, override the hidden text color to use the body 1
  /// theme, but allow other properties of [Text] to be inherited.
  TextStyle _convertTextStyle(
    bool isHidden,
    BuildContext context,
    TextStyle? textStyle,
  ) {
    var color = textStyle?.color != null ? textStyle!.color! : null;
    if (isHidden) {
      // Use a default color for hidden legend entries if none is provided.
      color ??= Theme.of(context).textTheme.bodyText2!.color;
      color = color!.withOpacity(0.26);
    }

    return TextStyle(
      fontFamily: textStyle?.fontFamily,
      fontSize:
          textStyle?.fontSize != null ? textStyle!.fontSize!.toDouble() : null,
      color: color,
    );
  }
}
