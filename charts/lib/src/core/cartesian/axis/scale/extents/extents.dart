import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

export 'numeric_extents.dart';
export 'ordinal_extents.dart';

@immutable
abstract class Extents<D> extends Equatable {
  const Extents.base();
}
