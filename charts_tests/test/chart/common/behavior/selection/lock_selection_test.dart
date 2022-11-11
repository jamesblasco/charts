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

import 'dart:math';
import 'package:charts/charts.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockChart extends Mock implements BaseRenderChart {
  GestureListener lastListener;

  @override
  GestureListener addGestureListener(GestureListener listener) {
    lastListener = listener;
    return listener;
  }

  @override
  void removeGestureListener(GestureListener listener) {
    expect(listener, equals(lastListener));
    lastListener = null;
  }
}

class MockSelectionModel extends Mock implements MutableSelectionModel {
  @override
  bool locked = false;
}

void main() {
  MockChart _chart;
  MockSelectionModel _hoverSelectionModel;
  MockSelectionModel _clickSelectionModel;

  LockSelectionState _makeLockSelectionBehavior(
      SelectionModelType selectionModelType) {
    LockSelectionState behavior =
        LockSelectionState(selectionModelType: selectionModelType);

    behavior.attachTo(_chart);

    return behavior;
  }

  void _setupChart({Offset forPoint, bool isWithinRenderer}) {
    if (isWithinRenderer != null) {
      when(_chart.pointWithinRenderer(forPoint)).thenReturn(isWithinRenderer);
    }
  }

  setUp(() {
    _hoverSelectionModel = MockSelectionModel();
    _clickSelectionModel = MockSelectionModel();

    _chart = MockChart();
    when(_chart.getSelectionModel(SelectionModelType.info))
        .thenReturn(_hoverSelectionModel);
    when(_chart.getSelectionModel(SelectionModelType.action))
        .thenReturn(_clickSelectionModel);
  });

  group('LockSelectionState trigger handling', () {
    test('can lock model with a selection', () {
      // Setup chart matches point with single domain single series.
      _makeLockSelectionBehavior(SelectionModelType.info);
      Offset point = Offset(100.0, 100.0);
      _setupChart(forPoint: point, isWithinRenderer: true);

      when(_hoverSelectionModel.hasAnySelection).thenReturn(true);

      // Act
      _chart.lastListener.onTapTest(point);
      _chart.lastListener.onTap(point);

      // Validate
      verify(_hoverSelectionModel.hasAnySelection);
      expect(_hoverSelectionModel.locked, equals(true));
      verifyNoMoreInteractions(_hoverSelectionModel);
      verifyNoMoreInteractions(_clickSelectionModel);
    });

    test('can lock and unlock model', () {
      // Setup chart matches point with single domain single series.
      _makeLockSelectionBehavior(SelectionModelType.info);
      Offset point = Offset(100.0, 100.0);
      _setupChart(forPoint: point, isWithinRenderer: true);

      when(_hoverSelectionModel.hasAnySelection).thenReturn(true);

      // Act
      _chart.lastListener.onTapTest(point);
      _chart.lastListener.onTap(point);

      // Validate
      verify(_hoverSelectionModel.hasAnySelection);
      expect(_hoverSelectionModel.locked, equals(true));

      // Act
      _chart.lastListener.onTapTest(point);
      _chart.lastListener.onTap(point);

      // Validate
      verify(_hoverSelectionModel.clearSelection());
      expect(_hoverSelectionModel.locked, equals(false));
      verifyNoMoreInteractions(_hoverSelectionModel);
      verifyNoMoreInteractions(_clickSelectionModel);
    });

    test('does not lock model with empty selection', () {
      // Setup chart matches point with single domain single series.
      _makeLockSelectionBehavior(SelectionModelType.info);
      Offset point = Offset(100.0, 100.0);
      _setupChart(forPoint: point, isWithinRenderer: true);

      when(_hoverSelectionModel.hasAnySelection).thenReturn(false);

      // Act
      _chart.lastListener.onTapTest(point);
      _chart.lastListener.onTap(point);

      // Validate
      verify(_hoverSelectionModel.hasAnySelection);
      expect(_hoverSelectionModel.locked, equals(false));
      verifyNoMoreInteractions(_hoverSelectionModel);
      verifyNoMoreInteractions(_clickSelectionModel);
    });
  });

  group('Cleanup', () {
    test('detach removes listener', () {
      // Setup
      final behavior = _makeLockSelectionBehavior(SelectionModelType.info);
      Offset point = Offset(100.0, 100.0);
      _setupChart(forPoint: point, isWithinRenderer: true);
      expect(_chart.lastListener, isNotNull);

      // Act
      behavior.removeFrom(_chart);

      // Validate
      expect(_chart.lastListener, isNull);
    });
  });
}
