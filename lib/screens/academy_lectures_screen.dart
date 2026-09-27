import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/academy_lecture_catalog.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/premium_card.dart';
import 'lesson_video_player_screen.dart';

/// A separate shelf of complete external lectures. It never changes progress
/// in the 570 interactive modules, and it never presents an excerpt as a full
/// lecture or a source-metadata check as religious expert approval.
class AcademyLecturesScreen extends StatefulWidget {
  const AcademyLecturesScreen({super.key});

  @override
  State<AcademyLecturesScreen> createState() => _AcademyLecturesScreenState();
}

class _AcademyLecturesScreenState extends State<AcademyLecturesScreen> {
  final _search = TextEditingController();
  String _query = '';
  String _category = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final entries = AcademyLectureCatalog.all.where((lecture) {
      if (_category != 'all' && lecture.category != _category) return false;
      return _query.isEmpty ||
          lecture.title.toLowerCase().contains(_query.toLowerCase());
    }).toList(growable: false);

    return CustomScrollView(
      key: const ValueKey('academy-lecture-list'),
      slivers: [
        SliverToBoxAdapter(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.tr(
                  ru: '220 полных лекций',
                  kk: '220 толық дәріс',
                  en: '220 complete lectures',
                  ar: '٢٢٠ محاضرة كاملة',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.tr(
                  ru: 'Оригиналы на русском · отдельно от 570 модулей, без XP. Проверены ссылки и темы; богословское содержание новых лекций ещё ждёт экспертной проверки.',
                  kk: 'Түпнұсқалар орыс тілінде · 570 модульден бөлек, XP берілмейді. Сілтемелер мен тақырыптар тексерілді; мазмұн сарапшының тексеруін күтуде.',
                  en: 'Russian originals · separate from the 570 modules, no XP. Source links and titles are checked; the new lectures still await theological expert review.',
                  ar: 'المحاضرات الأصلية بالروسية · منفصلة عن الوحدات الـ٥٧٠ ودون نقاط. تم التحقق من الروابط والعناوين، والمحتوى بانتظار مراجعة شرعية متخصصة.',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('academy-lecture-search'),
                controller: _search,
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: state.tr(
                    ru: 'Найти лекцию',
                    kk: 'Дәрісті іздеу',
                    en: 'Find a lecture',
                    ar: 'ابحث عن محاضرة',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip(
                        state,
                        'all',
                        state.tr(
                            ru: 'Все', kk: 'Барлығы', en: 'All', ar: 'الكل')),
                    _chip(
                        state,
                        'reading',
                        state.tr(
                            ru: 'Чтение',
                            kk: 'Оқу',
                            en: 'Reading',
                            ar: 'القراءة')),
                    _chip(
                        state,
                        'meaning',
                        state.tr(
                            ru: 'Смысл сур',
                            kk: 'Сүрелер мәні',
                            en: 'Surah meaning',
                            ar: 'معاني السور')),
                    _chip(
                        state,
                        'prayer',
                        state.tr(
                            ru: 'Намаз',
                            kk: 'Намаз',
                            en: 'Prayer',
                            ar: 'الصلاة')),
                  ],
                ),
              ),
            ],
          ),
        )),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
          sliver: SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final lecture = entries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PremiumCard(
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    key: ValueKey('academy-lecture-${lecture.youtubeId}'),
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => LessonVideoPlayerScreen(
                          video: lecture.toPlayerVideo(),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.skyLight,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: AppColors.navyDark, size: 27),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lecture.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.navyDark,
                                    )),
                                const SizedBox(height: 4),
                                Text(
                                    'Русский · ${lecture.durationLabel} · Абу Ясин',
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 11,
                                      color: AppColors.textGrey,
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(AppState state, String value, String label) => Padding(
        padding: const EdgeInsets.only(right: 7),
        child: ChoiceChip(
          key: ValueKey('academy-lecture-filter-$value'),
          label: Text(label),
          selected: _category == value,
          onSelected: (_) => setState(() => _category = value),
        ),
      );
}
