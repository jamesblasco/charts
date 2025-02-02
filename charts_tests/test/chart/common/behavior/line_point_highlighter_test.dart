// @dart=2.9

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


import 'package:charts/charts.dart';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockChart extends Mock implements CartesianRenderChart {
  LifecycleListener lastListener;

  @override
  LifecycleListener addLifecycleListener(LifecycleListener listener) =>
      lastListener = listener;

  @override
  bool removeLifecycleListener(LifecycleListener listener) {
    expect(listener, equals(lastListener));
    lastListener = null;
    return true;
  }

  @override
  bool get vertical => true;
}

class MockSelectionModel extends Mock implements MutableSelectionModel {
  SelectionModelListener lastListener;

  @override
  void addSelectionChangedListener(SelectionModelListener listener) =>
      lastListener = listener;

  @override
  void removeSelectionChangedListener(SelectionModelListener listener) {
    expect(listener, equals(lastListener));
    lastListener = null;
  }
}

class MockNumericAxis extends Mock implements NumericAxisElement {
  @override
  double getLocation(num domain) {
    return 10.0;
  }
}

class MockSeriesRenderer<D> extends BaseSeriesRenderer<D> {
  MockSeriesRenderer() : super(rendererId: 'fake', layoutPaintOrder: 0);

  @override
  void update(_, __) {}

  @override
  void paint(_, __) {}

  @override
  List<DatumDetails<D>> getNearestDatumDetailPerSeries(
    Offset chartPoint,
    bool byDomain,
    Rect boundsOverride, {
    selectOverlappingPoints = false,
    selectExactEventLocation = false,
  }) =>
      null;

  @override
  DatumDetails<D> addPositionToDetailsForSeriesDatum(
      DatumDetails<D> details, SeriesDatum<D> seriesDatum) {
    return DatumDetails.from(details, chartPosition: NullableOffset(0.0, 0.0));
  }
}

