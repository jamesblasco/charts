import 'package:charts/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TextStyleSpec extends Equatable {
  final String? fontFamily;
  final int? fontSize;
  final double? lineHeight;
  final Color? color;
  final String? fontWeight;

  const TextStyleSpec(
      {this.fontFamily,
      this.fontSize,
      this.lineHeight,
      this.color,
      this.fontWeight});

  @override
  List<Object?> get props =>
      [fontFamily, fontSize, lineHeight, color, fontWeight];
}

@immutable
class LineStyleSpec {
  final Color? color;
  final List<int>? dashPattern;
  final int? thickness;

  const LineStyleSpec({this.color, this.dashPattern, this.thickness});

  @override
  List<Object?> get props => [
        color,
        dashPattern,
        thickness,
      ];
}
