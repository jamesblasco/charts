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

/// Example of a line chart with null measure values.
///
/// Null values will be visible as gaps in lines and area skirts. Any data
/// points that exist between two nulls in a line will be rendered as an
/// isolated point, as seen in the green series.
// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:charts/charts.dart';
import 'package:flutter/material.dart';

class SimpleNullsLineChart extends StatelessWidget {
  final List<Series<dynamic, num>> seriesList;
  final bool animate;

  SimpleNullsLineChart(this.seriesList, {this.animate = false});

  /// Creates a [LineChart] with sample data and no transition.
  factory SimpleNullsLineChart.withSampleData() {
    return SimpleNullsLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory SimpleNullsLineChart.withRandomData() {
    return SimpleNullsLineChart(_createRandomData());
  }

  /// Create random data.
  static List<Series<LinearSales, num>> _createRandomData() {
    final random = Random();

    final myFakeDesktopData = [
      LinearSales(0, random.nextInt(100)),
      LinearSales(1, random.nextInt(100)),
      LinearSales(2, null),
      LinearSales(3, random.nextInt(100)),
      LinearSales(4, random.nextInt(100)),
      LinearSales(5, random.nextInt(100)),
      LinearSales(6, random.nextInt(100)),
    ];

    var myFakeTabletData = [
      LinearSales(0, random.nextInt(100)),
      LinearSales(1, random.nextInt(100)),
      LinearSales(2, random.nextInt(100)),
      LinearSales(3, random.nextInt(100)),
      LinearSales(4, random.nextInt(100)),
      LinearSales(5, random.nextInt(100)),
      LinearSales(6, random.nextInt(100)),
    ];

    var myFakeMobileData = [
      LinearSales(0, random.nextInt(100)),
      LinearSales(1, random.nextInt(100)),
      LinearSales(2, null),
      LinearSales(3, random.nextInt(100)),
      LinearSales(4, null),
      LinearSales(5, random.nextInt(100)),
      LinearSales(6, random.nextInt(100)),
    ];

    return [
      Series<LinearSales, int>(
        id: 'Desktop',
        colorFn: (_, __) => Colors.blue,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: myFakeDesktopData,
      ),
      Series<LinearSales, int>(
        id: 'Tablet',
        colorFn: (_, __) => Colors.red,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: myFakeTabletData,
      ),
      Series<LinearSales, int>(
        id: 'Mobile',
        colorFn: (_, __) => Colors.green,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: myFakeMobileData,
      ),
    ];
  }
  // EXCLUDE_FROM_GALLERY_DOCS_END

  @override
  Widget build(BuildContext context) {
    return LineChart(seriesList, animate: animate);
  }

  /// Create one series with sample hard coded data.
  static List<Series<LinearSales, int>> _createSampleData() {
    final myFakeDesktopData = [
      LinearSales(0, 5),
      LinearSales(1, 15),
      LinearSales(2, null),
      LinearSales(3, 75),
      LinearSales(4, 100),
      LinearSales(5, 90),
      LinearSales(6, 75),
    ];

    final myFakeTabletData = [
      LinearSales(0, 10),
      LinearSales(1, 30),
      LinearSales(2, 50),
      LinearSales(3, 150),
      LinearSales(4, 200),
      LinearSales(5, 180),
      LinearSales(6, 150),
    ];

    final myFakeMobileData = [
      LinearSales(0, 15),
      LinearSales(1, 45),
      LinearSales(2, null),
      LinearSales(3, 225),
      LinearSales(4, null),
      LinearSales(5, 270),
      LinearSales(6, 225),
    ];

    return [
      Series<LinearSales, int>(
        id: 'Desktop',
        colorFn: (_, __) => Colors.blue,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: myFakeDesktopData,
      ),
      Series<LinearSales, int>(
        id: 'Tablet',
        colorFn: (_, __) => Colors.red,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: myFakeTabletData,
      ),
      Series<LinearSales, int>(
        id: 'Mobile',
        colorFn: (_, __) => Colors.green,
        domainFn: (LinearSales sales, _) => sales.year,
        measureFn: (LinearSales sales, _) => sales.sales,
        data: myFakeMobileData,
      ),
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final int? sales;

  LinearSales(this.year, this.sales);
}
