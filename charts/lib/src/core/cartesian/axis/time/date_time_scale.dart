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

/// [DateTimeScale] is a wrapper for [LinearScaleElement].
/// [DateTime] values are converted to millisecondsSinceEpoch and passed to the
/// [LinearScaleElement].
class DateTimeScale extends MutableScaleElement<DateTime> {
  DateTimeScale(this.dateTimeFactory) : _linearScale = LinearScaleElement();

  DateTimeScale._copy(DateTimeScale other)
      : dateTimeFactory = other.dateTimeFactory,
        _linearScale = other._linearScale.copy();
  final DateTimeFactory dateTimeFactory;
  final LinearScaleElement _linearScale;

  @override
  num operator [](DateTime domainValue) =>
      _linearScale[domainValue.millisecondsSinceEpoch];

  @override
  DateTime reverse(double pixelLocation) =>
      dateTimeFactory.createDateTimeFromMilliSecondsSinceEpoch(
        _linearScale.reverse(pixelLocation).round(),
      );

  @override
  void resetDomain() {
    _linearScale.resetDomain();
  }

  @override
  set stepSizeConfig(StepSizeConfig config) {
    _linearScale.stepSizeConfig = config;
  }

  @override
  StepSizeConfig get stepSizeConfig => _linearScale.stepSizeConfig;

  @override
  set rangeBandConfig(RangeBandConfig barGroupWidthConfig) {
    _linearScale.rangeBandConfig = barGroupWidthConfig;
  }

  @override
  void setViewportSettings(double viewportScale, double viewportTranslate) {
    _linearScale.setViewportSettings(viewportScale, viewportTranslate);
  }

  @override
  set range(ScaleOutputExtent? extent) {
    _linearScale.range = extent;
  }

  @override
  void addDomain(DateTime domainValue) {
    _linearScale.addDomain(domainValue.millisecondsSinceEpoch);
  }

  @override
  void resetViewportSettings() {
    _linearScale.resetViewportSettings();
  }

  DateTimeExtents get viewportDomain {
    final extents = _linearScale.viewportDomain;
    return DateTimeExtents(
      start: dateTimeFactory
          .createDateTimeFromMilliSecondsSinceEpoch(extents.min.toInt()),
      end: dateTimeFactory
          .createDateTimeFromMilliSecondsSinceEpoch(extents.max.toInt()),
    );
  }

  set viewportDomain(DateTimeExtents extents) {
    _linearScale.viewportDomain = NumericExtents(
      extents.start.millisecondsSinceEpoch,
      extents.end.millisecondsSinceEpoch,
    );
  }

  @override
  DateTimeScale copy() => DateTimeScale._copy(this);

  @override
  double get viewportTranslate => _linearScale.viewportTranslate;

  @override
  double get viewportScalingFactor => _linearScale.viewportScalingFactor;

  @override
  bool isRangeValueWithinViewport(double rangeValue) =>
      _linearScale.isRangeValueWithinViewport(rangeValue);

  @override
  int compareDomainValueToViewport(DateTime domainValue) => _linearScale
      .compareDomainValueToViewport(domainValue.millisecondsSinceEpoch);

  @override
  double get rangeBand => _linearScale.rangeBand;

  @override
  double get stepSize => _linearScale.stepSize;

  @override
  double get domainStepSize => _linearScale.domainStepSize;

  @override
  RangeBandConfig get rangeBandConfig => _linearScale.rangeBandConfig;

  @override
  int get rangeWidth => _linearScale.rangeWidth;

  @override
  ScaleOutputExtent? get range => _linearScale.range;

  @override
  bool canTranslate(DateTime domainValue) =>
      _linearScale.canTranslate(domainValue.millisecondsSinceEpoch);

  NumericExtents get dataExtent => _linearScale.dataExtent;
}
