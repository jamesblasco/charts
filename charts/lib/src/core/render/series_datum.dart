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

import 'package:charts/src/core/render/processed_series.dart'
    show ImmutableSeries;
import 'package:charts/src/core/render/processed_series.dart';
import 'package:equatable/equatable.dart';

/// Stores datum and the series the datum originated.
class SeriesDatum<D> extends Equatable {
  SeriesDatum({
    required this.datum,
    required this.series,
  });
  final ImmutableSeries<D> series;
  final dynamic datum;

  /// Returns null if-and-only if [datum] is null.
  late final int? index = () {
    if (datum == null) return null;
    return series.data.indexOf(datum);
  }();

  @override
  List<Object?> get props => [series, datum];
}

/// Represents a series datum based on series id and datum index.
class SeriesDatumConfig<D> extends Equatable {
  const SeriesDatumConfig(this.seriesId, this.domainValue);
  final String seriesId;
  final D domainValue;

  @override
  List<Object?> get props => [seriesId, domainValue];
}
