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

import 'dart:collection' show LinkedHashMap;
import 'dart:math' show pi, Point, Rectangle;

import 'package:charts/charts.dart';
import 'package:charts/core.dart';
import 'package:meta/meta.dart';

const _defaultStrokeWidth = 2.0;

/// Chart behavior that annotates domain ranges with a solid fill color.
///
/// The annotations will be drawn underneath series data and chart axes.
///
/// This is typically used for line charts to call out sections of the data
/// range.
///
/// TODO: Support labels.
class RangeAnnotationState<D> implements ChartBehaviorState<D> {
  RangeAnnotationState(
    this.annotations, {
    AnnotationLabelAnchor? defaultLabelAnchor,
    AnnotationLabelDirection? defaultLabelDirection,
    AnnotationLabelPosition? defaultLabelPosition,
    TextStyle? defaultLabelStyleSpec,
    bool? extendAxis,
    double? labelPadding,
    double? defaultStrokeWidth,
    int? layoutPaintOrder,
  })  : defaultColor = StyleFactory.style.rangeAnnotationColor,
        defaultLabelAnchor = defaultLabelAnchor ?? _defaultLabelAnchor,
        defaultLabelDirection = defaultLabelDirection ?? _defaultLabelDirection,
        defaultLabelPosition = defaultLabelPosition ?? _defaultLabelPosition,
        defaultLabelStyleSpec = defaultLabelStyleSpec ?? _defaultLabelStyle,
        extendAxis = extendAxis ?? true,
        labelPadding = labelPadding ?? _defaultLabelPadding,
        defaultStrokeWidth = defaultStrokeWidth ?? _defaultStrokeWidth,
        layoutPaintOrder =
            layoutPaintOrder ?? LayoutViewPaintOrder.rangeAnnotation {
    _lifecycleListener = LifecycleListener<D>(
      onPostprocess: _updateAxisRange,
      onAxisConfigured: _updateViewData,
    );
  }
  static const _defaultLabelAnchor = AnnotationLabelAnchor.end;
  static const _defaultLabelDirection = AnnotationLabelDirection.auto;
  static const _defaultLabelPosition = AnnotationLabelPosition.auto;
  static const _defaultLabelPadding = 5.0;
  static const _defaultLabelStyle =
      TextStyle(fontSize: 12, color: Colors.black);

  /// List of annotations to render on the chart.
  final List<AnnotationSegment<Object>> annotations;

  /// Default color for annotations.
  final Color defaultColor;

  /// Configures where to anchor annotation label text.
  final AnnotationLabelAnchor defaultLabelAnchor;

  /// Direction of label text on the annotations.
  final AnnotationLabelDirection defaultLabelDirection;

  /// Configures where to place labels relative to the annotation.
  final AnnotationLabelPosition defaultLabelPosition;

  /// Configures the style of label text.
  final TextStyle defaultLabelStyleSpec;

  /// Configures the stroke width for line annotations.
  final double defaultStrokeWidth;

  /// Whether or not the range of the axis should be extended to include the
  /// annotation start and end values.
  final bool extendAxis;

  /// Space before and after label text.
  final double labelPadding;

  /// Configures the order in which the behavior should be painted.
  /// This value should be relative to LayoutPaintViewOrder.rangeAnnotation.
  /// (e.g. LayoutViewPaintOrder.rangeAnnotation + 1)
  final int layoutPaintOrder;

  late CartesianRenderChart<D> _chart;

  late _RangeAnnotationLayoutView<D> _view;

  late LifecycleListener<D> _lifecycleListener;

  /// Store a map of data drawn on the chart, mapped by series name.
  ///
  /// [LinkedHashMap] is used to render the series on the canvas in the same
  /// order as the data was given to the chart.
  // ignore: prefer_collection_literals, https://github.com/dart-lang/linter/issues/1649
  final _annotationMap = LinkedHashMap<String, _AnimatedAnnotation<D>>();

  // Store a list of annotations that exist in the current annotation list.
  //
  // This list will be used to remove any [_AnimatedAnnotation] that were
  // rendered in previous draw cycles, but no longer have a corresponding datum
  // in the new data.
  final _currentKeys = <String>[];

  @override
  void attachTo(BaseRenderChart<D> chart) {
    if (chart is! CartesianRenderChart<D>) {
      throw ArgumentError(
        'RangeAnnotation can only be attached to a CartesianChart<D>',
      );
    }

    _chart = chart;

    _view = _RangeAnnotationLayoutView<D>(
      defaultColor: defaultColor,
      labelPadding: labelPadding,
      chart: _chart,
      rangeAnnotation: this,
      layoutPaintOrder: layoutPaintOrder,
    );

    chart.addView(_view);

    chart.addLifecycleListener(_lifecycleListener);
  }

  @override
  void removeFrom(BaseRenderChart<D> chart) {
    chart.removeView(_view);
    chart.removeLifecycleListener(_lifecycleListener);

    _view.chart = null;
  }

  /// Sub-classes can override this method to control label visibility.
  @protected
  bool shouldShowLabels(AnnotationSegment<Object> annotation) => true;

  void _updateAxisRange(List<MutableSeries<D>> seriesList) {
    // Extend the axis range if enabled.
    if (extendAxis) {
      for (final annotation in annotations) {
        // Either an Axis<D> and Axis<num>.
        MutableAxisElement<Object?> axis;

        switch (annotation.axisType) {
          case RangeAnnotationAxisType.domain:
            axis = _chart.domainAxis!;
            break;

          case RangeAnnotationAxisType.measure:
            // We expect an empty axisId to get us the primary measure axis.
            axis = _chart.getMeasureAxis(axisId: annotation.axisId);
            break;
        }

        if (annotation is RangeAnnotationSegment<Object>) {
          axis.addDomainValue(annotation.startValue);
          axis.addDomainValue(annotation.endValue);
        } else if (annotation is LineAnnotationSegment<Object>) {
          axis.addDomainValue(annotation.value);
        }
      }
    }
  }

