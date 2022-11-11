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

import 'package:charts/charts/pie.dart';

/// Configuration for an [ArcRenderer].
class ArcRendererConfig<D> extends BaseArcRendererConfig<D> {
  ArcRendererConfig({
    super.customRendererId,
    super.arcLength,
    super.arcRendererDecorators,
    super.arcRatio,
    super.arcWidth,
    super.layoutPaintOrder,
    super.minHoleWidthForCenterContent,
    super.startAngle,
    super.strokeWidth,
  });

  @override
  ArcRenderer<D> build() {
    return ArcRenderer<D>(config: this, rendererId: customRendererId);
  }
}
