import 'package:alchemist/alchemist.dart';
import 'package:example/gallery_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

@isTest
Future<void> testCaseGolden(GalleryScaffold testCase) async {
  goldenTest(testCase.title,
      constraints: BoxConstraints.tight(Size(800, 600)),
      fileName: testCase.title.toLowerCase().replaceAll(' ', '_'), builder: () {
    return testCase.childBuilder();
  });
}

@isTest
Future<void> testChart(String name, WidgetBuilder builder) async {
  goldenTest(name,
      constraints: BoxConstraints.tight(Size(800, 600)),
      fileName: name.toLowerCase().replaceAll(' ', '_'), builder: () {
    return Builder(builder: builder);
  });
}
