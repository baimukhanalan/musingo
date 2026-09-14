import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/curriculum_module.dart';

class CurriculumRepository {
  static const assetPath = 'docs/content/approved-570-curriculum-plan.json';

  static Future<List<CurriculumModule>>? _cached;

  static Future<List<CurriculumModule>> load() => _cached ??= _load();

  static Future<List<CurriculumModule>> _load() async {
    final raw = await rootBundle.loadString(assetPath);
    final document = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    final modules = (document['modules'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((item) => CurriculumModule.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((module) => module.id.isNotEmpty && module.title.isNotEmpty)
        .toList(growable: false);
    if (modules.length != 570) {
      throw StateError(
          'Expected 570 curriculum modules, got ${modules.length}.');
    }
    return modules;
  }

  static void clearCacheForTesting() => _cached = null;
}
