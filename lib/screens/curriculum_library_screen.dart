import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/curriculum_module.dart';
import '../services/app_state.dart';
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
                              _notice(state),
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
                              child: _ModuleCard(module: filtered[index]),
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

  Widget _notice(AppState state) => PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.library_books_rounded, color: AppColors.navy),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.tr(
                  ru: 'Все 570 модулей открыты бесплатно. Для каждого показаны цель, источники и текущий статус редакционной проверки.',
                  kk: 'Барлық 570 модуль тегін ашық. Әр модульде мақсат, дереккөз және редакциялық тексеру мәртебесі көрсетілген.',
                  en: 'All 570 modules are free. Each shows its objective, sources, and current editorial review status.',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      );

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

  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        key: ValueKey('curriculum-module-${module.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.pushNamed(
          context,
          '/curriculum-module',
          arguments: module,
        ),
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
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textLight),
            ],
          ),
        ),
      ),
    );
  }
}

class CurriculumModuleScreen extends StatelessWidget {
  final CurriculumModule module;

  const CurriculumModuleScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              Text(
                '${module.id} · ${module.track}',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: AppColors.sky,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                module.title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 25,
                  height: 1.18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 16),
              _DetailSection(
                title: state.tr(ru: 'Цель', kk: 'Мақсат', en: 'Objective'),
                body: module.objective,
              ),
              _DetailSection(
                title: state.tr(ru: 'Источник', kk: 'Дереккөз', en: 'Source'),
                body: module.sourceLocator,
              ),
              _DetailSection(
                title: state.tr(
                    ru: 'Предварительное условие',
                    kk: 'Алғышарт',
                    en: 'Prerequisite'),
                body: module.prerequisite,
              ),
              _DetailSection(
                title: state.tr(
                    ru: 'Редакционный статус',
                    kk: 'Редакциялық мәртебе',
                    en: 'Editorial status'),
                body: module.reviewStatus,
                warning: module.publicationStatus == 'blocked_until_review',
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/audio-session',
                  arguments: module,
                ),
                icon: const Icon(Icons.headphones_rounded),
                label: Text(state.tr(
                  ru: 'Слушать с этого модуля',
                  kk: 'Осы модульден тыңдау',
                  en: 'Listen from this module',
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final String body;
  final bool warning;

  const _DetailSection({
    required this.title,
    required this.body,
    this.warning = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: PremiumCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (warning) ...[
                    const Icon(Icons.info_outline_rounded,
                        size: 17, color: AppColors.gold),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                body,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      );
}
