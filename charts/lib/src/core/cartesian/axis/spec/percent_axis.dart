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
import 'package:intl/intl.dart';
import 'package:meta/meta.dart' show immutable;

/// Convenience [AxisData] specialized for numeric percentage axes.
@immutable
class PercentAxisSpec extends NumericAxis {
  /// Creates a [NumericAxis] that is specialized for percentage data.
  PercentAxisSpec({
    super.decoration,
    NumericTickProvider? tickProvider,
    NumericTickFormatter? tickFormatter,
    super.showAxisLine,
    NumericExtents? viewport,
  }) : super(
          tickProvider: tickProvider ??
              const BasicNumericTickProvider(dataIsInWholeNumbers: false),
          tickFormatter: tickFormatter ??
              NumericTickFormatter.fromFormat(
                NumberFormat.percentPattern(),
              ),
          viewport: viewport ?? const NumericExtents(0.0, 1.0),
        );

  @override
  List<Object?> get props => [super.props];
}