void main() {
  MockChart _chart;
  MockSelectionModel _selectionModel;
  MockSeriesRenderer _seriesRenderer;

  MutableSeries<int> _series1;
  final _s1D1 = MyRow(1, 11);
  final _s1D2 = MyRow(2, 12);
  final _s1D3 = MyRow(3, 13);

  MutableSeries<int> _series2;
  final _s2D1 = MyRow(4, 21);
  final _s2D2 = MyRow(5, 22);
  final _s2D3 = MyRow(6, 23);

  List<DatumDetails> _mockGetSelectedDatumDetails(List<SeriesDatum> selection) {
    final details = <DatumDetails>[];

    for (SeriesDatum seriesDatum in selection) {
      details.add(_seriesRenderer.getDetailsForSeriesDatum(seriesDatum));
    }

    return details;
  }

  void _setupSelection(List<SeriesDatum> selection) {
    final selected = <MyRow>[];

    for (var i = 0; i < selection.length; i++) {
      selected.add(selection[0].datum as MyRow);
    }

    for (int i = 0; i < _series1.data.length; i++) {
      when(_selectionModel.isDatumSelected(_series1, i))
          .thenReturn(selected.contains(_series1.data[i]));
    }
    for (int i = 0; i < _series2.data.length; i++) {
      when(_selectionModel.isDatumSelected(_series2, i))
          .thenReturn(selected.contains(_series2.data[i]));
    }

    when(_selectionModel.selectedDatum).thenReturn(selection);

    final selectedDetails = _mockGetSelectedDatumDetails(selection);

    when(_chart.getSelectedDatumDetails(SelectionModelType.info))
        .thenReturn(selectedDetails);
  }

  setUp(() {
    _chart = MockChart();

    _seriesRenderer = MockSeriesRenderer();

    _selectionModel = MockSelectionModel();
    when(_chart.getSelectionModel(SelectionModelType.info))
        .thenReturn(_selectionModel);

    _series1 = MutableSeries(Series<MyRow, int>(
        id: 's1',
        data: [_s1D1, _s1D2, _s1D3],
        domainFn: (MyRow row, _) => row.campaign,
        measureFn: (MyRow row, _) => row.count,
        colorFn: (_, __) => Colors.blue))
      ..measureFn = (_) => 0.0;

    _series2 = MutableSeries(Series<MyRow, int>(
        id: 's2',
        data: [_s2D1, _s2D2, _s2D3],
        domainFn: (MyRow row, _) => row.campaign,
        measureFn: (MyRow row, _) => row.count,
        colorFn: (_, __) => Colors.red))
      ..measureFn = (_) => 0.0;
  });

  group('LinePointHighlighter', () {
    test('highlights the selected points', () {
      // Setup
      final behavior = LinePointHighlighterState(
          selectionModelType: SelectionModelType.info);
      final tester = LinePointHighlighterTester(behavior);
      behavior.attachTo(_chart);
      _setupSelection([
        SeriesDatum(series: _series1, datum: _s1D2),
        SeriesDatum(series: _series2, datum: _s2D2),
      ]);

      // Mock axes for returning fake domain locations.
      MutableAxisElement domainAxis = MockNumericAxis();
      MutableAxisElement primaryMeasureAxis = MockNumericAxis();

      _series1.setAttr(domainAxisKey, domainAxis);
      _series1.setAttr(measureAxisKey, primaryMeasureAxis);
      _series1.measureOffsetFn = (_) => 0.0;

      _series2.setAttr(domainAxisKey, domainAxis);
      _series2.setAttr(measureAxisKey, primaryMeasureAxis);
      _series2.measureOffsetFn = (_) => 0.0;

      // Act
      _selectionModel.lastListener(_selectionModel);
      verify(_chart.redraw(skipAnimation: true, skipLayout: true));

      _chart.lastListener.onAxisConfigured();

      // Verify
      expect(tester.getSelectionLength(), equals(2));

      expect(tester.isDatumSelected(_series1.data[0]), equals(false));
      expect(tester.isDatumSelected(_series1.data[1]), equals(true));
      expect(tester.isDatumSelected(_series1.data[2]), equals(false));

      expect(tester.isDatumSelected(_series2.data[0]), equals(false));
      expect(tester.isDatumSelected(_series2.data[1]), equals(true));
      expect(tester.isDatumSelected(_series2.data[2]), equals(false));
    });

    test('listens to other selection models', () {
      // Setup
      final behavior = LinePointHighlighterState(
          selectionModelType: SelectionModelType.action);
      when(_chart.getSelectionModel(SelectionModelType.action))
          .thenReturn(_selectionModel);

      // Act
      behavior.attachTo(_chart);

      // Verify
      verify(_chart.getSelectionModel(SelectionModelType.action));
      verifyNever(_chart.getSelectionModel(SelectionModelType.info));
    });

    test('leaves everything alone with no selection', () {
      // Setup
      final behavior = LinePointHighlighterState(
          selectionModelType: SelectionModelType.info);
      final tester = LinePointHighlighterTester(behavior);
      behavior.attachTo(_chart);
      _setupSelection([]);

      // Act
      _selectionModel.lastListener(_selectionModel);
      verify(_chart.redraw(skipAnimation: true, skipLayout: true));
      _chart.lastListener.onAxisConfigured();

      // Verify
      expect(tester.getSelectionLength(), equals(0));

      expect(tester.isDatumSelected(_series1.data[0]), equals(false));
      expect(tester.isDatumSelected(_series1.data[1]), equals(false));
      expect(tester.isDatumSelected(_series1.data[2]), equals(false));

      expect(tester.isDatumSelected(_series2.data[0]), equals(false));
      expect(tester.isDatumSelected(_series2.data[1]), equals(false));
      expect(tester.isDatumSelected(_series2.data[2]), equals(false));
    });

    test('cleans up', () {
      // Setup
      final behavior = LinePointHighlighterState(
          selectionModelType: SelectionModelType.info);
      behavior.attachTo(_chart);
      _setupSelection([
        SeriesDatum(series: _series1, datum: _s1D2),
        SeriesDatum(series: _series2, datum: _s2D2),
      ]);

      // Act
      behavior.removeFrom(_chart);

      // Verify
      expect(_chart.lastListener, isNull);
      expect(_selectionModel.lastListener, isNull);
    });
  });
}

class MyRow {
  final int campaign;
  final int count;
  MyRow(this.campaign, this.count);
}
