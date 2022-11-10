import 'package:charts/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Get the [ChartContainerRenderObject] from a [RenderBox].
///
/// [RenderBox] is expected to be a [RenderSemanticsGestureHandler] with child
/// of [RenderPointerListener] with child of [ChartContainerRenderObject].
ChartContainerRenderObject getChartContainerRenderObject(RenderBox box) {
  assert(box is RenderCustomMultiChildLayoutBox);
  final semanticHandler = (box as RenderCustomMultiChildLayoutBox)
      .getChildrenAsList()
      .firstWhere((child) => child is RenderSemanticsGestureHandler);

  assert(semanticHandler is RenderSemanticsGestureHandler);
  final renderPointerListener =
      (semanticHandler as RenderSemanticsGestureHandler).child;

  assert(renderPointerListener is RenderPointerListener);
  final chartContainerRenderObject =
      (renderPointerListener as RenderPointerListener).child;

  assert(chartContainerRenderObject is ChartContainerRenderObject);

  return chartContainerRenderObject as ChartContainerRenderObject;
}
