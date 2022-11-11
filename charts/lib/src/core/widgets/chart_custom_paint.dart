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

import 'package:charts/charts/time_series.dart';

import 'package:flutter/material.dart' hide AxisDirection;
import 'package:flutter/rendering.dart' hide AxisDirection;
import 'package:flutter/scheduler.dart';

/// Widget that inflates to a [CustomPaint] that implements common [ChartContext].
class ChartCustomPaint<D> extends CustomPaint {
  const ChartCustomPaint({
    super.key,
    this.oldChartWidget,
    required this.chartWidget,
    required this.chartState,
    required this.animationValue,
    required this.rtl,
    this.rtlSpec,
    this.userManagedState,
  });
  final BaseChart<D> chartWidget;
  final BaseChart<D>? oldChartWidget;
  final BaseChartState<D> chartState;
  final double animationValue;
  final bool rtl;
  final RTLSpec? rtlSpec;
  final UserManagedState<D>? userManagedState;

  @override
  RenderCustomPaint createRenderObject(BuildContext context) {
    return ChartContainerRenderObject<D>()..reconfigure(this, context);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    ChartContainerRenderObject renderObject,
  ) {
    renderObject.reconfigure(this, context);
  }
}

/// [RenderCustomPaint] that implements common [ChartContext].
class ChartContainerRenderObject<D> extends RenderCustomPaint
    implements ChartContext {
  BaseRenderChart<D>? _chart;
  List<Series<dynamic, D>>? _seriesList;
  late BaseChartState<D> _chartState;
  bool _chartContainerIsRtl = false;
  RTLSpec? _rtlSpec;
  DateTimeFactory? _dateTimeFactory;
  bool _exploreMode = false;
  List<A11yNode>? _a11yNodes;

  void reconfigure(ChartCustomPaint<D> config, BuildContext context) {
    _chartState = config.chartState;

    _dateTimeFactory = (config.chartWidget is TimeSeriesChart)
        ? (config.chartWidget as TimeSeriesChart).dateTimeFactory
        : null;
    _dateTimeFactory ??= const LocalDateTimeFactory();

    if (_chart == null) {
      Performance.time('chartsCreate');
      _chart = config.chartWidget.createRenderChart(_chartState);
      _chart!.init(this, FlutterGraphicsFactory(context));
      Performance.timeEnd('chartsCreate');
    }
    Performance.time('chartsConfig');
    config.chartWidget
        .updateRenderChart(_chart!, config.oldChartWidget, _chartState);

    _rtlSpec = config.rtlSpec;
    _chartContainerIsRtl = config.rtl;

    Performance.timeEnd('chartsConfig');

    if (_chartState.chartIsDirty) {
      _chart!.configurationChanged();
    }

    // If series list changes or other configuration changed that triggered the
    // _chartState.configurationChanged flag to be set (such as axis, behavior,
    // and renderer changes). Otherwise, the chart only requests repainting and
    // does not reprocess the series.
    //
    // Series list is considered "changed" based on the instance.
    if (_seriesList != config.chartWidget.series || _chartState.chartIsDirty) {
      _chartState.resetChartDirtyFlag();
      _seriesList = config.chartWidget.series;

      // Clear out the a11y nodes generated.
      _a11yNodes = null;

      Performance.time('chartsDraw');
      _chart!.draw(_seriesList!);
      Performance.timeEnd('chartsDraw');

      // This is needed because when a series changes we need to reset flutter's
      // animation value from 1.0 back to 0.0.
      _chart!.animationPercent = 0.0;
      markNeedsLayout();
    } else {
      _chart!.animationPercent = config.animationValue;
      markNeedsPaint();
    }

    _updateUserManagedState(config.userManagedState);

    // Set the painter used for calling common chart for paint.
    // This painter is also used to generate semantic nodes for a11y.
    _setNewPainter();
  }

  /// If user managed state is set, check each setting to see if it is different
  /// than internal chart state and only update if different.
  void _updateUserManagedState(UserManagedState<D>? newState) {
    if (newState == null) {
      return;
    }

    // Only override the selection model if it is different than the existing
    // selection model so update listeners are not unnecessarily triggered.
    for (final type in newState.selectionModels.keys) {
      final model = _chart!.getSelectionModel(type);

      final userModel =
          newState.selectionModels[type]!.getModel(_chart!.currentSeriesList);

      if (model != userModel) {
        model.updateSelection(
          userModel.selectedDatum,
          userModel.selectedSeries,
        );
      }
    }
  }

  @override
  void performLayout() {
    Performance.time('chartsLayout');
    _chart!
        .measure(constraints.maxWidth.toInt(), constraints.maxHeight.toInt());
    _chart!.layout(constraints.maxWidth.toInt(), constraints.maxHeight.toInt());
    Performance.timeEnd('chartsLayout');
    size = constraints.biggest;

    // Check if the gestures registered in gesture registry matches what the
    // common chart is listening to.
    // TODO: Still need a test for this for sanity sake.
//    assert(_desiredGestures
//        .difference(_chart!.gestureProxy.listenedGestures)
//        .isEmpty);
  }

  @override
  void markNeedsLayout() {
    super.markNeedsLayout();
    if (parent != null) {
      markParentNeedsLayout();
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void requestRedraw() {}

  @override
  void requestAnimation(Duration transition) {
    void startAnimationController(_) {
      _chartState.setAnimation(transition);
    }

    // Sometimes chart behaviors try to draw the chart outside of a Flutter draw
    // cycle. Schedule a frame manually to handle these cases.
    if (!SchedulerBinding.instance.hasScheduledFrame) {
      SchedulerBinding.instance.scheduleFrame();
    }

    SchedulerBinding.instance.addPostFrameCallback(startAnimationController);
  }

  /// Request Flutter to rebuild the widget/container of chart.
  ///
  /// This is different than requesting redraw and paint because those only
  /// affect the chart widget. This is for requesting rebuild of the Flutter
  /// widget that contains the chart widget. This is necessary for supporting
  /// Flutter widgets that are layout with the chart.
  ///
  /// Example is legends, a legend widget can be layout on top of the chart
  /// widget or along the sides of the chart. Requesting a rebuild allows
  /// the legend to layout and redraw itself.
  void requestRebuild() {
    void doRebuild(_) {
      _chartState.requestRebuild();
    }

    // Flutter does not allow requesting rebuild during the build cycle, this
    // schedules rebuild request to happen after the current build cycle.
    // This is needed to request rebuild after the legend has been added in the
    // post process phase of the chart, which happens during the chart widget's
    // build cycle.
    SchedulerBinding.instance.addPostFrameCallback(doRebuild);
  }

  /// When Flutter's markNeedsLayout is called, layout and paint are both
  /// called. If animations are off, Flutter's paint call after layout will
  /// paint the chart. If animations are on, Flutter's paint is called with the
  /// initial animation value and then the animation controller is started after
  /// this first build cycle.
  @override
  void requestPaint() {
    markNeedsPaint();
  }

  @override
  double get pixelsPerDp => 1;

  @override
  bool get chartContainerIsRtl => _chartContainerIsRtl;

  @override
  RTLSpec? get rtlSpec => _rtlSpec;

  @override
  bool get isRtl =>
      _chartContainerIsRtl &&
      (_rtlSpec == null ||
          _rtlSpec?.axisDirection == AxisRTLDirection.reversed);

  @override
  bool get isTappable => _chart!.isTappable;

  @override
  DateTimeFactory get dateTimeFactory => _dateTimeFactory!;

  /// Gets the chart's gesture listener.
  ProxyGestureListener get gestureProxy => _chart!.gestureProxy;

  TextDirection get textDirection =>
      _chartContainerIsRtl ? TextDirection.rtl : TextDirection.ltr;

  @override
  void enableA11yExploreMode(List<A11yNode> nodes, {String? announcement}) {
    _a11yNodes = nodes;
    _exploreMode = true;
    _setNewPainter();
    requestRebuild();
    if (announcement != null) {
      SemanticsService.announce(announcement, textDirection);
    }
  }

  @override
  void disableA11yExploreMode({String? announcement}) {
    _a11yNodes = [];
    _exploreMode = false;
    _setNewPainter();
    requestRebuild();
    if (announcement != null) {
      SemanticsService.announce(announcement, textDirection);
    }
  }

  void _setNewPainter() {
    painter = ChartContainerCustomPaint(
      oldPainter: painter as ChartContainerCustomPaint?,
      chart: _chart!,
      exploreMode: _exploreMode,
      a11yNodes: _a11yNodes ?? [],
      textDirection: textDirection,
    );
  }
}

class ChartContainerCustomPaint extends CustomPainter {
  factory ChartContainerCustomPaint({
    ChartContainerCustomPaint? oldPainter,
    required BaseRenderChart chart,
    bool exploreMode = false,
    List<A11yNode> a11yNodes = const [],
    TextDirection textDirection = TextDirection.ltr,
  }) {
    if (oldPainter != null &&
        oldPainter.exploreMode == exploreMode &&
        oldPainter.a11yNodes == a11yNodes &&
        oldPainter.textDirection == textDirection) {
      return oldPainter;
    } else {
      return ChartContainerCustomPaint._internal(
        chart: chart,
        exploreMode: exploreMode,
        a11yNodes: a11yNodes,
        textDirection: textDirection,
      );
    }
  }

  ChartContainerCustomPaint._internal({
    required this.chart,
    required this.exploreMode,
    required this.a11yNodes,
    required this.textDirection,
  });
  final BaseRenderChart chart;
  final bool exploreMode;
  final List<A11yNode> a11yNodes;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    Performance.time('chartsPaint');
    final chartsCanvas = FlutterChartCanvas(canvas);
    chart.paint(chartsCanvas);
    Performance.timeEnd('chartsPaint');
  }

  /// Common chart requests rebuild that handle repaint requests.
  @override
  bool shouldRepaint(ChartContainerCustomPaint oldPainter) => false;

  /// Rebuild semantics when explore mode is toggled semantic properties change.
  @override
  bool shouldRebuildSemantics(ChartContainerCustomPaint oldDelegate) {
    return exploreMode != oldDelegate.exploreMode ||
        a11yNodes != oldDelegate.a11yNodes ||
        textDirection != textDirection;
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder => _buildSemantics;

  List<CustomPainterSemantics> _buildSemantics(Size size) {
    final nodes = <CustomPainterSemantics>[];

    for (final node in a11yNodes) {
      final rect = Rect.fromLTWH(
        node.boundingBox.left.toDouble(),
        node.boundingBox.top.toDouble(),
        node.boundingBox.width.toDouble(),
        node.boundingBox.height.toDouble(),
      );
      nodes.add(
        CustomPainterSemantics(
          rect: rect,
          properties: SemanticsProperties(
            value: node.label,
            textDirection: textDirection,
            onDidGainAccessibilityFocus: node.onFocus,
          ),
        ),
      );
    }

    return nodes;
  }
}
