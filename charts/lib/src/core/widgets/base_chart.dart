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
import 'package:flutter/widgets.dart';

@immutable
abstract class BaseChart<D> extends StatefulWidget {
  const BaseChart(
    this.series, {
    super.key,
    bool? animate,
    Duration? animationDuration,
    this.defaultRenderer,
    this.customSeriesRenderers,
    this.behaviors,
    this.selectionModels,
    this.rtlSpec,
    this.defaultInteractions = true,
    this.layoutConfig,
    this.userManagedState,
  })  : animate = animate ?? true,
        animationDuration =
            animationDuration ?? const Duration(milliseconds: 300);

  /// Series list to draw.
  final List<Series<dynamic, D>> series;

  /// Animation transitions.
  final bool animate;
  final Duration animationDuration;

  /// Used to configure the margin sizes around the drawArea that the axis and
  /// other things render into.
  final LayoutConfig? layoutConfig;

  // Default renderer used to draw series data on the chart.
  final SeriesRendererConfig<D>? defaultRenderer;

  /// Include the default interactions or not.
  final bool defaultInteractions;

  final List<ChartBehavior<D>>? behaviors;

  final List<SelectionModelConfig<D>>? selectionModels;

  // List of custom series renderers used to draw series data on the chart.
  //
  // Series assigned a rendererIdKey will be drawn with the matching renderer in
  // this list. Series without a rendererIdKey will be drawn by the default
  // renderer.
  final List<SeriesRendererConfig<D>>? customSeriesRenderers;

  /// The spec to use if RTL is enabled.
  final RTLSpec? rtlSpec;

  /// Optional state that overrides internally kept state, such as selection.
  final UserManagedState<D>? userManagedState;

  @override
  BaseChartState<D> createState() => BaseChartState<D>();

  /// Creates and returns a [BaseRenderChart].
  BaseRenderChart<D> createRenderChart(BaseChartState<D> chartState);

  /// Updates the [BaseRenderChart].
  void updateRenderChart(
    BaseRenderChart<D> chart,
    BaseChart<D>? oldWidget,
    BaseChartState<D> chartState,
  ) {
    Performance.time('chartsUpdateRenderers');
    // Set default renderer if one was provided.
    if (defaultRenderer != null &&
        defaultRenderer != oldWidget?.defaultRenderer) {
      chart.defaultRenderer = defaultRenderer!.build();
      chartState.markChartDirty();
    }

    // Add custom series renderers if any were provided.
    if (customSeriesRenderers != null) {
      // TODO: This logic does not remove old renderers and
      // shouldn't require the series configs to remain in the same order.
      for (var i = 0; i < customSeriesRenderers!.length; i++) {
        if (oldWidget == null ||
            (oldWidget.customSeriesRenderers != null &&
                i > oldWidget.customSeriesRenderers!.length) ||
            customSeriesRenderers![i] != oldWidget.customSeriesRenderers![i]) {
          chart.addSeriesRenderer(customSeriesRenderers![i].build());
          chartState.markChartDirty();
        }
      }
    }
    Performance.timeEnd('chartsUpdateRenderers');

    Performance.time('chartsUpdateBehaviors');
    _updateBehaviors(chart, chartState);
    Performance.timeEnd('chartsUpdateBehaviors');

    _updateSelectionModel(chart, chartState);

    chart.transition = animate ? animationDuration : Duration.zero;
  }

