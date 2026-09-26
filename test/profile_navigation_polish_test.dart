import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muslingo/screens/main_tab_screen.dart';
import 'package:muslingo/screens/friends_screen.dart';
import 'package:muslingo/screens/profile_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/profile_avatar_store.dart';
import 'package:muslingo/widgets/editable_profile_avatar.dart';
import 'package:muslingo/widgets/language_pills.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppState> guest(WidgetTester tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 15));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });
    expect(state.isInitialized, isTrue);
    addTearDown(state.dispose);
    return state;
  }

  Widget host(AppState state, Widget screen) => ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(home: screen),
      );

  testWidgets(
      'tab visits and retap reset vertical scroll without clearing draft',
      (tester) async {
    final state = await guest(tester);
    await tester.pumpWidget(host(state, const MainTabScreen()));
    await tester.pump();
    final homeScroll =
        tester.state<ScrollableState>(find.byType(Scrollable).first);
    homeScroll.position.jumpTo(250);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('bottom-nav-4')));
    await tester.pump(const Duration(milliseconds: 300));
    final profileScroll = tester.state<ScrollableState>(find
        .descendant(
            of: find.byType(ProfileScreen), matching: find.byType(Scrollable))
        .first);
    profileScroll.position.jumpTo(300);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('bottom-nav-0')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(homeScroll.position.pixels, 0);
    await tester.tap(find.byKey(const ValueKey('bottom-nav-4')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(profileScroll.position.pixels, 0);
    profileScroll.position.jumpTo(300);
    await tester.tap(find.byKey(const ValueKey('bottom-nav-4')));
    await tester.pump();
    expect(profileScroll.position.pixels, 0);
    await tester.tap(find.byKey(const ValueKey('bottom-nav-2')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField).last, 'Несохранённый вопрос');
    await tester.tap(find.byKey(const ValueKey('bottom-nav-0')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('bottom-nav-2')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Несохранённый вопрос'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('no language picker remains in profile or friends',
      (tester) async {
    final state = await guest(tester);
    for (final screen in [const ProfileScreen(), const FriendsScreen()]) {
      await tester.pumpWidget(host(state, screen));
      await tester.pump();
      expect(find.byType(LanguagePills), findsNothing);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('avatar sheet supports cancellation without altering the default',
      (tester) async {
    final state = await guest(tester);
    var pickerCalls = 0;
    await tester.pumpWidget(host(
        state,
        Scaffold(
            body: EditableProfileAvatar(
          storageScope: state.avatarStorageScope,
          pickImage: () async {
            pickerCalls++;
            return null;
          },
        ))));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('profile-avatar-edit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('только на этом устройстве'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(pickerCalls, 0);
    await tester.tap(find.byKey(const ValueKey('profile-avatar-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('avatar-pick-photo')));
    await tester.pumpAndSettle();
    expect(pickerCalls, 1);
    expect(find.byKey(const ValueKey('profile-avatar-photo')), findsNothing);
    expect(await ProfileAvatarStore().load(state.avatarStorageScope), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('invalid selected avatar reports error and keeps default',
      (tester) async {
    final state = await guest(tester);
    await tester.pumpWidget(host(
        state,
        Scaffold(
            body: EditableProfileAvatar(
          storageScope: state.avatarStorageScope,
          pickImage: () async => XFile.fromData(
            Uint8List.fromList('<svg>not a photo</svg>'.codeUnits),
            mimeType: 'image/svg+xml',
          ),
        ))));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('profile-avatar-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('avatar-pick-photo')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Попробуй JPG'), findsOneWidget);
    expect(find.byKey(const ValueKey('profile-avatar-photo')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'guest reset rotates avatar ownership while normal restart retains it',
      (tester) async {
    final state = await guest(tester);
    final original = state.avatarStorageScope;
    final preferences = await SharedPreferences.getInstance();
    expect(original, startsWith('guest:'));
    await preferences.setString(ProfileAvatarStore.keyFor(original), 'old');
    await state.logout();
    await state.loginAsGuest();
    expect(state.avatarStorageScope, isNot(original));
    expect(preferences.getString(ProfileAvatarStore.keyFor(original)), isNull);
  });
}
