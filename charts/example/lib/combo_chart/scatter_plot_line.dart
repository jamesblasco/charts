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

/// Example of a combo scatter plot chart with a second series rendered as a
/// line.
// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:charts/charts.dart';
import 'package:flutter/material.dart';

class ScatterPlotComboLineChart extends StatelessWidget {
  final List<Series<dynamic, num>> seriesList;
  final bool animate;

  ScatterPlotComboLineChart(this.seriesList, {this.animate = false});

  /// Creates a [ScatterPlotChart] with sample data and no transition.
  factory ScatterPlotComboLineChart.withSampleData() {
    return ScatterPlotComboLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory ScatterPlotComboLineChart.withRandomData() {
    return ScatterPlotComboLineChart(_createRandomData());
  }

  /// Create random data.
  static List<Series<LinearSales, num>> _createRandomData() {
    final random = Random();

    final makeRadius = (int value) => (random.nextInt(value) + 2).toDouble();

    final desktopSalesData = [
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
      LinearSales(random.nextInt(100), random.nextInt(100), makeRadius(6)),
    ];

    var myRegressionData = [
      LinearSales(0, desktopSalesData[0].sales, 3.5),
      LinearSales(
          100, desktopSalesData[desktopSalesData.length - 1].sales, 7.5),
    ];

    final maxMeasure = 100;

    return [
      Series<LinearSales, int>(
        id: 'Sales',
        // Providing a color function is optional.
        colorFn: (LinearSales sales, _) {
          // Bucket the measure column value into 3 distinct colors.
          final bucket = sales.sales / maxMeasure;

          if (bucket < 1 / 3) {
            return Colors.blue;
          } else if (bucket < 2 / 3) {
            return Colors.red;
          } else {
            return Colors.green;
          }
        },
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        // Providing a radius function is optional.
        radiusFn: (LinearSales sales, _) => sales.radius,
        data: desktopSalesData,
      ),
      Series<LinearSales, int>(
          id: 'Mobile',
          colorFn: (_, __) => Colors.purple,
          domainFn: (LinearSales sales, _) => sales.year,
          measureFn: (LinearSales sales, _) => sales.sales,
          data: myRegressionData)
        // Configure our custom line renderer for this series.
        ..setAttribute(rendererIdKey, 'customLine'),
    ];
  }
  // EXCLUDE_FROM_GALLERY_DOCS_END

  @override
  Widget build(BuildContext context) {
    return ScatterPlotChart(seriesList,
        animate: animate,
        // Configure the default renderer as a point renderer. This will be used
        // for any series that does not define a rendererIdKey.
        //
        // This is the default configuration, but is shown here for
        // illustration.
        defaultRenderer: PointRendererConfig(),
        // Custom renderer configuration for the line series.
        customSeriesRenderers: [
          LineRendererConfig(
              // ID used to link series to this renderer.
              customRendererId: 'customLine',
              // Configure the regression line to be painted above the points.
              //
              // By default, series drawn by the point renderer are painted on
              // top of those drawn by a line renderer.
              layoutPaintOrder: LayoutViewPaintOrder.point + 1)
        ]);
  }

  /// Create one series with sample hard coded data.
  static List<Series<LinearSales, int>> _createSampleData() {
    final desktopSalesData = [
      LinearSales(0, 5, 3.0),
      LinearSales(10, 25, 5.0),
      LinearSales(12, 75, 4.0),
      LinearSales(13, 225, 5.0),
      LinearSales(16, 50, 4.0),
      LinearSales(24, 75, 3.0),
      LinearSales(25, 100, 3.0),
      LinearSales(34, 150, 5.0),
      LinearSales(37, 10, 4.5),
      LinearSales(45, 300, 8.0),
      LinearSales(52, 15, 4.0),
      LinearSales(56, 200, 7.0),
    ];

    var myRegressionData = [
      LinearSales(0, 5, 3.5),
      LinearSales(56, 240, 3.5),
    ];

    final maxMeasure = 300;

    return [
      Series<LinearSales, int>(
        id: 'Sales',
        // Providing a color function is optional.
        colorFn: (LinearSales sales, _) {
          // Bucket the measure column value into 3 distinct colors.
          final bucket = sales.sales / maxMeasure;

          if (bucket < 1 / 3) {
            return Colors.blue;
          } else if (bucket < 2 / 3) {
            return Colors.red;
          } else {
            return Colors.green;
          }
        },
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        // Providing a radius function is optional.
        radiusFn: (LinearSales sales, _) => sales.radius,
        data: desktopSalesData,
      ),
      Series<LinearSales, int>(
          id: 'Mobile',
          colorFn: (_, __) => Colors.purple,
          domainFn: (LinearSales sales, _) => sales.year,
          measureFn: (LinearSales sales, _) => sales.sales,
          data: myRegressionData)
        // Configure our custom line renderer for this series.
        ..setAttribute(rendererIdKey, 'customLine'),
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int sales;
  final double radius;

  LinearSales(this.year, this.sales, this.radius);
}