  void _updateBehaviors(
    BaseRenderChart<D> chart,
    BaseChartState<D> chartState,
  ) {
    final behaviorList = List<ChartBehavior<D>>.from(behaviors ?? []);

    // Insert automatic behaviors to the front of the behavior list.
    if (defaultInteractions) {
      if (chartState.autoBehaviorWidgets.isEmpty) {
        addDefaultInteractions(chartState.autoBehaviorWidgets);
      }

      // Add default interaction behaviors to the front of the list if they
      // don't conflict with user behaviors by role.
      chartState.autoBehaviorWidgets.reversed
          .where(_notACustomBehavior)
          .forEach((ChartBehavior<D> behavior) {
        behaviorList.insert(0, behavior);
      });
    }

    // Remove any behaviors from the chart that are not in the incoming list.
    // Walk in reverse order they were added.
    // Also, remove any persisting behaviors from incoming list.
    for (var i = chartState.addedBehaviorWidgets.length - 1; i >= 0; i--) {
      final addedBehavior = chartState.addedBehaviorWidgets[i];
      if (!behaviorList.remove(addedBehavior)) {
        final role = addedBehavior.role;
        chartState.addedBehaviorWidgets.remove(addedBehavior);
        chartState.addedCommonBehaviorsByRole.remove(role);
        chart.removeBehavior(chartState.addedCommonBehaviorsByRole[role]);
        chartState.markChartDirty();
      }
    }

    // Add any remaining/behaviors.
    for (final behaviorWidget in behaviorList) {
      final commonBehavior = behaviorWidget.createBehaviorState();

      // Assign the chart state to any behavior that needs it.
      if (commonBehavior is ChartStateBehavior) {
        (commonBehavior as ChartStateBehavior).chartState = chartState;
      }

      chart.addBehavior(commonBehavior);
      chartState.addedBehaviorWidgets.add(behaviorWidget);
      chartState.addedCommonBehaviorsByRole[behaviorWidget.role] =
          commonBehavior;
      chartState.markChartDirty();
    }
  }

  /// Create the list of default interaction behaviors.
  void addDefaultInteractions(List<ChartBehavior<D>> behaviors) {
    // Update selection model
    behaviors.add(
      SelectNearest<D>(),
    );
  }

  bool _notACustomBehavior(ChartBehavior<D> behavior) {
    return behaviors == null ||
        !behaviors!.any(
          (ChartBehavior<D> userBehavior) => userBehavior.role == behavior.role,
        );
  }

  void _updateSelectionModel(
    BaseRenderChart<D> chart,
    BaseChartState<D> chartState,
  ) {
    final prevTypes = List<SelectionModelType>.from(
      chartState.addedSelectionChangedListenersByType.keys,
    );

    // Update any listeners for each type.
    selectionModels?.forEach((SelectionModelConfig<D> model) {
      final selectionModel = chart.getSelectionModel(model.type);

      final prevChangedListener =
          chartState.addedSelectionChangedListenersByType[model.type];
      if (!identical(model.changedListener, prevChangedListener)) {
        if (prevChangedListener != null) {
          selectionModel.removeSelectionChangedListener(prevChangedListener);
        }
        selectionModel.addSelectionChangedListener(model.changedListener!);
        chartState.addedSelectionChangedListenersByType[model.type] =
            model.changedListener!;
      }

      final prevUpdatedListener =
          chartState.addedSelectionUpdatedListenersByType[model.type];
      if (!identical(model.updatedListener, prevUpdatedListener)) {
        if (prevUpdatedListener != null) {
          selectionModel.removeSelectionUpdatedListener(prevUpdatedListener);
        }
        selectionModel.addSelectionUpdatedListener(model.updatedListener!);
        chartState.addedSelectionUpdatedListenersByType[model.type] =
            model.updatedListener!;
      }

      prevTypes.remove(model.type);
    });

    // Remove any lingering listeners.
    for (final type in prevTypes) {
      chart.getSelectionModel(type)
        ..removeSelectionChangedListener(
          chartState.addedSelectionChangedListenersByType[type]!,
        )
        ..removeSelectionUpdatedListener(
          chartState.addedSelectionUpdatedListenersByType[type]!,
        );
    }
  }

  /// Gets distinct set of gestures this chart will subscribe to.
  ///
  /// This is needed to allow setup of the [GestureDetector] widget with only
  /// gestures we need to listen to and it must wrap [ChartContainer] widget.
  /// Gestures are then setup to be proxied in [BaseRenderChart] and that is
  /// held by [ChartContainerRenderObject].
  Set<GestureType> getDesiredGestures(BaseChartState<D> chartState) {
    final types = <GestureType>{};
    behaviors?.forEach((ChartBehavior<D> behavior) {
      types.addAll(behavior.desiredGestures);
    });

    if (defaultInteractions && chartState.autoBehaviorWidgets.isEmpty) {
      addDefaultInteractions(
        List<ChartBehavior<D>>.from(chartState.autoBehaviorWidgets),
      );
    }

    for (final behavior in chartState.autoBehaviorWidgets) {
      types.addAll(behavior.desiredGestures);
    }
    return types;
  }
}