  void _updateViewData() {
    _currentKeys.clear();

    // The values (T) can match the data type of the domain (D) or measure axis
    // (num).
    void updateAnnotation<T>(
      MutableAxisElement<T> axis,
      AnnotationSegment<Object> annotation,
    ) {
      final key = annotation.key;

      final color = annotation.color ?? defaultColor;

      final startLabel = annotation.startLabel;
      final endLabel = annotation.endLabel;
      final middleLabel = annotation.middleLabel;
      final labelAnchor = annotation.labelAnchor ?? defaultLabelAnchor;
      var labelDirection = annotation.labelDirection ?? defaultLabelDirection;

      if (labelDirection == AnnotationLabelDirection.auto) {
        switch (annotation.axisType) {
          case RangeAnnotationAxisType.domain:
            labelDirection = AnnotationLabelDirection.vertical;
            break;

          case RangeAnnotationAxisType.measure:
            labelDirection = AnnotationLabelDirection.horizontal;
            break;
        }
      }

      final labelPosition = annotation.labelPosition ?? defaultLabelPosition;
      final labelStyleSpec = annotation.labelStyleSpec ?? defaultLabelStyleSpec;

      // Add line annotation settings.
      final dashPattern = annotation is LineAnnotationSegment<Object>
          ? annotation.dashPattern
          : null;
      final strokeWidth = annotation is LineAnnotationSegment<Object>
          ? annotation.strokeWidth
          : 0.0;

      final isRange = annotation is RangeAnnotationSegment;

      final T startValue;
      final T endValue;

      // We unfortunately can't check for `RangeAnnotationSegment<T>` nor
      // `LineAnnotationSegment<T>` here because the `AnnotationSegment` object
      // might not have been parameterized on `T` when it was initially
      // constructed.
      if (annotation is RangeAnnotationSegment<Object>) {
        startValue = annotation.startValue as T;
        endValue = annotation.endValue as T;
      } else if (annotation is LineAnnotationSegment<Object>) {
        startValue = endValue = annotation.value as T;
      } else {
        throw UnsupportedError(
          'Unrecognized annotation type: ${annotation.runtimeType}',
        );
      }

      final annotationDatum =
          _getAnnotationDatum(startValue, endValue, axis, annotation.axisType);

      // If we already have a animatingAnnotation for that index, use it.
      var animatingAnnotation = _annotationMap[key];
      if (animatingAnnotation == null) {
        // Create a new annotation, positioned at the start and end values.
        animatingAnnotation = _AnimatedAnnotation<D>(key: key)
          ..setNewTarget(
            _AnnotationElement<D>(
              annotation: annotationDatum,
              annotationSegment: annotation,
              color: color,
              dashPattern: dashPattern,
              startLabel: startLabel,
              endLabel: endLabel,
              middleLabel: middleLabel,
              isRange: isRange,
              labelAnchor: labelAnchor,
              labelDirection: labelDirection,
              labelPosition: labelPosition,
              labelStyleSpec: labelStyleSpec,
              strokeWidth: strokeWidth,
            ),
          );

        _annotationMap[key] = animatingAnnotation;
      }

      // Update the set of annotations that still exist in the series data.
      _currentKeys.add(key);

      // Get the annotation element we are going to setup.
      final annotationElement = _AnnotationElement<D>(
        annotation: annotationDatum,
        annotationSegment: annotation,
        color: color,
        dashPattern: dashPattern,
        startLabel: startLabel,
        endLabel: endLabel,
        middleLabel: middleLabel,
        isRange: isRange,
        labelAnchor: labelAnchor,
        labelDirection: labelDirection,
        labelPosition: labelPosition,
        labelStyleSpec: labelStyleSpec,
        strokeWidth: strokeWidth,
      );

      animatingAnnotation.setNewTarget(annotationElement);
    }

    for (final annotation in annotations) {
      switch (annotation.axisType) {
        case RangeAnnotationAxisType.domain:
          updateAnnotation(_chart.domainAxis!, annotation);
          break;

        case RangeAnnotationAxisType.measure:
          // We expect an empty axisId to get us the primary measure axis.
          updateAnnotation(
            _chart.getMeasureAxis(axisId: annotation.axisId),
            annotation,
          );
          break;
      }
    }

    // Animate out annotations that don't exist anymore.
    _annotationMap.forEach((String key, _AnimatedAnnotation<D> annotation) {
      if (!_currentKeys.contains(annotation.key)) {
        annotation.animateOut();
      }
    });

    _view.annotationMap = _annotationMap;
  }

  /// Generates a datum that describes an annotation.
  ///
  /// [startValue] and [endValue] are dynamic because they can be different data
  /// types for domain and measure axes, e.g. DateTime and num for a TimeSeries
  /// chart.
  _DatumAnnotation _getAnnotationDatum<T>(
    T startValue,
    T endValue,
    MutableAxisElement<T> axis,
    RangeAnnotationAxisType axisType,
  ) {
    // Remove floating point rounding errors by rounding to 2 decimal places of
    // precision. The difference in the canvas is negligible.
    final startPosition = (axis.getLocation(startValue)! * 100).round() / 100;
    final endPosition = (axis.getLocation(endValue)! * 100).round() / 100;

    return _DatumAnnotation(
      startPosition: startPosition,
      endPosition: endPosition,
      axisType: axisType,
    );
  }

  @override
  String get role => 'RangeAnnotation';
}

