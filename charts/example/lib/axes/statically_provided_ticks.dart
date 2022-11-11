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

/// Example of axis using statically provided ticks.
// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';
// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:flutter/material.dart';
import 'package:charts/charts.dart';

/// Example of specifying a custom set of ticks to be used on the domain axis.
///
/// Specifying custom set of ticks allows specifying exactly what ticks are
/// used in the axis. Each tick is also allowed to have a different style set.
///
/// For an ordinal axis, the [StaticOrdinalTickProvider] is shown in this
/// example defining ticks to be used with [Tick] of String.
///
/// For numeric axis, the [StaticNumericTickProvider] can be used by passing
/// in a list of ticks defined with [Tick] of num.
///
/// For datetime axis, the [StaticDateTimeTickProviderSpec] can be used by
/// passing in a list of ticks defined with [Tick] of datetime.
class StaticallyProvidedTicks extends StatelessWidget {
  final List<Series<dynamic, String>> seriesList;
  final bool animate;

  StaticallyProvidedTicks(this.seriesList, {this.animate = false});

  factory StaticallyProvidedTicks.withSampleData() {
    return StaticallyProvidedTicks(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory StaticallyProvidedTicks.withRandomData() {
    return StaticallyProvidedTicks(_createRandomData());
  }

  /// Create random data.
  static List<Series<OrdinalSales, String>> _createRandomData() {
    final random = Random();

    final globalSalesData = [
      OrdinalSales('2014', random.nextInt(100) * 100),
      OrdinalSales('2015', random.nextInt(100) * 100),
      OrdinalSales('2016', random.nextInt(100) * 100),
      OrdinalSales('2017', random.nextInt(100) * 100),
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
    // Create the ticks to be used the domain axis.
    final staticTicks = <Tick<String>>[
      Tick(
          // Value must match the domain value.
          '2014',
          // Optional label for this tick, defaults to domain value if not set.
          label: 'Year 2014',
          // The styling for this tick.
          style: TextStyle(color: Color.fromARGB(0xFF, 0x4C, 0xAF, 0x50))),
      // If no text style is specified - the style from renderSpec will be used
      // if one is specified.
      Tick('2015'),
      Tick('2016'),
      Tick('2017'),
    ];

    return BarChart(
      seriesList,
      animate: animate,
      domainAxis:
          OrdinalAxis(tickProvider: StaticOrdinalTickProvider(staticTicks)),
    );
  }

  /// Create series list with single series
  static List<Series<OrdinalSales, String>> _createSampleData() {
    final globalSalesData = [
      OrdinalSales('2014', 5000),
      OrdinalSales('2015', 25000),
      OrdinalSales('2016', 100000),
      OrdinalSales('2017', 750000),
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
