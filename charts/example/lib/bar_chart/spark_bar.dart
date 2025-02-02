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

/// Spark Bar Example
// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';
// EXCLUDE_FROM_GALLERY_DOCS_END

import 'package:flutter/material.dart';
import 'package:charts/charts.dart';

/// Example of a Spark Bar by hiding both axis, reducing the chart margins.
class SparkBar extends StatelessWidget {
  final List<Series<dynamic, String>> seriesList;
  final bool animate;

  SparkBar(this.seriesList, {this.animate = false});

  factory SparkBar.withSampleData() {
    return SparkBar(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory SparkBar.withRandomData() {
    return SparkBar(_createRandomData());
  }

  /// Create random data.
  static List<Series<OrdinalSales, String>> _createRandomData() {
    final random = Random();

    final globalSalesData = [
      OrdinalSales('2007', random.nextInt(100)),
      OrdinalSales('2008', random.nextInt(100)),
      OrdinalSales('2009', random.nextInt(100)),
      OrdinalSales('2010', random.nextInt(100)),
      OrdinalSales('2011', random.nextInt(100)),
      OrdinalSales('2012', random.nextInt(100)),
      OrdinalSales('2013', random.nextInt(100)),
      OrdinalSales('2014', random.nextInt(100)),
      OrdinalSales('2015', random.nextInt(100)),
      OrdinalSales('2016', random.nextInt(100)),
      OrdinalSales('2017', random.nextInt(100)),
    ];

    return [
      Series<OrdinalSales, String>(
        id: 'Global Revenue',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: globalSalesData,
      ),
    ];
  }
  // EXCLUDE_FROM_GALLERY_DOCS_END

  @override
  Widget build(BuildContext context) {
    return BarChart(seriesList,
        animate: animate,

        /// Assign a custom style for the measure axis.
        ///
        /// The NoneRenderSpec only draws an axis line (and even that can be hidden
        /// with showAxisLine=false).
        primaryMeasureAxis: NumericAxis(decoration: NoneAxisDecoration()),

        /// This is an OrdinalAxisSpec to match up with BarChart's default
        /// ordinal domain axis (use NumericAxisSpec or DateTimeAxisSpec for
        /// other .
        domainAxis: OrdinalAxis(
            // Make sure that we draw the domain axis line.
            showAxisLine: true,
            // But don't draw anything else.
            decoration: NoneAxisDecoration()),

        // With a spark chart we likely don't want large chart margins.
        // 1px is the smallest we can make each margin.
        layoutConfig: LayoutConfig(
          margin: LayoutMargin.zero,
        ));
  }

  /// Create series list with single series
  static List<Series<OrdinalSales, String>> _createSampleData() {
    final globalSalesData = [
      OrdinalSales('2007', 3100),
      OrdinalSales('2008', 3500),
      OrdinalSales('2009', 5000),
      OrdinalSales('2010', 2500),
      OrdinalSales('2011', 3200),
      OrdinalSales('2012', 4500),
      OrdinalSales('2013', 4400),
      OrdinalSales('2014', 5000),
      OrdinalSales('2015', 5000),
      OrdinalSales('2016', 4500),
      OrdinalSales('2017', 4300),
    ];

    return [
      Series<OrdinalSales, String>(
        id: 'Global Revenue',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: globalSalesData,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
