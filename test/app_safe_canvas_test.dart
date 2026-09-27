import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('every iPhone route gets a top inset even when web reports zero',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding();
    tester.view.viewPadding = const FakeViewPadding();
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MuslingoApp());
    await tester.pump();
    final canvas = find.byWidgetPredicate((widget) =>
        widget is SafeArea && widget.minimum.top == 72 && !widget.bottom);
    expect(canvas, findsOneWidget);
    expect(tester.getTopLeft(find.byType(Navigator).first).dy,
        greaterThanOrEqualTo(72));
    debugDefaultTargetPlatformOverride = null;
  });
}
