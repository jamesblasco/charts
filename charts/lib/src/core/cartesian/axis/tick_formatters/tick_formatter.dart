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

import 'package:charts/core.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

@immutable
abstract class TickFormatter<D> extends Equatable {
  const TickFormatter();
  TickFormatterElement<D> createElement(ChartContext context);
}

// TODO: Break out into separate files.

/// A strategy used for converting domain values of the ticks into Strings.
///
/// [D] is the domain type.
abstract class TickFormatterElement<D> {
  const TickFormatterElement();

  /// Formats a list of tick values.
  List<String> format(
    List<D> tickValues,
    Map<D, String> cache, {
    num? stepSize,
  });
}

abstract class BaseSimpleTickFormatterElement<D>
    extends TickFormatterElement<D> {
  const BaseSimpleTickFormatterElement();

  @override
  List<String> format(
    List<D> tickValues,
    Map<D, String> cache, {
    num? stepSize,
  }) =>
      tickValues.map((value) {
        // Try to use the cached formats first.
        var formattedString = cache[value];
        if (formattedString == null) {
          formattedString = formatValue(value);
          cache[value] = formattedString;
        }
        return formattedString;
      }).toList();

  /// Formats a single tick value.
  String formatValue(D value);
}
