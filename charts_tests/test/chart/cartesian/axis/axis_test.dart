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

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:charts/charts.dart';

class MockTickDrawStrategy extends Mock implements TickDrawStrategy<num> {}

class MockGraphicsFactory extends Mock implements GraphicsFactory {
  @override
  TextElement createTextElement(String _) {
    return MockTextElement();
  }
}

class MockTextElement extends Mock implements TextElement {}

StaticTickProviderElement<num> _createProvider(List<num> values) =>
    StaticTickProviderElement<num>(values.map((v) => Tick(v)).toList());

void main() {
  test('changing first tick only', () {
    var axis = NumericAxisElement(
      tickProvider: _createProvider([1, 10]),
    );

    var drawStrategy = MockTickDrawStrategy();
    when(drawStrategy.collides(any, any)).thenReturn(CollisionReport<num>(
        ticks: [], ticksCollide: false, alternateTicksUsed: false));

    var tester = AxisTester(axis);
    axis.tickDrawStrategy = drawStrategy;
    axis.graphicsFactory = MockGraphicsFactory();
    tester.scale.range = ScaleOutputExtent(0, 300);

    axis.updateTicks();

    axis.tickProvider = _createProvider([5, 10]);
    axis.updateTicks();

    // The old value should still be there as it gets animated out, but the
    // values should be sorted by their position.
    expect(tester.axisValues, equals([1, 5, 10]));
  });

  test('updates max label width on layout change', () {
    var axis = NumericAxisElement(
      tickProvider: _createProvider([1, 10]),
    );

    var drawStrategy = MockTickDrawStrategy();
    when(drawStrategy.collides(any, any)).thenReturn(CollisionReport<num>(
        ticks: [], ticksCollide: false, alternateTicksUsed: false));

    axis.tickDrawStrategy = drawStrategy;
    axis.graphicsFactory = MockGraphicsFactory();
    var axisOrientation = AxisOrientation.left;
    axis.axisOrientation = axisOrientation;

    var maxWidth = 100;
    var maxHeight = 500;
    var componentBounds = Rectangle<int>(0, 0, maxWidth, maxHeight);
    var drawBounds = Rectangle<int>(0, 0, maxWidth, maxHeight);
    axis.layout(componentBounds, drawBounds);

    verify(drawStrategy.updateTickWidth(
            any, maxWidth, maxHeight, axisOrientation,
            collision: false))
        .called(1);
  });
}