class _RangeAnnotationLayoutView<D> extends LayoutView {
  _RangeAnnotationLayoutView({
    required this.defaultColor,
    required this.labelPadding,
    required this.chart,
    required this.rangeAnnotation,
    required this.layoutPaintOrder,
  }) : layoutConfig = LayoutViewConfig(
          paintOrder: layoutPaintOrder,
          position: LayoutPosition.drawArea,
          positionOrder: LayoutViewPositionOrder.drawArea,
        );
  @override
  final LayoutViewConfig layoutConfig;

  final Color defaultColor;

  final double labelPadding;

  final RangeAnnotationState<D> rangeAnnotation;

  final int layoutPaintOrder;

  CartesianRenderChart<D>? chart;

  bool get isRtl => chart!.context.isRtl;

  late Rect _drawAreaBounds;

  Rect get drawBounds => _drawAreaBounds;

  @override
  GraphicsFactory? graphicsFactory;

  /// Store a map of series drawn on the chart, mapped by series name.
  ///
  /// [LinkedHashMap] is used to render the series on the canvas in the same
  /// order as the data was given to the chart.
  LinkedHashMap<String, _AnimatedAnnotation<D>>? _annotationMap;

  set annotationMap(LinkedHashMap<String, _AnimatedAnnotation<D>> value) {
    _annotationMap = value;
  }

  @override
  ViewMeasuredSizes? measure(double maxWidth, double maxHeight) {
    return null;
  }

  @override
  void layout(Rect componentBounds, Rect drawAreaBounds) {
    _drawAreaBounds = drawAreaBounds;
  }

  @override
  void paint(ChartCanvas canvas, double animationPercent) {
    final annotationMap = _annotationMap;
    if (annotationMap == null) {
      return;
    }

    // Clean up the annotations that no longer exist.
    if (animationPercent == 1.0) {
      final keysToRemove = <String>[];

      annotationMap.forEach((String key, _AnimatedAnnotation<D> annotation) {
        if (annotation.animatingOut) {
          keysToRemove.add(key);
        }
      });

      keysToRemove.forEach(annotationMap.remove);
    }

    annotationMap.forEach((String key, _AnimatedAnnotation<D> annotation) {
      final annotationElement =
          annotation.getCurrentAnnotation(animationPercent);

      // Calculate the bounds of a range annotation.
      //
      // This will still be used for line annotations to compute the position of
      // labels. We always expect those to end up outside, since the bounds will
      // have zero width or  height.
      final bounds = _getAnnotationBounds(annotationElement);

      if (annotationElement.isRange) {
        // Draw the annotation.
        canvas.drawRect(bounds, fill: annotationElement.color);
      } else {
        // Calculate the points for a line annotation.
        final points = _getLineAnnotationPoints(annotationElement);

        // Draw the annotation.
        canvas.drawLine(
          dashPattern: annotationElement.dashPattern,
          points: points,
          stroke: annotationElement.color,
          strokeWidth: annotationElement.strokeWidth,
        );
      }

      // Create [TextStyle] from [TextStyle] to be used by all the elements.
      // The [GraphicsFactory] is needed so it can't be created earlier.
      final labelStyle =
          _getTextStyle(graphicsFactory!, annotationElement.labelStyleSpec);

      final rotation =
          annotationElement.labelDirection == AnnotationLabelDirection.vertical
              ? -pi / 2
              : 0.0;

      if (rangeAnnotation
          .shouldShowLabels(annotationElement.annotationSegment)) {
        final labels = {
          if (annotationElement.startLabel != null)
            _AnnotationLabelType.start: annotationElement.startLabel,
          if (annotationElement.endLabel != null)
            _AnnotationLabelType.end: annotationElement.endLabel,
          if (annotationElement.middleLabel != null)
            _AnnotationLabelType.middle: annotationElement.middleLabel,
        };

        // Draw labels that have been defined.
        labels.forEach((labelType, label) {
          final labelElement = graphicsFactory!.createTextElement(label!)
            ..maxWidthStrategy = MaxWidthStrategy.ellipsize
            ..textStyle = labelStyle;

          // Measure the label max width once if either type of label is defined.
          labelElement.maxWidth =
              _getLabelMaxWidth(bounds, annotationElement, labelElement);

          final labelPoint = _getLabelPosition(
            labelType,
            bounds,
            annotationElement,
            labelElement,
          );

          if (labelPoint != null) {
            canvas.drawText(
              labelElement,
              labelPoint.dx,
              labelPoint.dy,
              rotation: rotation,
            );
          }
        });
      }
    });
  }

  /// Calculates the bounds of the annotation.
  Rect _getAnnotationBounds(_AnnotationElement<D> annotationElement) {
    Rect bounds;

    switch (annotationElement.annotation.axisType) {
      case RangeAnnotationAxisType.domain:
        bounds = Rect.fromLTWH(
          annotationElement.annotation.startPosition,
          _drawAreaBounds.top,
          annotationElement.annotation.endPosition -
              annotationElement.annotation.startPosition,
          _drawAreaBounds.height,
        );
        break;

      case RangeAnnotationAxisType.measure:
        bounds = Rect.fromLTWH(
          _drawAreaBounds.left,
          annotationElement.annotation.endPosition,
          _drawAreaBounds.width,
          annotationElement.annotation.startPosition -
              annotationElement.annotation.endPosition,
        );
        break;
    }

    return bounds;
  }

