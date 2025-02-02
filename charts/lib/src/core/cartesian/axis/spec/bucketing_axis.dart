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

/// A numeric [AxisData] that positions all values beneath a certain [threshold]
/// into a reserved space on the axis range. The label for the bucket line will
/// be drawn in the middle of the bucket range, rather than aligned with the
/// gridline for that value's position on the scale.
///
/// An example illustration of a bucketing measure axis on a point chart
/// follows. In this case, values such as "6%" and "3%" are drawn in the bucket
/// of the axis, since they are less than the [threshold] value of 10%.
///
///  100% ┠─────────────────────────
///       ┃                  *
///       ┃         *
///   50% ┠──────*──────────────────
///       ┃
///       ┠─────────────────────────
/// < 10% ┃   *          *
///       ┗┯━━━━━━━━━━┯━━━━━━━━━━━┯━
///       0         50          100
///
/// This axis will format numbers as percents by default.
@immutable
class BucketingAxis extends NumericAxis {
  /// Creates a [NumericAxis] that is specialized for percentage data.
  BucketingAxis({
    super.decoration,
    NumericTickProvider? tickProvider,
    NumericTickFormatter? tickFormatter,
    super.showAxisLine,
    bool? showBucket,
    this.threshold,
    NumericExtents? viewport,
  })  : showBucket = showBucket ?? true,
        super(
          tickProvider: tickProvider ?? const BucketingNumericTickProvider(),
          tickFormatter: tickFormatter ??
              NumericTickFormatter.fromFormat(
                NumberFormat.percentPattern(),
              ),
          viewport: viewport ?? const NumericExtents(0.0, 1.0),
        );

  /// All values smaller than the threshold will be bucketed into the same
  /// position in the reserved space on the axis.
  final num? threshold;

  /// Whether or not measure values bucketed below the [threshold] should be
  /// visible on the chart, or collapsed.
  ///
  /// If this is false, then any data with measure values smaller than
  /// [threshold] will not be rendered on the chart.
  final bool showBucket;

  @override
  void configure(
    MutableAxisElement<num> axis,
    ChartContext context,
    GraphicsFactory graphicsFactory,
  ) {
    super.configure(axis, context, graphicsFactory);

    if (axis is NumericAxisElement && viewport != null) {
      axis.setScaleViewport(viewport!);
    }

    if (axis is BucketingNumericAxisElement && threshold != null) {
      axis.threshold = threshold!;
    }

    if (axis is BucketingNumericAxisElement) {
      axis.showBucket = showBucket;
    }
  }

  @override
  BucketingNumericAxisElement createElement() => BucketingNumericAxisElement();

  @override
  List<Object?> get props => [super.props, showBucket, threshold];
}
