import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/curriculum_progress.dart';
import 'package:muslingo/services/curriculum_progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test('restart and lower assessment cannot erase achieved progress', () async {
    await CurriculumProgressService.recordStep(
        learnerId: 'one', moduleId: 'QUR-001', step: 3);
    final restart = await CurriculumProgressService.recordStep(
        learnerId: 'one', moduleId: 'QUR-001', step: 0);
    expect(restart.stepByModuleId['QUR-001'], 3);
    await CurriculumProgressService.complete(
        learnerId: 'one', moduleId: 'QUR-001', mastery: 90);
    await CurriculumProgressService.recordStep(
        learnerId: 'one', moduleId: 'QUR-001', step: 1);
    final retried = await CurriculumProgressService.complete(
        learnerId: 'one', moduleId: 'QUR-001', mastery: 60);
    expect(retried.stepByModuleId['QUR-001'], 4);
    expect(retried.masteryByModuleId['QUR-001'], 90);
    expect(retried.completionFor('QUR-001'), 1);
    final improved = await CurriculumProgressService.complete(
        learnerId: 'one', moduleId: 'QUR-001', mastery: 100);
    expect(improved.masteryByModuleId['QUR-001'], 100);
  });

  test('concurrent answers preserve every module and remain account isolated',
      () async {
    await Future.wait([
      CurriculumProgressService.recordStep(
          learnerId: 'one', moduleId: 'QUR-001', step: 3),
      CurriculumProgressService.recordStep(
          learnerId: 'one', moduleId: 'QUR-002', step: 2),
      CurriculumProgressService.complete(
          learnerId: 'one', moduleId: 'QUR-001', mastery: 95),
      CurriculumProgressService.recordStep(
          learnerId: 'one', moduleId: 'QUR-001', step: 1),
      CurriculumProgressService.recordStep(
          learnerId: 'two', moduleId: 'QUR-004', step: 2),
    ]);
    final first = await CurriculumProgressService.load('one');
    expect(first.stepByModuleId, {'QUR-001': 4, 'QUR-002': 2});
    expect(first.masteryByModuleId['QUR-001'], 95);
    final second = await CurriculumProgressService.load('two');
    expect(second.stepByModuleId, {'QUR-004': 2});
  });

  test('persist merges stale snapshots without losing completions', () async {
    await CurriculumProgressService.persist(
        'one',
        const CurriculumProgress(
          completedModuleIds: {'QUR-001'},
          stepByModuleId: {'QUR-001': 4},
          masteryByModuleId: {'QUR-001': 100},
        ));
    await CurriculumProgressService.persist(
        'one',
        const CurriculumProgress(
          stepByModuleId: {'QUR-001': 1, 'QUR-002': 2},
          masteryByModuleId: {'QUR-001': 50},
        ));
    final saved = await CurriculumProgressService.load('one');
    expect(saved.completedModuleIds, {'QUR-001'});
    expect(saved.stepByModuleId, {'QUR-001': 4, 'QUR-002': 2});
    expect(saved.masteryByModuleId['QUR-001'], 100);
    expect(CurriculumProgress.fromJson(saved.toJson()).masteryByModuleId,
        saved.masteryByModuleId);
  });
}
