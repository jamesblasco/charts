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

enum PanningTickProviderMode {
  /// Return cached ticks.
  useCachedTicks,

  /// Request ticks with [TickHint] calculated from cached ticks.
  stepSizeLocked,

  /// Request ticks directly from tick provider.
  passThrough,
}

/// Wraps an existing tick provider to be able to return cached ticks during
/// zoom in/out, return ticks calculated with locked step size during panning,
/// or just pass through to the existing tick provider.
class PanningTickProvider<D> extends TickStrategyElement<D> {
  PanningTickProvider(this.tickProvider);
  final TickStrategyElement<D> tickProvider;

  PanningTickProviderMode _mode = PanningTickProviderMode.passThrough;

  late List<TickElement<D>> _ticks;

  set mode(PanningTickProviderMode mode) {
    _mode = mode;
  }

  @override
  List<TickElement<D>> getTicks({
    required ChartContext? context,
    required GraphicsFactory graphicsFactory,
    required MutableScaleElement<D> scale,
    required TickFormatterElement<D> formatter,
    required Map<D, String> formatterValueCache,
    required TickDrawStrategy<D> tickDrawStrategy,
    required AxisOrientation? orientation,
    bool viewportExtensionEnabled = false,
    TickHint<D>? tickHint,
  }) {
    if (_mode == PanningTickProviderMode.stepSizeLocked) {
      tickHint = TickHint(
        _ticks.first.value,
        _ticks.last.value,
        tickCount: _ticks.length,
      );
    }

    if (_mode != PanningTickProviderMode.useCachedTicks) {
      _ticks = tickProvider.getTicks(
        context: context,
        graphicsFactory: graphicsFactory,
        scale: scale,
        formatter: formatter,
        formatterValueCache: formatterValueCache,
        tickDrawStrategy: tickDrawStrategy,
        orientation: orientation,
        viewportExtensionEnabled: viewportExtensionEnabled,
        tickHint: tickHint,
      );
    }

    return _ticks;
  }

  @override
  List<Object?> get props => [tickProvider, _ticks, _mode];
}