  /// Calculates the bounds of the annotation.
  List<Offset> _getLineAnnotationPoints(
    _AnnotationElement<D> annotationElement,
  ) {
    final points = <Offset>[];

    switch (annotationElement.annotation.axisType) {
      case RangeAnnotationAxisType.domain:
        points.add(
          Offset(
            annotationElement.annotation.startPosition,
            _drawAreaBounds.top,
          ),
        );
        points.add(
          Offset(
            annotationElement.annotation.endPosition,
            _drawAreaBounds.bottom,
          ),
        );
        break;

      case RangeAnnotationAxisType.measure:
        points.add(
          Offset(
            _drawAreaBounds.left,
            annotationElement.annotation.startPosition,
          ),
        );
        points.add(
          Offset(
            _drawAreaBounds.right,
            annotationElement.annotation.endPosition,
          ),
        );
        break;
    }

    return points;
  }

  /// Measures the max label width of the annotation.
  double _getLabelMaxWidth(
    Rect bounds,
    _AnnotationElement<D> annotationElement,
    TextElement labelElement,
  ) {
    double maxWidth = 0.0;

    final calculatedLabelPosition =
        _resolveAutoLabelPosition(bounds, annotationElement, labelElement);

    if (annotationElement.labelPosition == AnnotationLabelPosition.margin &&
        annotationElement.annotation.axisType ==
            RangeAnnotationAxisType.measure) {
      switch (annotationElement.annotation.axisType) {
        case RangeAnnotationAxisType.domain:
          break;

        case RangeAnnotationAxisType.measure:
          switch (annotationElement.labelAnchor) {
            case AnnotationLabelAnchor.start:
              maxWidth = chart!.marginLeft - labelPadding;
              break;

            case AnnotationLabelAnchor.end:
              maxWidth = chart!.marginRight - labelPadding;
              break;

            case AnnotationLabelAnchor.middle:
              break;
          }
          break;
      }
    } else {
      if (calculatedLabelPosition == AnnotationLabelPosition.outside) {
        maxWidth = annotationElement.labelDirection ==
                AnnotationLabelDirection.horizontal
            ? drawBounds.width
            : drawBounds.height;
      } else {
        maxWidth = annotationElement.labelDirection ==
                AnnotationLabelDirection.horizontal
            ? bounds.width
            : bounds.height;
      }
    }

    return maxWidth;
  }

  /// Gets the resolved location for a label element.
  Offset? _getLabelPosition(
    _AnnotationLabelType labelType,
    Rect bounds,
    _AnnotationElement<D> annotationElement,
    TextElement labelElement,
  ) {
    switch (annotationElement.annotation.axisType) {
      case RangeAnnotationAxisType.domain:
        return _getDomainLabelPosition(
          labelType,
          bounds,
          annotationElement,
          labelElement,
        );

      case RangeAnnotationAxisType.measure:
        return _getMeasureLabelPosition(
          labelType,
          bounds,
          annotationElement,
          labelElement,
        );
    }
  }

  /// Gets the resolved location for a domain annotation label element.
  Offset _getDomainLabelPosition(
    _AnnotationLabelType labelType,
    Rect bounds,
    _AnnotationElement<D> annotationElement,
    TextElement labelElement,
  ) {
    if (annotationElement.labelDirection == AnnotationLabelDirection.vertical) {
      return _getDomainLabelPositionVertical(
        labelType,
        bounds,
        annotationElement,
        labelElement,
      );
    } else {
      return _getDomainLabelPositionHorizontal(
        labelType,
        bounds,
        annotationElement,
        labelElement,
      );
    }
  }

  /// Gets the resolved location for a horizontal domain annotation label
  /// element.
  Offset _getDomainLabelPositionHorizontal(
    _AnnotationLabelType labelType,
    Rect bounds,
    _AnnotationElement<D> annotationElement,
    TextElement labelElement,
  ) {
    var labelX = 0.0;
    var labelY = 0.0;

    final calculatedLabelPosition =
        _resolveAutoLabelPosition(bounds, annotationElement, labelElement);

    switch (annotationElement.labelAnchor) {
      case AnnotationLabelAnchor.middle:
        labelY = bounds.top +
            bounds.height / 2 -
            labelElement.measurement.verticalSliceWidth / 2 -
            labelPadding;
        break;

      case AnnotationLabelAnchor.end:
        if (annotationElement.labelPosition == AnnotationLabelPosition.margin) {
          labelY = bounds.top -
              labelElement.measurement.verticalSliceWidth -
              labelPadding;
        } else {
          labelY = bounds.top + labelPadding;
        }
        break;

      case AnnotationLabelAnchor.start:
        if (annotationElement.labelPosition == AnnotationLabelPosition.margin) {
          labelY = bounds.bottom + labelPadding;
        } else {
          labelY = bounds.bottom -
              labelElement.measurement.verticalSliceWidth -
              labelPadding;
        }
        break;
    }

    switch (calculatedLabelPosition) {
      case AnnotationLabelPosition.margin:
      case AnnotationLabelPosition.auto:
        throw ArgumentError(_unresolvedAutoMessage);

      case AnnotationLabelPosition.outside:
        switch (labelType) {
          case _AnnotationLabelType.start:
            labelX = bounds.left -
                labelElement.measurement.horizontalSliceWidth -
                labelPadding;
            break;
          case _AnnotationLabelType.end:
            labelX = bounds.right + labelPadding;
            break;
          case _AnnotationLabelType.middle:
            labelX = bounds.left +
                (bounds.width - labelElement.measurement.horizontalSliceWidth) /
                    2;
            break;
        }

        labelElement.textDirection =
            isRtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
        break;

      case AnnotationLabelPosition.inside:
        switch (labelType) {
          case _AnnotationLabelType.start:
            labelX = bounds.left + labelPadding;
            break;
          case _AnnotationLabelType.end:
            labelX = bounds.right -
                labelElement.measurement.horizontalSliceWidth -
                labelPadding;
            break;
          case _AnnotationLabelType.middle:
            labelX = bounds.left +
                (bounds.width - labelElement.measurement.horizontalSliceWidth) /
                    2;
            break;
        }

        labelElement.textDirection =
            isRtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
        break;
    }

    return Offset(labelX, labelY);
  }

