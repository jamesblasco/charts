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

import 'package:charts/core.dart';
import 'package:meta/meta.dart' show protected;

class NumericCartesianRenderChart extends CartesianRenderChart<num> {
  NumericCartesianRenderChart({
    super.vertical,
    super.layoutConfig,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
  }) : super(
          domainAxis: NumericAxisElement(),
        );

  @protected
  @override
  void initDomainAxis() {
    _domainAxis!.tickDrawStrategy = const SmallTickAxisDecoration<num>()
        .createDrawStrategy(context, graphicsFactory!);
  }
}

class OrdinalCartesianRenderChart extends CartesianRenderChart<String> {
  OrdinalCartesianRenderChart({
    super.vertical,
    super.layoutConfig,
    super.primaryMeasureAxis,
    super.secondaryMeasureAxis,
    super.disjointMeasureAxes,
  }) : super(
          domainAxis: OrdinalAxisElement(),
        );

  @protected
  @override
  void initDomainAxis() {
    _domainAxis!.tickDrawStrategy = const SmallTickAxisDecoration<String>()
        .createDrawStrategy(context, graphicsFactory!);
  }
}

abstract class CartesianRenderChart<D> extends BaseRenderChart<D> {
  CartesianRenderChart({
    bool? vertical,
    LayoutConfig? layoutConfig,
    MutableAxisElement<D>? domainAxis,
    NumericAxisElement? primaryMeasureAxis,
    NumericAxisElement? secondaryMeasureAxis,
    LinkedHashMap<String, NumericAxisElement>? disjointMeasureAxes,
  })  : vertical = vertical ?? true,
        // [domainAxis] will be set to the new axis in [configurationChanged].
        _newDomainAxis = domainAxis,
        _primaryMeasureAxis = primaryMeasureAxis ?? NumericAxisElement(),
        _secondaryMeasureAxis = secondaryMeasureAxis ?? NumericAxisElement(),
        _disjointMeasureAxes =
            // ignore: prefer_collection_literals
            disjointMeasureAxes ?? LinkedHashMap<String, NumericAxisElement>(),
        super(layoutConfig: layoutConfig ?? _defaultLayoutConfig);
  static final _defaultLayoutConfig = LayoutConfig(
    topSpec: MarginSpec.fromPixel(minPixel: 20),
    bottomSpec: MarginSpec.fromPixel(minPixel: 20),
    leftSpec: MarginSpec.fromPixel(minPixel: 20),
    rightSpec: MarginSpec.fromPixel(minPixel: 20),
  );

  bool vertical;

  /// The current domain axis for this chart.
  MutableAxisElement<D>? _domainAxis;

  /// Temporarily stores the new domain axis that is passed in the constructor
  /// and the new domain axis created when [domainAxisSpec] is set to a new
  /// spec.
  ///
  /// This step is necessary because the axis cannot be fully configured until
  /// [context] is available. [configurationChanged] is called after [context]
  /// is available and [_newDomainAxis] will be set to [_domainAxis] and then
  /// reset back to null.
  MutableAxisElement<D>? _newDomainAxis;

  /// The current domain axis spec that was used to configure [_domainAxis].
  ///
  /// This is kept to check if the axis spec has changed when [domainAxisSpec]
  /// is set.
  AxisData<D>? _domainAxisSpec;

  /// Temporarily stores the new domain axis spec that is passed in when
  /// [domainAxisSpec] is set and is different from [_domainAxisSpec]. This spec
  /// is then applied to the new domain axis when [configurationChanged] is
  /// called.
  AxisData<D>? _newDomainAxisSpec;

  NumericAxis? _primaryMeasureAxisSpec;

  NumericAxis? _newPrimaryMeasureAxisSpec;

  NumericAxisElement _primaryMeasureAxis;

  NumericAxis? _secondaryMeasureAxisSpec;

  NumericAxis? _newSecondaryMeasureAxisSpec;

  NumericAxisElement _secondaryMeasureAxis;

  LinkedHashMap<String, NumericAxis>? _disjointMeasureAxesSpec;

  LinkedHashMap<String, NumericAxis>? _newDisjointMeasureAxesSpec;

  LinkedHashMap<String, NumericAxisElement> _disjointMeasureAxes;

  /// If set to true, the vertical axis will render the opposite of the default
  /// direction.
  bool flipVerticalAxisOutput = false;

  bool _usePrimaryMeasureAxis = false;
  bool _useSecondaryMeasureAxis = false;

