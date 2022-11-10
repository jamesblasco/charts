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

/// Hour specific tick formatter which will format noon differently.
class HourTickFormatter extends TimeTickFormatterImpl {
  HourTickFormatter({
    required DateTimeFactory dateTimeFactory,
    required super.simpleFormat,
    required super.transitionFormat,
    required String? noonFormat,
  }) : super(
          dateTimeFactory: dateTimeFactory,
          transitionField: CalendarField.date,
        ) {
    _noonFormat = dateTimeFactory.createDateFormat(noonFormat);
  }
  late final DateFormat _noonFormat;

  @override
  String formatSimpleTick(DateTime date) {
    return (date.hour == 12)
        ? _noonFormat.format(date)
        : super.formatSimpleTick(date);
  }
}
