import 'dart:convert';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/curriculum_progress.dart';

class CurriculumProgressService {
  static const _prefix = 'curriculum_570_progress_v2_';
  static final Map<String, Future<void>> _pendingWrites = {};

  // Read/modify/write must be serial per learner. Two quick answers otherwise
  // read the same snapshot and the slower write silently loses progress.
  static Future<T> _mutate<T>(String learnerId, Future<T> Function() action) {
    final previous = _pendingWrites[learnerId] ?? Future<void>.value();
    final result = previous.then((_) => action());
    final settled =
        result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    _pendingWrites[learnerId] = settled;
    settled.then((_) {
      if (identical(_pendingWrites[learnerId], settled)) {
        _pendingWrites.remove(learnerId);
      }
    });
    return result;
  }

  static String _key(String learnerId) => '$_prefix$learnerId';

  static Future<CurriculumProgress> load(String learnerId) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key(learnerId));
    if (raw == null || raw.isEmpty) return const CurriculumProgress();
    try {
      return CurriculumProgress.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      await preferences.remove(_key(learnerId));
      return const CurriculumProgress();
    }
  }

  static Future<void> persist(
    String learnerId,
    CurriculumProgress progress,
  ) =>
      _mutate(learnerId, () async {
        final current = await load(learnerId);
        await _save(learnerId, current.mergedWith(progress));
      });

  static Future<CurriculumProgress> recordStep({
    required String learnerId,
    required String moduleId,
    required int step,
  }) =>
      _mutate(learnerId, () async {
        final current = await load(learnerId);
        final steps = Map<String, int>.from(current.stepByModuleId);
        steps[moduleId] = math.max(steps[moduleId] ?? 0, step.clamp(0, 4));
        final updated = CurriculumProgress(
          completedModuleIds: current.completedModuleIds,
          stepByModuleId: steps,
          masteryByModuleId: current.masteryByModuleId,
          lastModuleId: moduleId,
          lastActivityAt: DateTime.now(),
        );
        await _save(learnerId, updated);
        return updated;
      });

  static Future<CurriculumProgress> complete({
    required String learnerId,
    required String moduleId,
    required int mastery,
  }) =>
      _mutate(learnerId, () async {
        final current = await load(learnerId);
        final completed = Set<String>.from(current.completedModuleIds)
          ..add(moduleId);
        final steps = Map<String, int>.from(current.stepByModuleId)
          ..[moduleId] = 4;
        final scores = Map<String, int>.from(current.masteryByModuleId);
        scores[moduleId] =
            math.max(scores[moduleId] ?? 0, mastery.clamp(0, 100));
        final updated = CurriculumProgress(
          completedModuleIds: completed,
          stepByModuleId: steps,
          masteryByModuleId: scores,
          lastModuleId: moduleId,
          lastActivityAt: DateTime.now(),
        );
        await _save(learnerId, updated);
        return updated;
      });

  static Future<void> _save(
    String learnerId,
    CurriculumProgress progress,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _key(learnerId),
      jsonEncode(progress.toJson()),
    );
    if (!saved) throw StateError('Could not save curriculum progress.');
  }
}