  /// Gets the resolved location for a vertical domain annotation label element.
  Offset _getDomainLabelPositionVertical(
    _AnnotationLabelType labelType,
    Rect bounds,
    _AnnotationElement<D> annotationElement,
    TextElement labelElement,
  ) {
    var labelX = 0.0;
    var labelY = 0.0;

    final calculatedLabelPosition =
        _resolveAutoLabelPosition(bounds, annotationElement, labelElement);

    switch (annotationElement.labelAnchor) {
      case AnnotationLabelAnchor.middle:
        labelY = bounds.top +
            bounds.height / 2 +
            labelElement.measurement.horizontalSliceWidth / 2 +
            labelPadding;
        break;

      case AnnotationLabelAnchor.end:
        if (annotationElement.labelPosition == AnnotationLabelPosition.margin) {
          labelY = bounds.top +
              labelElement.measurement.horizontalSliceWidth +
              labelPadding;
        } else {
          labelY = bounds.top +
              labelElement.measurement.horizontalSliceWidth +
              labelPadding;
        }
        break;

      case AnnotationLabelAnchor.start:
        if (annotationElement.labelPosition == AnnotationLabelPosition.margin) {
          labelY = bounds.bottom + labelPadding;
        } else {
          labelY = bounds.bottom -
              labelElement.measurement.horizontalSliceWidth -
              labelPadding;
        }
        break;
    }

    switch (calculatedLabelPosition) {
      case AnnotationLabelPosition.margin:
      case AnnotationLabelPosition.auto:
        throw ArgumentError(_unresolvedAutoMessage);

      case AnnotationLabelPosition.outside:
        switch (labelType) {
          case _AnnotationLabelType.start:
            labelX = bounds.left -
                labelElement.measurement.verticalSliceWidth -
                labelPadding;
            break;
          case _AnnotationLabelType.end:
            labelX = bounds.right + labelPadding;
            break;
          case _AnnotationLabelType.middle:
            labelX = bounds.left +
                (bounds.width - labelElement.measurement.verticalSliceWidth) /
                    2;
            break;
        }

        labelElement.textDirection =
            isRtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
        break;

      case AnnotationLabelPosition.inside:
        switch (labelType) {
          case _AnnotationLabelType.start:
            labelX = bounds.left + labelPadding;
            break;
          case _AnnotationLabelType.end:
            labelX = bounds.right -
                labelElement.measurement.verticalSliceWidth -
                labelPadding;
            break;
          case _AnnotationLabelType.middle:
            labelX = bounds.left +
                (bounds.width - labelElement.measurement.verticalSliceWidth) /
                    2;
            break;
        }

        labelElement.textDirection =
            isRtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
        break;
    }

    return Offset(labelX, labelY);
  }

  /// Gets the resolved location for a measure annotation label element.
  Offset _getMeasureLabelPosition(
    _AnnotationLabelType labelType,
    Rect bounds,
    _AnnotationElement<D> annotationElement,
    TextElement labelElement,
  ) {
    if (annotationElement.labelDirection == AnnotationLabelDirection.vertical) {
      return _getMeasureLabelPositionVertical(
        labelType,
        bounds,
        annotationElement,
        labelElement,
      );
    } else {
      return _getMeasureLabelPositionHorizontal(
        labelType,
        bounds,
        annotationElement,
        labelElement,
      );
    }
  }

  /// Gets the resolved location for a horizontal measure annotation label
  /// element.
  Offset _getMeasureLabelPositionHorizontal(
    _AnnotationLabelType labelType,
    Rect bounds,
    _AnnotationElement<D> annotationElement,
    TextElement labelElement,
  ) {
    var labelX = 0.0;
    var labelY = 0.0;

    final calculatedLabelPosition =
        _resolveAutoLabelPosition(bounds, annotationElement, labelElement);

    switch (annotationElement.labelAnchor) {
      case AnnotationLabelAnchor.middle:
        labelX = bounds.left +
            bounds.width / 2 -
            labelElement.measurement.horizontalSliceWidth / 2;
        labelElement.textDirection =
            isRtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
        break;

      case AnnotationLabelAnchor.end:
      case AnnotationLabelAnchor.start:
        if (annotationElement.labelPosition == AnnotationLabelPosition.margin) {
          final alignLeft = isRtl
              ? (annotationElement.labelAnchor == AnnotationLabelAnchor.end)
              : (annotationElement.labelAnchor == AnnotationLabelAnchor.start);

          if (alignLeft) {
            labelX = bounds.left - labelPadding;
            labelElement.textDirection = TextDirectionAligment.rtl;
          } else {
            labelX = bounds.right + labelPadding;
            labelElement.textDirection = TextDirectionAligment.ltr;
          }
        } else {
          final alignLeft = isRtl
              ? (annotationElement.labelAnchor == AnnotationLabelAnchor.end)
              : (annotationElement.labelAnchor == AnnotationLabelAnchor.start);

          if (alignLeft) {
            labelX = bounds.left + labelPadding;
            labelElement.textDirection = TextDirectionAligment.ltr;
          } else {
            labelX = bounds.right - labelPadding;
            labelElement.textDirection = TextDirectionAligment.rtl;
          }
        }
        break;
    }

    switch (calculatedLabelPosition) {
      case AnnotationLabelPosition.margin:
      case AnnotationLabelPosition.auto:
        throw ArgumentError(_unresolvedAutoMessage);

      case AnnotationLabelPosition.outside:
        switch (labelType) {
          case _AnnotationLabelType.start:
            labelY = bounds.bottom + labelPadding;
            break;
          case _AnnotationLabelType.end:
            labelY = bounds.top -
                labelElement.measurement.verticalSliceWidth -
                labelPadding;
            break;
          case _AnnotationLabelType.middle:
            labelY = bounds.top +
                (bounds.height - labelElement.measurement.verticalSliceWidth) /
                    2;
            break;
        }
        break;

      case AnnotationLabelPosition.inside:
        switch (labelType) {
          case _AnnotationLabelType.start:
            labelY = bounds.bottom -
                labelElement.measurement.verticalSliceWidth -
                labelPadding;
            break;
          case _AnnotationLabelType.end:
            labelY = bounds.top + labelPadding;
            break;
          case _AnnotationLabelType.middle:
            labelY = bounds.top +
                (bounds.height - labelElement.measurement.verticalSliceWidth) /
                    2;
            break;
        }
        break;
    }

    return Offset(labelX, labelY);
  }