  @override
  void init(ChartContext context, GraphicsFactory graphicsFactory) {
    super.init(context, graphicsFactory);

    _primaryMeasureAxis.context = context;
    _primaryMeasureAxis.tickDrawStrategy = const GridlineAxisDecoration<num>()
        .createDrawStrategy(context, graphicsFactory);

    _secondaryMeasureAxis.context = context;
    _secondaryMeasureAxis.tickDrawStrategy = const GridlineAxisDecoration<num>()
        .createDrawStrategy(context, graphicsFactory);

    _disjointMeasureAxes.forEach((String axisId, NumericAxisElement axis) {
      axis.context = context;
      axis.tickDrawStrategy = NoneDrawStrategy<num>(graphicsFactory);
    });
  }

  @override
  void updateConfig(LayoutConfig? layoutConfig) {
    super.updateConfig(layoutConfig ?? _defaultLayoutConfig);
  }

  MutableAxisElement<D>? get domainAxis => _domainAxis;

  /// Allows the chart to configure the domain axis when it is created.
  @protected
  void initDomainAxis();

  /// Create a new domain axis and save the new spec to be applied during
  /// [configurationChanged].
  set domainAxisSpec(AxisData<D> axisSpec) {
    if (_domainAxisSpec != axisSpec) {
      _newDomainAxis = createDomainAxisFromSpec(axisSpec);
      _newDomainAxisSpec = axisSpec;
    }
  }

  /// Creates the domain axis from a provided axis spec.
  @protected
  MutableAxisElement<D>? createDomainAxisFromSpec(AxisData<D> axisSpec) {
    return axisSpec.createElement();
  }

  @override
  void configurationChanged() {
    if (_newDomainAxis != null) {
      markChartDirty();
      if (_domainAxis != null) {
        removeView(_domainAxis!);
      }

      _domainAxis = _newDomainAxis;
      _domainAxis!
        ..context = context
        ..layoutPaintOrder = LayoutViewPaintOrder.domainAxis;

      initDomainAxis();

      addView(_domainAxis!);

      _newDomainAxis = null;
    }

    if (_newDomainAxisSpec != null) {
      markChartDirty();
      _domainAxisSpec = _newDomainAxisSpec;
      _newDomainAxisSpec!.configure(_domainAxis!, context, graphicsFactory!);
      _newDomainAxisSpec = null;
    }

    if (_primaryMeasureAxisSpec != _newPrimaryMeasureAxisSpec) {
      markChartDirty();
      _primaryMeasureAxisSpec = _newPrimaryMeasureAxisSpec;
      removeView(_primaryMeasureAxis);

      _primaryMeasureAxis =
          _primaryMeasureAxisSpec?.createElement() ?? NumericAxisElement();

      _primaryMeasureAxis.tickDrawStrategy = const GridlineAxisDecoration<num>()
          .createDrawStrategy(context, graphicsFactory!);

      _primaryMeasureAxisSpec?.configure(
        _primaryMeasureAxis,
        context,
        graphicsFactory!,
      );
      addView(_primaryMeasureAxis);
    }

    if (_secondaryMeasureAxisSpec != _newSecondaryMeasureAxisSpec) {
      markChartDirty();
      _secondaryMeasureAxisSpec = _newSecondaryMeasureAxisSpec;
      removeView(_secondaryMeasureAxis);

      _secondaryMeasureAxis =
          _secondaryMeasureAxisSpec?.createElement() ?? NumericAxisElement();

      _secondaryMeasureAxis.tickDrawStrategy =
          const GridlineAxisDecoration<num>()
              .createDrawStrategy(context, graphicsFactory!);

      _secondaryMeasureAxisSpec?.configure(
        _secondaryMeasureAxis,
        context,
        graphicsFactory!,
      );
      addView(_secondaryMeasureAxis);
    }

    if (_disjointMeasureAxesSpec != _newDisjointMeasureAxesSpec) {
      markChartDirty();
      _disjointMeasureAxesSpec = _newDisjointMeasureAxesSpec;
      _disjointMeasureAxes.forEach((String axisId, NumericAxisElement axis) {
        removeView(axis);
      });

      // ignore: prefer_collection_literals, https://github.com/dart-lang/linter/issues/1649
      _disjointMeasureAxes = LinkedHashMap<String, NumericAxisElement>();
      _disjointMeasureAxesSpec?.forEach((axisId, axisSpec) {
        _disjointMeasureAxes[axisId] = axisSpec.createElement();
        _disjointMeasureAxes[axisId]!.tickDrawStrategy =
            NoneDrawStrategy<num>(graphicsFactory!);
        axisSpec.configure(
          _disjointMeasureAxes[axisId]!,
          context,
          graphicsFactory!,
        );
        addView(_disjointMeasureAxes[axisId]!);
      });
    }
  }

