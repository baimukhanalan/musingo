import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'saved module stages and completion notify profile listeners without minting rewards',
      () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    final deadline = DateTime.now().add(const Duration(seconds: 10));
    while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(state.isInitialized, isTrue);
    await state.loginAsGuest();
    final userBefore = state.user!.toJson();
    final observed = <Map<String, dynamic>>[];
    state.addListener(() => observed.add(state.curriculumProgress));

    state.updateCurriculumProgress({
      'completedModuleIds': <String>[],
      'stepByModuleId': {'QUR-001': 2},
    });
    expect(observed, hasLength(1));
    expect((observed.last['stepByModuleId'] as Map)['QUR-001'], 2);

    final completed = {
      'completedModuleIds': ['QUR-001'],
      'stepByModuleId': {'QUR-001': 4},
      'masteryByModuleId': {'QUR-001': 100},
      'lastActivityAt': DateTime.now().toIso8601String(),
    };
    state.updateCurriculumProgress(completed);
    expect(observed, hasLength(2));
    expect(observed.last['completedModuleIds'], ['QUR-001']);
    state.updateCurriculumProgress(completed);
    expect(state.user!.toJson(), userBefore,
        reason: 'a client completion map is not an authoritative receipt');
    expect(state.achievements.every((achievement) => !achievement.isUnlocked),
        isTrue);
    state.dispose();
  });
}
