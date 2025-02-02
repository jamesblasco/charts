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

/// Returns a string for a11y vocalization from a list of series datum.
typedef VocalizationCallback<D> = String Function(
  List<SeriesDatum<D>> seriesDatums,
);

/// A simple vocalization that returns the domain value to string.
String domainVocalization<D>(List<SeriesDatum<D>> seriesDatums) {
  final datumIndex = seriesDatums.first.index;
  final domainFn = seriesDatums.first.series.domainFn;
  final domain = domainFn(datumIndex);

  return domain.toString();
}

/// Behavior that generates semantic nodes for each domain.
class DomainA11yExploreBehaviorState<D> extends A11yExploreBehaviorState<D> {
  DomainA11yExploreBehaviorState({
    VocalizationCallback<D>? vocalizationCallback,
    super.exploreModeTrigger,
    super.minimumWidth,
    super.exploreModeEnabledAnnouncement,
    super.exploreModeDisabledAnnouncement,
  }) : _vocalizationCallback = vocalizationCallback ?? domainVocalization {
    _lifecycleListener = LifecycleListener<D>(onPostprocess: _updateSeriesList);
  }
  final VocalizationCallback<D> _vocalizationCallback;
  late final LifecycleListener<D> _lifecycleListener;
  late CartesianRenderChart<D> _chart;
  late List<MutableSeries<D>> _seriesList;

  @override
  List<A11yNode> createA11yNodes() {
    final nodes = <_DomainA11yNode>[];

    // Update the selection model when the a11y node has focus.
    final selectionModel = _chart.getSelectionModel(SelectionModelType.info);

    final domainSeriesDatum = <D, List<SeriesDatum<D>>>{};

    for (final series in _seriesList) {
      for (var index = 0; index < series.data.length; index++) {
        final Object? datum = series.data[index];
        final domain = series.domainFn(index);

        domainSeriesDatum[domain] ??= <SeriesDatum<D>>[];
        domainSeriesDatum[domain]!
            .add(SeriesDatum<D>(series: series, datum: datum));
      }
    }

    domainSeriesDatum.forEach((D domain, List<SeriesDatum<D>> seriesDatums) {
      final a11yDescription = _vocalizationCallback(seriesDatums);

      final firstSeries = seriesDatums.first.series;
      final domainAxis =
          firstSeries.getAttr(domainAxisKey)! as ImmutableAxisElement<D>;
      final location = domainAxis.getLocation(domain)!;

      /// If the step size is smaller than the minimum width, use minimum.
      final stepSize = (domainAxis.stepSize > minimumWidth)
          ? domainAxis.stepSize
          : minimumWidth;

      nodes.add(
        _DomainA11yNode(
          a11yDescription,
          location: location,
          stepSize: stepSize,
          chartDrawBounds: _chart.drawAreaBounds,
          isRtl: _chart.context.isRtl,
          renderVertically: _chart.vertical,
          onFocus: () => selectionModel.updateSelection(seriesDatums, []),
        ),
      );
    });

    // The screen reader navigates the nodes based on the order it is returned.
    // So if the chart is RTL, then the nodes should be ordered with the right
    // most domain first.
    //
    // If the chart has multiple series and one series is missing the domain
    // and it was added later, we still want the domains to be in order.
    nodes.sort();

    return nodes;
  }

  void _updateSeriesList(List<MutableSeries<D>> seriesList) {
    _seriesList = seriesList;
  }

  @override
  void attachTo(BaseRenderChart<D> chart) {
    // Domain selection behavior only works for cartesian charts.
    assert(chart is CartesianRenderChart<D>);
    _chart = chart as CartesianRenderChart<D>;

    chart.addLifecycleListener(_lifecycleListener);

    super.attachTo(chart);
  }

  @override
  void removeFrom(BaseRenderChart<D> chart) {
    chart.removeLifecycleListener(_lifecycleListener);
  }

  @override
  String get role => 'DomainA11yExplore-$exploreModeTrigger';
}

/// A11yNode with domain specific information.
class _DomainA11yNode extends A11yNode implements Comparable<_DomainA11yNode> {
  factory _DomainA11yNode(
    String label, {
    required double location,
    required double stepSize,
    required Rect chartDrawBounds,
    required bool isRtl,
    required bool renderVertically,
    OnFocus? onFocus,
  }) {
    Rect boundingBox;
    if (renderVertically) {
      final left = location - stepSize / 2;
      final top = chartDrawBounds.top;
      final width = stepSize;
      final height = chartDrawBounds.height;
      boundingBox = Rect.fromLTWH(left, top, width, height);
    } else {
      final left = chartDrawBounds.left;
      final top = location - stepSize / 2;
      final width = chartDrawBounds.width;
      final height = stepSize;
      boundingBox = Rect.fromLTWH(left, top, width, height);
    }

    return _DomainA11yNode._internal(
      label,
      boundingBox,
      location: location,
      isRtl: isRtl,
      renderVertically: renderVertically,
      onFocus: onFocus,
    );
  }

  _DomainA11yNode._internal(
    super.label,
    super.boundingBox, {
    required this.location,
    required this.isRtl,
    required this.renderVertically,
    super.onFocus,
  });
  // Save location, RTL, and is render vertically for sorting
  final double location;
  final bool isRtl;
  final bool renderVertically;

  @override
  int compareTo(_DomainA11yNode other) {
    // Ordered by smaller location first, unless rendering vertically and RTL,
    // then flip to sort by larger location first.
    var result = location.compareTo(other.location);

    if (renderVertically && isRtl && result != 0) {
      result = -result;
    }

    return result;
  }
}