  /// Gets the measure axis matching the provided id.
  ///
  /// If none is provided, this returns the primary measure axis.
  NumericAxisElement getMeasureAxis({String? axisId}) {
    NumericAxisElement? axis;
    if (axisId == MutableAxisElement.secondaryMeasureAxisId) {
      axis = _secondaryMeasureAxis;
    } else if (axisId == MutableAxisElement.primaryMeasureAxisId) {
      axis = _primaryMeasureAxis;
    } else if (axisId != null && _disjointMeasureAxes[axisId] != null) {
      axis = _disjointMeasureAxes[axisId];
    }

    // If no valid axisId was provided, fall back to primary axis.
    axis ??= _primaryMeasureAxis;

    return axis;
  }

  /// Sets the primary measure axis for the chart, rendered on the start side of
  /// the domain axis.
  set primaryMeasureAxisSpec(NumericAxis? axisSpec) {
    _newPrimaryMeasureAxisSpec = axisSpec;
  }

  /// Sets the secondary measure axis for the chart, rendered on the end side of
  /// the domain axis.
  set secondaryMeasureAxisSpec(NumericAxis? axisSpec) {
    _newSecondaryMeasureAxisSpec = axisSpec;
  }

  /// Sets a map of disjoint measure axes for the chart.
  ///
  /// Disjoint measure axes can be used to scale a sub-set of series on the
  /// chart independently from the primary and secondary axes. The general use
  /// case for this type of chart is to show differences in the trends of the
  /// data, without comparing their absolute values.
  ///
  /// Disjoint axes will not render any tick or gridline elements. With
  /// independent scales, there would be a lot of collision in labels were they
  /// to do so.
  ///
  /// If any series is rendered with a disjoint axis, it is highly recommended
  /// to render all series with disjoint axes. Otherwise, the chart may be
  /// visually misleading.
  ///
  /// A [LinkedHashMap] is used to ensure consistent ordering when painting the
  /// axes.
  set disjointMeasureAxisSpecs(
    LinkedHashMap<String, NumericAxis>? axisSpecs,
  ) {
    _newDisjointMeasureAxesSpec = axisSpecs;
  }

  @override
  MutableSeries<D> makeSeries(Series<dynamic, D> series) {
    final s = super.makeSeries(series);

    s.measureOffsetFn ??= (_) => 0;

    // Setup the Axes
    s.setAttr(domainAxisKey, domainAxis);
    s.setAttr(
      measureAxisKey,
      getMeasureAxis(axisId: series.getAttribute(measureAxisIdKey)),
    );

    return s;
  }

  @override
  SeriesRenderer<D> makeDefaultRenderer() {
    throw UnimplementedError();
    // return BarRenderer()..rendererId = SeriesRenderer.defaultRendererId;
  }

