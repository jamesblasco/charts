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

import 'package:charts/charts/bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selection can be set programmatically',
      (WidgetTester tester) async {
    final onTapSelection = UserManagedSelectionModel<String>.fromConfig(
        selectedDataConfig: [const SeriesDatumConfig<String>('Sales', '2016')],);

    SelectionModel<String>? currentSelectionModel;

    void selectionChangedListener(SelectionModel<String> model) {
      currentSelectionModel = model;
    }

    final testChart = TestChart(selectionChangedListener, onTapSelection);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: testChart,
      ),
    );

    expect(currentSelectionModel, isNull);

    await tester.tap(find.byType(BarChart));

    await tester.pump();

    expect(currentSelectionModel, isNotNull);
    expect(currentSelectionModel!.selectedDatum, hasLength(1));
    final selectedDatum =
        currentSelectionModel!.selectedDatum.first.datum as OrdinalSales;
    expect(selectedDatum.year, equals('2016'));
    expect(selectedDatum.sales, equals(100));
    expect(currentSelectionModel!.selectedSeries, hasLength(1));
    expect(currentSelectionModel!.selectedSeries.first.id, equals('Sales'));
  });
}

class TestChart extends StatefulWidget {

  const TestChart(this.selectionChangedListener, this.onTapSelection);
  final SelectionModelListener<String> selectionChangedListener;
  final UserManagedSelectionModel<String> onTapSelection;

  @override
  TestChartState createState() {
    return TestChartState(selectionChangedListener, onTapSelection);
  }
}

class TestChartState extends State<TestChart> {

  TestChartState(this.selectionChangedListener, this.onTapSelection);
  final SelectionModelListener<String> selectionChangedListener;
  final UserManagedSelectionModel<String> onTapSelection;

  final seriesList = _createSampleData();
  final myState = UserManagedState<String>();

  @override
  Widget build(BuildContext context) {
    final chart = BarChart(
      seriesList,
      userManagedState: myState,
      selectionModels: [
        SelectionModelConfig(
            changedListener: widget.selectionChangedListener,)
      ],
      // Disable animation and gesture for testing.
      animate: false, //widget.animate,
      defaultInteractions: false,
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(onTap: handleOnTap, child: chart),
    );
  }

  void handleOnTap() {
    setState(() {
      myState.selectionModels[SelectionModelType.info] = onTapSelection;
    });
  }
}

/// Create one series with sample hard coded data.
List<Series<OrdinalSales, String>> _createSampleData() {
  final data = [
    OrdinalSales('2014', 5),
    OrdinalSales('2015', 25),
    OrdinalSales('2016', 100),
    OrdinalSales('2017', 75),
  ];

  return [
    Series<OrdinalSales, String>(
      id: 'Sales',
      colorFn: (_, __) => Colors.blue,
      domainFn: (OrdinalSales sales, _) => sales.year,
      measureFn: (OrdinalSales sales, _) => sales.sales,
      data: data,
    )
  ];
}

/// Sample ordinal data type.
class OrdinalSales {

  OrdinalSales(this.year, this.sales);
  final String year;
  final int sales;
}
