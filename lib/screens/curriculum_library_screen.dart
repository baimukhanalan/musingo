import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/curriculum_module.dart';
import '../models/curriculum_progress.dart';
import '../services/app_state.dart';
import '../services/curriculum_progress_service.dart';
import '../services/curriculum_repository.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';

class CurriculumLibraryScreen extends StatefulWidget {
  final Future<List<CurriculumModule>>? modulesFuture;

  const CurriculumLibraryScreen({
    super.key,
    @visibleForTesting this.modulesFuture,
  });

  @override
  State<CurriculumLibraryScreen> createState() =>
      _CurriculumLibraryScreenState();
}

class _CurriculumLibraryScreenState extends State<CurriculumLibraryScreen> {
  late final Future<List<CurriculumModule>> _modules =
      widget.modulesFuture ?? CurriculumRepository.load();
  final _searchController = TextEditingController();
  String _query = '';
  String _track = 'all';
  CurriculumProgress _progress = const CurriculumProgress();
  String? _learnerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final learnerId = context.read<AppState>().user?.id ?? 'anonymous-learner';
    if (_learnerId == learnerId) return;
    _learnerId = learnerId;
    _reloadProgress();
  }

  Future<void> _reloadProgress() async {
    final learnerId = _learnerId;
    if (learnerId == null) return;
    final local = await CurriculumProgressService.load(learnerId);
    if (!mounted || learnerId != _learnerId) return;
    final remote = CurriculumProgress.fromJson(
      context.read<AppState>().curriculumProgress,
    );
    final progress = local.mergedWith(remote);
    await CurriculumProgressService.persist(learnerId, progress);
    if (mounted && learnerId == _learnerId) {
      setState(() => _progress = progress);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _header(state),
              Expanded(
                child: FutureBuilder<List<CurriculumModule>>(
                  future: _modules,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(state.tr(
                          ru: 'Не удалось открыть библиотеку.',
                          kk: 'Кітапхананы ашу мүмкін болмады.',
                          en: 'Could not open the library.',
                        )),
                      );
                    }
                    final modules = snapshot.data;
                    if (modules == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final filtered = _filter(modules);
                    return CustomScrollView(
                      key: const ValueKey('curriculum-scroll'),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                          sliver: SliverList.list(
                            children: [
                              _learningDashboard(state, modules),
                              const SizedBox(height: 14),
                              TextField(
                                key: const ValueKey('curriculum-search'),
                                controller: _searchController,
                                onChanged: (value) =>
                                    setState(() => _query = value.trim()),
                                decoration: InputDecoration(
                                  hintText: state.tr(
                                    ru: 'Найти модуль',
                                    kk: 'Модульді табу',
                                    en: 'Find a module',
                                  ),
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: _query.isEmpty
                                      ? null
                                      : IconButton(
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _query = '');
                                          },
                                          icon: const Icon(Icons.close_rounded),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _trackChip(
                                        state,
                                        'all',
                                        state.tr(
                                          ru: 'Все 570',
                                          kk: 'Барлық 570',
                                          en: 'All 570',
                                        )),
                                    _trackChip(state, 'Quran', 'Quran · 150'),
                                    _trackChip(state, 'Arabic', 'Arabic · 170'),
                                    _trackChip(state, 'Tajwid', 'Tajwid · 70'),
                                    _trackChip(state, 'Foundations/Academy',
                                        'Foundations · 180'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                state.tr(
                                  ru: 'Найдено: ${filtered.length}',
                                  kk: 'Табылды: ${filtered.length}',
                                  en: 'Found: ${filtered.length}',
                                ),
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
                          sliver: SliverList.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ModuleCard(
                                module: filtered[index],
                                progress: _progress,
                                onReturn: _reloadProgress,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppState state) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 18, 6),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.navyDark),
            ),
            Expanded(
              child: Text(
                state.tr(
                  ru: 'Библиотека 570',
                  kk: '570 кітапханасы',
                  en: 'Library 570',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark,
                ),
              ),
            ),
            IconButton.filled(
              key: const ValueKey('open-continuous-audio'),
              onPressed: () => Navigator.pushNamed(context, '/audio-session'),
              tooltip: state.tr(
                ru: 'Аудиорежим',
                kk: 'Аудиорежим',
                en: 'Audio mode',
              ),
              icon: const Icon(Icons.headphones_rounded),
            ),
          ],
        ),
      );

  Widget _learningDashboard(
    AppState state,
    List<CurriculumModule> modules,
  ) {
    final completed = _progress.completedCount.clamp(0, modules.length);
    final value = modules.isEmpty ? 0.0 : completed / modules.length;
    CurriculumModule? continuation;
    final lastId = _progress.lastModuleId;
    if (lastId != null) {
      for (final module in modules) {
        if (module.id == lastId &&
            !_progress.completedModuleIds.contains(module.id)) {
          continuation = module;
          break;
        }
      }
    }
    return PremiumCard(
      color: AppColors.navyDark,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.sky.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.sky),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr(
                        ru: 'Твоя образовательная траектория',
                        kk: 'Сенің оқу траекторияң',
                        en: 'Your learning path',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      state.tr(
                        ru: '$completed из 570 модулей освоено',
                        kk: '570 модульдің $completed аяқталды',
                        en: '$completed of 570 modules mastered',
                      ),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.sky,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 9,
              backgroundColor: AppColors.white.withValues(alpha: 0.16),
              color: AppColors.sky,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            state.tr(
              ru: 'Все модули бесплатны: теория, источники, активная практика и проверка мастерства.',
              kk: 'Барлық модуль тегін: теория, дереккөз, белсенді тәжірибе және меңгеруді тексеру.',
              en: 'Every module is free: concept, sources, active practice, and mastery checks.',
            ),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.white.withValues(alpha: 0.82),
            ),
          ),
          if (continuation != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('curriculum-continue'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sky,
                foregroundColor: AppColors.navyDark,
              ),
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  '/curriculum-module',
                  arguments: continuation,
                );
                await _reloadProgress();
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(state.tr(
                ru: 'Продолжить ${continuation.id}',
                kk: '${continuation.id} жалғастыру',
                en: 'Continue ${continuation.id}',
              )),
            ),
          ],
        ],
      ),
    );
  }

  Widget _trackChip(AppState state, String value, String label) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          selected: _track == value,
          onSelected: (_) => setState(() => _track = value),
          label: Text(label),
        ),
      );

  List<CurriculumModule> _filter(List<CurriculumModule> modules) {
    final query = _query.toLowerCase();
    return modules.where((module) {
      final trackMatches = _track == 'all' || module.track == _track;
      final queryMatches = query.isEmpty ||
          module.id.toLowerCase().contains(query) ||
          module.title.toLowerCase().contains(query) ||
          module.strand.toLowerCase().contains(query) ||
          module.objective.toLowerCase().contains(query);
      return trackMatches && queryMatches;
    }).toList(growable: false);
  }
}