  @override
  Map<String, List<MutableSeries<D>>> preprocessSeries(
    List<MutableSeries<D>> seriesList,
  ) {
    final rendererToSeriesList = super.preprocessSeries(seriesList);
    _useSecondaryMeasureAxis = false;
    // Check if primary or secondary measure axis is being used.
    for (final series in seriesList) {
      final measureAxisId = series.getAttr(measureAxisIdKey);
      _usePrimaryMeasureAxis = _usePrimaryMeasureAxis ||
          (measureAxisId == null ||
              measureAxisId == MutableAxisElement.primaryMeasureAxisId);
      _useSecondaryMeasureAxis = _useSecondaryMeasureAxis ||
          (measureAxisId == MutableAxisElement.secondaryMeasureAxisId);
    }

    // Add or remove the primary axis view.
    if (_usePrimaryMeasureAxis) {
      addView(_primaryMeasureAxis);
    } else {
      removeView(_primaryMeasureAxis);
    }

    // Add or remove the secondary axis view.
    if (_useSecondaryMeasureAxis) {
      addView(_secondaryMeasureAxis);
    } else {
      removeView(_secondaryMeasureAxis);
    }

    // Add all disjoint axis views so that their range will be configured.
    _disjointMeasureAxes.forEach((String axisId, NumericAxisElement axis) {
      addView(axis);
    });

    final domainAxis = this.domainAxis!;

    // Reset stale values from previous draw cycles.
    domainAxis.resetDomains();
    _primaryMeasureAxis.resetDomains();
    _secondaryMeasureAxis.resetDomains();

    _disjointMeasureAxes.forEach((String axisId, NumericAxisElement axis) {
      axis.resetDomains();
    });

    final reverseAxisDirection = context.isRtl;

    if (vertical) {
      domainAxis
        ..axisOrientation = AxisOrientation.bottom
        ..reverseOutputRange = reverseAxisDirection;

      _primaryMeasureAxis
        ..axisOrientation = (reverseAxisDirection
            ? AxisOrientation.right
            : AxisOrientation.left)
        ..reverseOutputRange = flipVerticalAxisOutput;

      _secondaryMeasureAxis
        ..axisOrientation = (reverseAxisDirection
            ? AxisOrientation.left
            : AxisOrientation.right)
        ..reverseOutputRange = flipVerticalAxisOutput;

      _disjointMeasureAxes.forEach((String axisId, NumericAxisElement axis) {
        axis
          ..axisOrientation = (reverseAxisDirection
              ? AxisOrientation.left
              : AxisOrientation.right)
          ..reverseOutputRange = flipVerticalAxisOutput;
      });
    } else {
      domainAxis
        ..axisOrientation = (reverseAxisDirection
            ? AxisOrientation.right
            : AxisOrientation.left)
        ..reverseOutputRange = flipVerticalAxisOutput;

      _primaryMeasureAxis
        ..axisOrientation = AxisOrientation.bottom
        ..reverseOutputRange = reverseAxisDirection;

      _secondaryMeasureAxis
        ..axisOrientation = AxisOrientation.top
        ..reverseOutputRange = reverseAxisDirection;

      _disjointMeasureAxes.forEach((String axisId, NumericAxisElement axis) {
        axis
          ..axisOrientation = AxisOrientation.top
          ..reverseOutputRange = reverseAxisDirection;
      });
    }

    // Have each renderer configure the axes with their domain and measure
    // values.
    rendererToSeriesList
        .forEach((String rendererId, List<MutableSeries<D>> seriesList) {
      getSeriesRenderer(rendererId).configureDomainAxes(seriesList);
      getSeriesRenderer(rendererId).configureMeasureAxes(seriesList);
    });

    return rendererToSeriesList;
  }

  @override
  void onSkipLayout() {
    // Update ticks only when skipping layout.
    domainAxis!.updateTicks();

    if (_usePrimaryMeasureAxis) {
      _primaryMeasureAxis.updateTicks();
    }

    if (_useSecondaryMeasureAxis) {
      _secondaryMeasureAxis.updateTicks();
    }

    _disjointMeasureAxes.forEach((String axisId, NumericAxisElement axis) {
      axis.updateTicks();
    });

    super.onSkipLayout();
  }

  @override
  void onPostLayout(Map<String, List<MutableSeries<D>>> rendererToSeriesList) {
    fireOnAxisConfigured();

    super.onPostLayout(rendererToSeriesList);
  }

  /// Returns a list of datum details from selection model of [type].
  @override
  List<DatumDetails<D>> getDatumDetails(SelectionModelType type) {
    final entries = <DatumDetails<D>>[];

    getSelectionModel(type).selectedDatum.forEach((seriesDatum) {
      final series = seriesDatum.series;
      final Object? datum = seriesDatum.datum;
      final datumIndex = seriesDatum.index;

      final domain = series.domainFn(datumIndex);
      final domainFormatterFn = series.domainFormatterFn;
      final measure = series.measureFn(datumIndex);
      final measureFormatterFn = series.measureFormatterFn;
      final measureOffset = series.measureOffsetFn!(datumIndex);
      final rawMeasure = series.rawMeasureFn(datumIndex);
      final color = series.colorFn!(datumIndex);

      final renderer = getSeriesRenderer(series.getAttr(rendererIdKey));

      final datumDetails = renderer.addPositionToDetailsForSeriesDatum(
        DatumDetails(
          datum: datum,
          domain: domain,
          domainFormatter: domainFormatterFn?.call(datumIndex),
          index: datumIndex,
          measure: measure,
          measureFormatter: measureFormatterFn?.call(datumIndex),
          measureOffset: measureOffset,
          rawMeasure: rawMeasure,
          series: series,
          color: color,
        ),
        seriesDatum,
      );

      entries.add(datumDetails);
    });

    return entries;
  }
}
