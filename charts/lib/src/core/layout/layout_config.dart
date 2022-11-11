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

import 'package:equatable/equatable.dart';

/// Collection of configurations that apply to the [LayoutManager].
class LayoutConfig extends Equatable {
  /// Create a new [LayoutConfig] used by [DynamicLayoutManager].
  LayoutConfig({
    LayoutMargin? margin,
  }) : margin = margin ?? LayoutMargin.all(LayoutValue(50));

  final LayoutMargin margin;

  @override
  List<Object?> get props => [margin];
}

class LayoutMargin extends Equatable {
  const LayoutMargin({
    this.top = LayoutValue.zero,
    this.left = LayoutValue.zero,
    this.right = LayoutValue.zero,
    this.bottom = LayoutValue.zero,
  });

  const LayoutMargin.symetric({LayoutValue? horizontal, LayoutValue? vertical})
      : top = vertical ?? LayoutValue.zero,
        left = horizontal ?? LayoutValue.zero,
        right = horizontal ?? LayoutValue.zero,
        bottom = vertical ?? LayoutValue.zero;

  const LayoutMargin.all(LayoutValue? value)
      : top = value ?? LayoutValue.zero,
        left = value ?? LayoutValue.zero,
        right = value ?? LayoutValue.zero,
        bottom = value ?? LayoutValue.zero;

  static const LayoutMargin zero = LayoutMargin.all(LayoutValue.zero);

  final LayoutValue top;
  final LayoutValue left;
  final LayoutValue right;
  final LayoutValue bottom;

  @override
  List<Object?> get props => [top, left, right, bottom];
}

/// Specs that applies to one margin.
class LayoutValue extends Equatable {
  /// Create [LayoutValue] with a fixed pixel size [pixels].
  ///
  /// [pixels] if set must be greater than or equal to 0.
  factory LayoutValue(int? pixels) {
    // Require require or higher setting if set
    assert(pixels == null || pixels >= 0);
    return LayoutValue._internal(pixels, pixels, null, null);
  }

  const LayoutValue._internal(
    int? minPixel,
    int? maxPixel,
    int? minPercent,
    int? maxPercent,
  )   : _minPixel = minPixel,
        _maxPixel = maxPixel,
        _minPercent = minPercent,
        _maxPercent = maxPercent;

  /// Create [LayoutValue] that specifies min/max pixels.
  ///
  /// [minPixel] if set must be greater than or equal to 0 and less than max if
  /// it is also set.
  /// [maxPixel] if set must be greater than or equal to 0.
  factory LayoutValue.between({int? minPixel, int? maxPixel}) {
    // Require zero or higher settings if set
    assert(minPixel == null || minPixel >= 0);
    assert(maxPixel == null || maxPixel >= 0);
    // Min must be less than or equal to max.
    // Can be equal to enforce strict pixel size.
    if (minPixel != null && maxPixel != null) {
      assert(minPixel <= maxPixel);
    }

    return LayoutValue._internal(minPixel, maxPixel, null, null);
  }

  /// Create [LayoutValue] that specifies min/max percentage.
  ///
  /// [minPercent] if set must be between 0 and 100 inclusive. If [maxPercent]
  /// is also set, then must be less than [maxPercent].
  /// [maxPercent] if set must be between 0 and 100 inclusive.
  factory LayoutValue.relativeBetween({int? minPercent, int? maxPercent}) {
    // Percent must be within 0 to 100
    assert(minPercent == null || (minPercent >= 0 && minPercent <= 100));
    assert(maxPercent == null || (maxPercent >= 0 && maxPercent <= 100));
    // Min must be less than or equal to max.
    // Can be equal to enforce strict percentage.
    if (minPercent != null && maxPercent != null) {
      assert(minPercent <= maxPercent);
    }

    return LayoutValue._internal(null, null, minPercent, maxPercent);
  }

  final int? _minPixel;
  final int? _maxPixel;
  final int? _minPercent;
  final int? _maxPercent;

  /// Get the min pixels, given the [totalPixels].
  int getMinPixels(int totalPixels) {
    final minPixel = _minPixel;
    final minPercent = _minPercent;
    if (minPixel != null) {
      assert(minPixel < totalPixels);
      return minPixel;
    } else if (minPercent != null) {
      return (totalPixels * (minPercent / 100)).round();
    } else {
      return 0;
    }
  }

  /// Get the max pixels, given the [totalPixels].
  int getMaxPixels(int totalPixels) {
    final maxPixel = _maxPixel;
    final maxPercent = _maxPercent;
    if (maxPixel != null) {
      assert(maxPixel < totalPixels);
      return maxPixel;
    } else if (maxPercent != null) {
      return (totalPixels * (maxPercent / 100)).round();
    } else {
      return totalPixels;
    }
  }

  static const zero = LayoutValue._internal(0, 0, null, null);

  @override
  List<Object?> get props => [_minPixel, _maxPixel, _minPercent, _maxPercent];
}
