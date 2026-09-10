import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/utils/colors.dart';
import 'package:muslingo/widgets/premium_button.dart';

void main() {
  testWidgets('long primary action remains fully rendered at 320px',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: PremiumButton(
                label: 'Войти или создать аккаунт',
                icon: Icons.login_rounded,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Войти или создать аккаунт'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final label = tester.widget<Text>(find.text('Войти или создать аккаунт'));
    expect(label.overflow, isNull);
  });
}
