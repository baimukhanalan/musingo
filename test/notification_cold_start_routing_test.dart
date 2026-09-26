import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/main.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/screens/onboarding_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/notification_service_io.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    NotificationPlatform.onOpenRoute = null;
  });

  tearDown(() {
    NotificationPlatform.onOpenRoute = null;
  });

  testWidgets('notification at 1450ms is not replaced by the splash timer',
      (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MuslingoApp());
    final state = tester.element(find.byType(MaterialApp)).read<AppState>();
    // Real asset I/O must finish without advancing the splash's fake clock.
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(state.isInitialized, isTrue);
    final recommendedId = state.recommendedLesson!.id;

    await tester.pump(const Duration(milliseconds: 1450));
    expect(find.byType(LessonScreen), findsNothing);
    expect(NotificationPlatform.onOpenRoute, isNotNull);
    // Exercise the production notification callback, not a separate navigator.
    NotificationPlatform.onOpenRoute!('/daily-plan');
    expect(tester.binding.hasScheduledFrame, isTrue);
    await tester.pump();
    await tester.pump();
    // The first incoming route layout is offstage for Hero measurements.
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(LessonScreen), findsOneWidget);

    // At 1600ms the splash is still mounted during the 320ms lesson transition.
    await tester.pump(const Duration(milliseconds: 134));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(LessonScreen), findsOneWidget);
    final lesson = tester.widget<LessonScreen>(find.byType(LessonScreen));
    expect(lesson.lesson.id, recommendedId);
    expect(ModalRoute.of(tester.element(find.byType(LessonScreen)))!.isCurrent,
        isTrue);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 500));
  });
}
