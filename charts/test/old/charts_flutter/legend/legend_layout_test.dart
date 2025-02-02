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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Can't use Mockito annotations with BuildContext yet? Fake it.
class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late BuildContext context;

  setUp(() {
    context = FakeBuildContext();
  });

  group('TabularLegendLayoutBuilder', () {
    test('builds horizontally', () {
      final builder = TabularLegendLayout.horizontalFirst();
      final widgets = <Widget>[
        const Text('1'),
        const Text('2'),
        const Text('3')
      ];

      final layout = builder.build(context, widgets) as Table;
      expect(layout.children.length, 1);
      expect(layout.children.first.children!.length, 3);
    });

    test('does not build extra columns if max columns exceed widget count', () {
      final builder =
          TabularLegendLayout.horizontalFirst(desiredMaxColumns: 10);
      final widgets = <Widget>[
        const Text('1'),
        const Text('2'),
        const Text('3')
      ];

      final layout = builder.build(context, widgets) as Table;
      expect(layout.children.length, 1);
      expect(layout.children.first.children!.length, 3);
    });

    test('builds horizontally until max column exceeded', () {
      final builder = TabularLegendLayout.horizontalFirst(desiredMaxColumns: 2);

      final widgets =
          List<Widget>.generate(7, (int index) => Text(index.toString()));

      final layout = builder.build(context, widgets) as Table;
      expect(layout.children.length, 4);

      expect(layout.children[0].children![0], equals(widgets[0]));
      expect(layout.children[0].children![1], equals(widgets[1]));

      expect(layout.children[1].children![0], equals(widgets[2]));
      expect(layout.children[1].children![1], equals(widgets[3]));

      expect(layout.children[2].children![0], equals(widgets[4]));
      expect(layout.children[2].children![1], equals(widgets[5]));

      expect(layout.children[3].children![0], equals(widgets[6]));
    });

    test('builds vertically', () {
      final builder = TabularLegendLayout.verticalFirst();
      final widgets = <Widget>[
        const Text('1'),
        const Text('2'),
        const Text('3')
      ];

      final layout = builder.build(context, widgets) as Table;
      expect(layout.children.length, 3);
      expect(layout.children[0].children!.length, 1);
      expect(layout.children[1].children!.length, 1);
      expect(layout.children[2].children!.length, 1);
    });

    test('does not build extra rows if max rows exceed widget count', () {
      final builder = TabularLegendLayout.verticalFirst(desiredMaxRows: 10);
      final widgets = <Widget>[
        const Text('1'),
        const Text('2'),
        const Text('3')
      ];

      final layout = builder.build(context, widgets) as Table;
      expect(layout.children.length, 3);
      expect(layout.children[0].children!.length, 1);
      expect(layout.children[1].children!.length, 1);
      expect(layout.children[2].children!.length, 1);
    });

    test('builds vertically until max column exceeded', () {
      final builder = TabularLegendLayout.verticalFirst(desiredMaxRows: 2);

      final widgets =
          List<Widget>.generate(7, (int index) => Text(index.toString()));

      final layout = builder.build(context, widgets) as Table;
      expect(layout.children.length, 2);

      expect(layout.children[0].children![0], equals(widgets[0]));
      expect(layout.children[1].children![0], equals(widgets[1]));

      expect(layout.children[0].children![1], equals(widgets[2]));
      expect(layout.children[1].children![1], equals(widgets[3]));

      expect(layout.children[0].children![2], equals(widgets[4]));
      expect(layout.children[1].children![2], equals(widgets[5]));

      expect(layout.children[0].children![3], equals(widgets[6]));
    });
  });
}