  /// Gets the resolved location for a vertical measure annotation label
  /// element.
  Offset _getMeasureLabelPositionVertical(
    _AnnotationLabelType labelType,
    Rect bounds,
    _AnnotationElement<D> annotationElement,
    TextElement labelElement,
  ) {
    var labelX = 0.0;
    var labelY = 0.0;

    final calculatedLabelPosition =
        _resolveAutoLabelPosition(bounds, annotationElement, labelElement);

    switch (annotationElement.labelAnchor) {
      case AnnotationLabelAnchor.middle:
        labelX = bounds.left +
            bounds.width / 2 -
            labelElement.measurement.verticalSliceWidth / 2;
        labelElement.textDirection =
            isRtl ? TextDirectionAligment.rtl : TextDirectionAligment.ltr;
        break;

      case AnnotationLabelAnchor.end:
      case AnnotationLabelAnchor.start:
        if (annotationElement.labelPosition == AnnotationLabelPosition.margin) {
          final alignLeft = isRtl
              ? (annotationElement.labelAnchor == AnnotationLabelAnchor.end)
              : (annotationElement.labelAnchor == AnnotationLabelAnchor.start);

          if (alignLeft) {
            labelX = bounds.left -
                labelElement.measurement.verticalSliceWidth -
                labelPadding;
            labelElement.textDirection = TextDirectionAligment.ltr;
          } else {
            labelX = bounds.right + labelPadding;
            labelElement.textDirection = TextDirectionAligment.ltr;
          }
        } else {
          final alignLeft = isRtl
              ? (annotationElement.labelAnchor == AnnotationLabelAnchor.end)
              : (annotationElement.labelAnchor == AnnotationLabelAnchor.start);

          if (alignLeft) {
            labelX = bounds.left + labelPadding;
            labelElement.textDirection = TextDirectionAligment.ltr;
          } else {
            labelX = bounds.right -
                labelElement.measurement.verticalSliceWidth -
                labelPadding;
            labelElement.textDirection = TextDirectionAligment.ltr;
          }
        }
        break;
    }

    switch (calculatedLabelPosition) {
      case AnnotationLabelPosition.margin:
      case AnnotationLabelPosition.auto:
        throw ArgumentError(_unresolvedAutoMessage);

      case AnnotationLabelPosition.outside:
        switch (labelType) {
          case _AnnotationLabelType.start:
            labelY = bounds.bottom +
                labelElement.measurement.horizontalSliceWidth +
                labelPadding;
            break;
          case _AnnotationLabelType.end:
            labelY = bounds.top - labelPadding;
            break;
          case _AnnotationLabelType.middle:
            labelY = bounds.bottom +
                (labelElement.measurement.horizontalSliceWidth -
                        bounds.height) /
                    2;
            break;
        }
        break;

      case AnnotationLabelPosition.inside:
        switch (labelType) {
          case _AnnotationLabelType.start:
            labelY = bounds.bottom - labelPadding;
            break;
          case _AnnotationLabelType.end:
            labelY = bounds.top +
                labelElement.measurement.horizontalSliceWidth +
                labelPadding;
            break;
          case _AnnotationLabelType.middle:
            labelY = bounds.bottom +
                (labelElement.measurement.horizontalSliceWidth -
                        bounds.height) /
                    2;
            break;
        }
        break;
    }

    return Offset(labelX, labelY);
  }

  /// Resolves [AnnotationLabelPosition.auto] configuration for an annotation
  /// into an inside or outside position, depending on the size of the
  /// annotation and the chart draw area.
  AnnotationLabelPosition _resolveAutoLabelPosition(
    Rect bounds,
    _AnnotationElement<D> annotationElement,
    TextElement labelElement,
  ) {
    var calculatedLabelPosition = annotationElement.labelPosition;
    if (calculatedLabelPosition == AnnotationLabelPosition.auto ||
        calculatedLabelPosition == AnnotationLabelPosition.margin) {
      final isDomain = annotationElement.annotation.axisType ==
          RangeAnnotationAxisType.domain;

      final annotationBoundsSize = isDomain ? bounds.width : bounds.height;

      final drawBoundsSize = isDomain ? drawBounds.width : drawBounds.height;

      final isVertical =
          annotationElement.labelDirection == AnnotationLabelDirection.vertical;

      final labelSize = isDomain && isVertical || !isDomain && !isVertical
          ? labelElement.measurement.verticalSliceWidth
          : labelElement.measurement.horizontalSliceWidth;

      // Get space available inside and outside the annotation.
      final totalPadding = labelPadding * 2;
      final insideBarWidth = annotationBoundsSize - totalPadding;
      final outsideBarWidth =
          drawBoundsSize - annotationBoundsSize - totalPadding;

      // A label fits if the space inside the annotation is >= outside
      // annotation or if the length of the text fits and the space. This is
      // because if the annotation has more space than the outside, it makes
      // more sense to place the label inside the annotation, even if the
      // entire label does not fit.
      calculatedLabelPosition =
          (insideBarWidth >= outsideBarWidth || labelSize < insideBarWidth)
              ? AnnotationLabelPosition.inside
              : AnnotationLabelPosition.outside;
    }

    return calculatedLabelPosition;
  }