class _ModuleCard extends StatelessWidget {
  final CurriculumModule module;
  final CurriculumProgress progress;
  final Future<void> Function() onReturn;

  const _ModuleCard({
    required this.module,
    required this.progress,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        key: ValueKey('curriculum-module-${module.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () async {
          await Navigator.pushNamed(
            context,
            '/curriculum-module',
            arguments: module,
          );
          await onReturn();
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.skyLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${module.sequence}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${module.id} · ${module.strand}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      module.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              _ModuleProgressBadge(
                completion: progress.completionFor(module.id),
                mastery: progress.masteryByModuleId[module.id],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleProgressBadge extends StatelessWidget {
  final double completion;
  final int? mastery;

  const _ModuleProgressBadge({required this.completion, required this.mastery});

  @override
  Widget build(BuildContext context) {
    if (mastery != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, size: 15, color: AppColors.success),
            const SizedBox(width: 3),
            Text(
              '$mastery%',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }
    if (completion > 0) {
      return SizedBox(
        width: 34,
        height: 34,
        child: CircularProgressIndicator(
          value: completion,
          strokeWidth: 4,
          backgroundColor: AppColors.border,
          color: AppColors.sky,
        ),
      );
    }
    return const Icon(Icons.chevron_right_rounded, color: AppColors.textLight);
  }
}
