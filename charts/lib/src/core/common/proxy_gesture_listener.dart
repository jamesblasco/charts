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


import 'package:charts/charts.dart';
import 'package:collection/collection.dart' show IterableExtension;

/// Listens to all gestures and proxies to child listeners.
class ProxyGestureListener {
  final _listeners = <GestureListener>[];
  var _activeListeners = <GestureListener>[];

  void add(GestureListener listener) {
    _listeners.add(listener);
    _activeListeners.clear();
  }

  void remove(GestureListener listener) {
    _listeners.remove(listener);
    _activeListeners.clear();
  }

  bool onTapTest(Offset localPosition) {
    _activeListeners.clear();
    return _populateActiveListeners(localPosition);
  }

  bool onLongPress(Offset localPosition) {
    // Walk through listeners stopping at the first handled listener.
    final claimingListener = _activeListeners.firstWhereOrNull(
      (GestureListener listener) =>
          listener.onLongPress?.call(localPosition) ?? false,
    );

    // If someone claims the long press, then cancel everyone else.
    if (claimingListener != null) {
      _activeListeners =
          _cancel(all: _activeListeners, keep: [claimingListener]);
      return true;
    }
    return false;
  }

  bool onTap(Offset localPosition) {
    // Walk through listeners stopping at the first handled listener.
    final claimingListener = _activeListeners.firstWhereOrNull(
      (GestureListener listener) =>
          listener.onTap?.call(localPosition) ?? false,
    );

    // If someone claims the tap, then cancel everyone else.
    // This should hopefully be rare, like for drilling.
    if (claimingListener != null) {
      _activeListeners =
          _cancel(all: _activeListeners, keep: [claimingListener]);
      return true;
    }
    return false;
  }

  bool onHover(Offset localPosition) {
    // Cancel any previously active long lived gestures.
    _activeListeners = <GestureListener>[];

    // Walk through listeners stopping at the first handled listener.
    return _listeners.any(
      (GestureListener listener) =>
          listener.onHover?.call(localPosition) ?? false,
    );
  }

  bool onDragStart(Offset localPosition) {
    // In Flutter, a tap test may not be triggered because a tap down event
    // may not be registered if the the drag gesture happens without any pause.
    if (_activeListeners.isEmpty) {
      _populateActiveListeners(localPosition);
    }

    // Walk through listeners stopping at the first handled listener.
    final claimingListener = _activeListeners.firstWhereOrNull(
      (GestureListener listener) =>
          listener.onDragStart?.call(localPosition) ?? false,
    );

    if (claimingListener != null) {
      _activeListeners =
          _cancel(all: _activeListeners, keep: [claimingListener]);
      return true;
    }
    return false;
  }

  bool onDragUpdate(Offset localPosition, double scale) {
    return _activeListeners.any(
      (GestureListener listener) =>
          listener.onDragUpdate?.call(localPosition, scale) ?? false,
    );
  }

  bool onDragEnd(
    Offset localPosition,
    double scale,
    double pixelsPerSecond,
  ) {
    return _activeListeners.any(
      (GestureListener listener) =>
          listener.onDragEnd?.call(localPosition, scale, pixelsPerSecond) ??
          false,
    );
  }

  bool onFocus() {
    return _listeners
        .any((GestureListener listener) => listener.onFocus?.call() ?? false);
  }

  bool onBlur() {
    return _listeners
        .any((GestureListener listener) => listener.onBlur?.call() ?? false);
  }

  List<GestureListener> _cancel({
    required List<GestureListener> all,
    required List<GestureListener> keep,
  }) {
    for (final listener in all) {
      if (!keep.contains(listener)) {
        listener.onTapCancel();
      }
    }
    return keep;
  }

  bool _populateActiveListeners(Offset localPosition) {
    final localListeners = List.of(_listeners);

    var previouslyClaimed = false;
    for (final listener in localListeners) {
      final claimed = listener.onTapTest(localPosition);
      if (claimed && !previouslyClaimed) {
        // Cancel any already added non-claiming listeners now that someone is
        // claiming it.
        _activeListeners = _cancel(all: _activeListeners, keep: [listener]);
        previouslyClaimed = true;
      } else if (claimed || !previouslyClaimed) {
        _activeListeners.add(listener);
      }
    }

    return previouslyClaimed;
  }
}