  @override
  Rect get componentBounds => _drawAreaBounds;

  @override
  bool get isSeriesRenderer => false;

  // Helper function that converts [TextStyle] to [TextStyle].
  TextStyle _getTextStyle(
    GraphicsFactory graphicsFactory,
    TextStyle labelSpec,
  ) {
    return graphicsFactory
        .createTextPaint()
        .copyWith(color: Colors.black, fontSize: 12)
        .merge(labelSpec);
  }
}

class _DatumAnnotation {
  _DatumAnnotation({
    required this.startPosition,
    required this.endPosition,
    required this.axisType,
  });

  factory _DatumAnnotation.from(
    _DatumAnnotation other, [
    double? startPosition,
    double? endPosition,
  ]) {
    return _DatumAnnotation(
      startPosition: startPosition ?? other.startPosition,
      endPosition: endPosition ?? other.endPosition,
      axisType: other.axisType,
    );
  }
  final double startPosition;
  final double endPosition;
  final RangeAnnotationAxisType axisType;
}

class _AnnotationElement<D> {
  _AnnotationElement({
    required this.annotation,
    required this.annotationSegment,
    required this.color,
    required this.startLabel,
    required this.endLabel,
    required this.middleLabel,
    required this.isRange,
    required this.labelAnchor,
    required this.labelDirection,
    required this.labelPosition,
    required this.labelStyleSpec,
    required this.dashPattern,
    required this.strokeWidth,
  });
  _DatumAnnotation annotation;
  final AnnotationSegment<Object> annotationSegment;
  Color? color;
  final String? startLabel;
  final String? endLabel;
  final String? middleLabel;
  final bool isRange;
  final AnnotationLabelAnchor labelAnchor;
  final AnnotationLabelDirection labelDirection;
  final AnnotationLabelPosition labelPosition;
  final TextStyle labelStyleSpec;
  final List<int>? dashPattern;
  double strokeWidth;

  _AnnotationElement<D> clone() {
    return _AnnotationElement<D>(
      annotation: _DatumAnnotation.from(annotation),
      annotationSegment: annotationSegment,
      color: color,
      startLabel: startLabel,
      endLabel: endLabel,
      middleLabel: middleLabel,
      isRange: isRange,
      labelAnchor: labelAnchor,
      labelDirection: labelDirection,
      labelPosition: labelPosition,
      labelStyleSpec: labelStyleSpec,
      dashPattern: dashPattern,
      strokeWidth: strokeWidth,
    );
  }

  void updateAnimationPercent(
    _AnnotationElement<D> previous,
    _AnnotationElement<D> target,
    double animationPercent,
  ) {
    final targetAnnotation = target.annotation;
    final previousAnnotation = previous.annotation;

    final startPosition =
        ((targetAnnotation.startPosition - previousAnnotation.startPosition) *
                animationPercent) +
            previousAnnotation.startPosition;

    final endPosition =
        ((targetAnnotation.endPosition - previousAnnotation.endPosition) *
                animationPercent) +
            previousAnnotation.endPosition;

    annotation =
        _DatumAnnotation.from(targetAnnotation, startPosition, endPosition);

    color = getAnimatedColor(previous.color!, target.color!, animationPercent);

    strokeWidth =
        ((target.strokeWidth - previous.strokeWidth) * animationPercent) +
            previous.strokeWidth;
  }
}

enum _AnnotationLabelType {
  start,
  end,
  middle,
}

class _AnimatedAnnotation<D> {
  _AnimatedAnnotation({required this.key});
  final String key;

  _AnnotationElement<D>? _previousAnnotation;
  late _AnnotationElement<D> _targetAnnotation;
  _AnnotationElement<D>? _currentAnnotation;

  // Flag indicating whether this annotation is being animated out of the chart.
  bool animatingOut = false;

  /// Animates an annotation that was removed from the list out of the view.
  ///
  /// This should be called in place of "setNewTarget" for annotations have been
  /// removed from the list.
  /// TODO: Needed?
  void animateOut() {
    final newTarget = _currentAnnotation!.clone();

    setNewTarget(newTarget);
    animatingOut = true;
  }

  void setNewTarget(_AnnotationElement<D> newTarget) {
    animatingOut = false;
    _currentAnnotation ??= newTarget.clone();
    _previousAnnotation = _currentAnnotation!.clone();
    _targetAnnotation = newTarget;
  }

  _AnnotationElement<D> getCurrentAnnotation(double animationPercent) {
    if (animationPercent == 1.0 || _previousAnnotation == null) {
      _currentAnnotation = _targetAnnotation;
      _previousAnnotation = _targetAnnotation;
      return _currentAnnotation!;
    }

    _currentAnnotation!.updateAnimationPercent(
      _previousAnnotation!,
      _targetAnnotation,
      animationPercent,
    );

    return _currentAnnotation!;
  }
}

/// Helper class that exposes fewer private internal properties for unit tests.
@visibleForTesting
class RangeAnnotationTester<D> {
  RangeAnnotationTester(this.behavior);
  final RangeAnnotationState<D> behavior;

  set graphicsFactory(GraphicsFactory value) {
    behavior._view.graphicsFactory = value;
  }

  void mockLayout(Rect bounds) {
    behavior._view.layout(bounds, bounds);
  }

