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

/// Example of using user managed state to programmatically set selection.
///
/// In this example, clicking the "clear selection" button sets the selection
/// to an empty selection. This example also shows that initial selection
/// behavior can still be used with user managed state.
///
/// Note that the picture in this example is not interactive, please run the
/// gallery app to try out using the button to clear selection.
///
// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:charts/charts.dart';
import 'package:flutter/material.dart';

class SelectionUserManaged extends StatefulWidget {
  final List<Series<dynamic, String>> seriesList;
  final bool animate;

  SelectionUserManaged(this.seriesList, {this.animate = false});

  /// Creates a [BarChart] with sample data and no transition.
  factory SelectionUserManaged.withSampleData() {
    return SelectionUserManaged(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory SelectionUserManaged.withRandomData() {
    return SelectionUserManaged(_createRandomData());
  }

  /// Create random data.
  static List<Series<OrdinalSales, String>> _createRandomData() {
    final random = Random();

    final data = [
      OrdinalSales('2014', random.nextInt(100)),
      OrdinalSales('2015', random.nextInt(100)),
      OrdinalSales('2016', random.nextInt(100)),
      OrdinalSales('2017', random.nextInt(100)),
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
  // EXCLUDE_FROM_GALLERY_DOCS_END

  /// Create one series with sample hard coded data.
  static List<Series<OrdinalSales, String>> _createSampleData() {
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

  @override
  SelectionUserManagedState createState() {
    return SelectionUserManagedState();
  }
}

class SelectionUserManagedState extends State<SelectionUserManaged> {
  final _myState = UserManagedState<String>();

  @override
  Widget build(BuildContext context) {
    final chart = BarChart(
      widget.seriesList,
      animate: false, //widget.animate,
      selectionModels: [
        SelectionModelConfig(
            type: SelectionModelType.info,
            updatedListener: _infoSelectionModelUpdated)
      ],
      // Pass in the state you manage to the chart. This will be used to
      // override the internal chart state.
      userManagedState: _myState,
      // The initial selection can still be optionally added by adding the
      // initial selection behavior.
      behaviors: [
        InitialSelection(
            selectedDataConfig: [SeriesDatumConfig<String>('Sales', '2016')])
      ],
    );

    final clearSelection = MaterialButton(
        onPressed: _handleClearSelection, child: Text('Clear Selection'));

    return Column(
        children: [SizedBox(height: 150.0, child: chart), clearSelection]);
  }

  void _infoSelectionModelUpdated(SelectionModel<String> model) {
    // If you want to allow the chart to continue to respond to select events
    // that update the selection, add an updatedListener that saves off the
    // selection model each time the selection model is updated, regardless of
    // if there are changes.
    //
    // This also allows you to listen to the selection model update events and
    // alter the selection.
    _myState.selectionModels[SelectionModelType.info] =
        UserManagedSelectionModel(model: model);
  }

  void _handleClearSelection() {
    // Call set state to request a rebuild, to pass in the modified selection.
    // In this case, passing in an empty [UserManagedSelectionModel] creates a
    // no selection model to clear all selection when rebuilt.
    setState(() {
      _myState.selectionModels[SelectionModelType.info] =
          UserManagedSelectionModel();
    });
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