  /// Checks if an annotation exists with the given position and color.
  bool doesAnnotationExist({
    num? startPosition,
    num? endPosition,
    Color? color,
    List<int>? dashPattern,
    String? startLabel,
    String? endLabel,
    String? middleLabel,
    AnnotationLabelAnchor? labelAnchor,
    AnnotationLabelDirection? labelDirection,
    AnnotationLabelPosition? labelPosition,
  }) {
    for (final a in behavior._annotationMap.values) {
      final currentAnnotation = a._currentAnnotation!;
      final annotation = currentAnnotation.annotation;

      if (annotation.startPosition == startPosition &&
          annotation.endPosition == endPosition &&
          currentAnnotation.color == color &&
          currentAnnotation.startLabel == startLabel &&
          currentAnnotation.endLabel == endLabel &&
          currentAnnotation.middleLabel == middleLabel &&
          currentAnnotation.labelAnchor == labelAnchor &&
          currentAnnotation.labelDirection == labelDirection &&
          currentAnnotation.labelPosition == labelPosition &&
          (currentAnnotation is! LineAnnotationSegment ||
              currentAnnotation.dashPattern == dashPattern)) {
        return true;
      }
    }

    return false;
  }
}

/// Base class for chart annotations.
abstract class AnnotationSegment<D> {
  AnnotationSegment(
    this.axisType, {
    this.axisId,
    this.color,
    this.startLabel,
    this.endLabel,
    this.middleLabel,
    this.labelAnchor,
    this.labelDirection,
    this.labelPosition,
    this.labelStyleSpec,
  });
  final RangeAnnotationAxisType axisType;
  final String? axisId;
  final Color? color;
  final String? startLabel;
  final String? endLabel;
  final String? middleLabel;
  final AnnotationLabelAnchor? labelAnchor;
  final AnnotationLabelDirection? labelDirection;
  final AnnotationLabelPosition? labelPosition;
  final TextStyle? labelStyleSpec;

  String get key;
}

/// Data for a chart range annotation.
class RangeAnnotationSegment<D> extends AnnotationSegment<D> {
  RangeAnnotationSegment(
    this.startValue,
    this.endValue,
    RangeAnnotationAxisType axisType, {
    String? axisId,
    Color? color,
    String? startLabel,
    String? endLabel,
    String? middleLabel,
    AnnotationLabelAnchor? labelAnchor,
    AnnotationLabelDirection? labelDirection,
    AnnotationLabelPosition? labelPosition,
    TextStyle? labelStyleSpec,
  }) : super(
          axisType,
          axisId: axisId,
          color: color,
          startLabel: startLabel,
          endLabel: endLabel,
          middleLabel: middleLabel,
          labelAnchor: labelAnchor,
          labelDirection: labelDirection,
          labelPosition: labelPosition,
          labelStyleSpec: labelStyleSpec,
        );
  final D startValue;
  final D endValue;

  @override
  String get key => 'r::$axisType::$axisId::$startValue::$endValue';
}

/// Data for a chart line annotation.
class LineAnnotationSegment<D> extends AnnotationSegment<D> {
  LineAnnotationSegment(
    this.value,
    RangeAnnotationAxisType axisType, {
    String? axisId,
    Color? color,
    String? startLabel,
    String? endLabel,
    String? middleLabel,
    AnnotationLabelAnchor? labelAnchor,
    AnnotationLabelDirection? labelDirection,
    AnnotationLabelPosition? labelPosition,
    TextStyle? labelStyleSpec,
    this.dashPattern,
    this.strokeWidth = _defaultStrokeWidth,
  }) : super(
          axisType,
          axisId: axisId,
          color: color,
          startLabel: startLabel,
          endLabel: endLabel,
          middleLabel: middleLabel,
          labelAnchor: labelAnchor,
          labelDirection: labelDirection,
          labelPosition: labelPosition,
          labelStyleSpec: labelStyleSpec,
        );
  final D value;
  final List<int>? dashPattern;
  final double strokeWidth;

  @override
  String get key => 'l::$axisType::$axisId::$value';
}

/// Axis type for an annotation.
enum RangeAnnotationAxisType {
  domain,
  measure,
}

/// Configures where to anchor the label.
enum AnnotationLabelAnchor {
  /// Anchor to the starting side of the annotation range.
  start,

  /// Anchor to the middle of the annotation range.
  middle,

  /// Anchor to the ending side of the annotation range.
  end,
}

/// Direction of the label text on the chart.
enum AnnotationLabelDirection {
  /// Automatically assign a direction based on the [RangeAnnotationAxisType].
  ///
  /// [horizontal] for measure axes, or [vertical] for domain axes.
  auto,

  /// Text flows parallel to the x axis.
  horizontal,

  /// Text flows parallel to the y axis.
  /// TODO[b/112553019]: Implement vertical text rendering of labels.
  vertical,
}

/// Configures where to place the label relative to the annotation.
enum AnnotationLabelPosition {
  /// Automatically try to place the label inside the bar first and place it on
  /// the outside of the space available outside the bar is greater than space
  /// available inside the bar.
  auto,

  /// Always place label on the outside.
  outside,

  /// Always place label on the inside.
  inside,

  /// Place the label outside of the draw area, in the chart margin.
  ///
  /// Labels will be rendered on the opposite side of the chart from the primary
  /// axis. For measure annotations, this means the "end" side, opposite from
  /// the "start" side where the primary measure axis is located.
  ///
  /// This should not be used for measure annotations if the chart has a
  /// secondary measure axis. The annotation behaviors do not perform collision
  /// detection with tick labels.
  margin,
}

const String _unresolvedAutoMessage = 'Unresolved AnnotationLabelPosition.auto';
