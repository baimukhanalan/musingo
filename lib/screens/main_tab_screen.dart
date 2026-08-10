import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hafiz_progress.dart';
import '../services/app_state.dart';
import '../services/quran_repository.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import 'home_screen.dart';
import 'quran_screen.dart';
import 'coach_screen.dart';
import 'hafiz_mode_screen.dart';
import 'profile_screen.dart';
import 'onboarding_screen.dart';

class MainTabScreen extends StatefulWidget {
  final int initialIndex;
  const MainTabScreen({super.key, this.initialIndex = 0});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  // Таббар прототипа: «Главная · Коран · Coach · Hafiz · Профиль».
  // «Основы ислама» больше не отдельная вкладка — они переехали в раздел на
  // главной. Слот 3 занял режим заучивания (Hafiz): хаб _HafizHubScreen ведёт
  // в HafizModeScreen по конкретному аяту. Лига/соперники-боты в навигацию не
  // вернулись — соревнование живёт в разделе «Друзья» в профиле.

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.sky)),
      );
    }
    if (!appState.isLoggedIn) return const OnboardingScreen();

    // Строим список вкладок в build(), т.к. Hafiz-хабу нужен колбэк перехода
    // на вкладку «Коран». IndexedStack сохраняет состояние детей по позиции.
    final screens = <Widget>[
      const HomeScreen(),
      const QuranScreen(),
      const CoachScreen(),
      _HafizHubScreen(onOpenQuran: () => _onTap(1)),
      const ProfileScreen(),
    ];

    return Scaffold(
      // IndexedStack держит все вкладки живыми, но НЕ глушит тикеры скрытых
      // детей: CatCharacter.repeat() в неактивных вкладках жёг бы CPU/батарею.
      // TickerMode(enabled: только у активной) замораживает анимации скрытых
      // вкладок и возобновляет их при переключении.
      body: IndexedStack(
        index: _current,
        children: [
          for (var i = 0; i < screens.length; i++)
            TickerMode(enabled: i == _current, child: screens[i]),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border:
              const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -3))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _NavItem(
                    icon: Icons.home_rounded,
                    label: appState.tr(
                        ru: 'Главная', kk: 'Басты', en: 'Home'),
                    index: 0,
                    current: _current,
                    onTap: _onTap),
                _NavItem(
                    icon: Icons.menu_book_rounded,
                    label: appState.tr(
                        ru: 'Коран', kk: 'Құран', en: 'Quran'),
                    index: 1,
                    current: _current,
                    onTap: _onTap),
                _NavItem(
                    icon: Icons.auto_awesome_rounded,
                    label: 'Coach',
                    index: 2,
                    current: _current,
                    onTap: _onTap),
                _NavItem(
                    icon: Icons.self_improvement_rounded,
                    label: 'Hafiz',
                    index: 3,
                    current: _current,
                    onTap: _onTap),
                _NavItem(
                    icon: Icons.person_rounded,
                    label: appState.tr(
                        ru: 'Профиль', kk: 'Профиль', en: 'Profile'),
                    index: 4,
                    current: _current,
                    onTap: _onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) => setState(() => _current = index);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isActive,
        label: label,
        child: GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        isActive ? AppColors.skyLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon,
                      color: isActive ? AppColors.sky : AppColors.textLight,
                      size: 25),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isActive
                        ? AppColors.pistachioDark
                        : AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Хаб режима заучивания (Hafiz). Сам HafizModeScreen работает по конкретному
/// аяту (chapter + verse), поэтому не может быть корневой вкладкой напрямую —
/// этот экран показывает прогресс заучивания из AppState и открывает
/// HafizModeScreen для выбранного аята, догружая суру через QuranRepository.
class _HafizHubScreen extends StatefulWidget {
  final VoidCallback onOpenQuran;
  const _HafizHubScreen({required this.onOpenQuran});

  @override
  State<_HafizHubScreen> createState() => _HafizHubScreenState();
}

class _HafizHubScreenState extends State<_HafizHubScreen> {
  final QuranRepository _repository = QuranRepository();
  String? _openingId;

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  Future<void> _openHafiz(HafizProgress progress) async {
    if (_openingId != null) return;
    setState(() => _openingId = progress.id);
    try {
      final chapters = await _repository.fetchChapters();
      final summary =
          chapters.firstWhere((c) => c.number == progress.surahNumber);
      final chapter = await _repository.fetchChapter(summary);
      final verse = chapter.verses
          .firstWhere((v) => v.numberInChapter == progress.verseNumber);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => HafizModeScreen(chapter: summary, verse: verse),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final state = context.read<AppState>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr(
            ru: 'Не удалось открыть аят. Проверьте интернет.',
            kk: 'Аятты ашу мүмкін болмады. Интернетті тексеріңіз.',
            en: 'Could not open the verse. Check your internet.',
          )),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final progress = appState.hafizProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Hafiz',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _HafizHeader(
            memorizedCount: appState.memorizedVerseCount,
            dueCount: appState.hafizDueCount,
          ),
          const SizedBox(height: 18),
          if (progress.isEmpty)
            _HafizEmptyState(onOpenQuran: widget.onOpenQuran)
          else ...[
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Text(
                appState.tr(
                  ru: 'Твои аяты',
                  kk: 'Сенің аяттарың',
                  en: 'Your verses',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
            ),
            for (final item in progress)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HafizVerseCard(
                  progress: item,
                  isDue: item.isDue(),
                  isOpening: _openingId == item.id,
                  onTap: () => _openHafiz(item),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _HafizHeader extends StatelessWidget {
  final int memorizedCount;
  final int dueCount;

  const _HafizHeader({
    required this.memorizedCount,
    required this.dueCount,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 58,
            height: 58,
            child: CatCharacter(mood: CatMood.prayer, size: 58),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr(
                    ru: 'Заучивание Корана',
                    kk: 'Құранды жаттау',
                    en: 'Memorizing the Quran',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  state.tr(
                    ru: 'Выучено: $memorizedCount · к повторению: $dueCount',
                    kk: 'Жатталды: $memorizedCount · қайталауға: $dueCount',
                    en: 'Learned: $memorizedCount · to review: $dueCount',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.skyLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HafizEmptyState extends StatelessWidget {
  final VoidCallback onOpenQuran;
  const _HafizEmptyState({required this.onOpenQuran});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            state.tr(
              ru: 'Пока нет аятов на заучивание',
              kk: 'Әзірге жаттауға аят жоқ',
              en: 'No verses to memorize yet',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.tr(
              ru: 'Открой суру в разделе «Коран» и начни заучивать любой аят — '
                  'он появится здесь для повторения.',
              kk: '«Құран» бөлімінен сүрені аш та кез келген аятты жаттай баста — '
                  'ол осы жерде қайталау үшін пайда болады.',
              en: 'Open a surah in the «Quran» section and start memorizing any '
                  'verse — it will appear here for review.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.4,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOpenQuran,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sky,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                state.tr(
                  ru: 'Открыть Коран',
                  kk: 'Құранды ашу',
                  en: 'Open the Quran',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HafizVerseCard extends StatelessWidget {
  final HafizProgress progress;
  final bool isDue;
  final bool isOpening;
  final VoidCallback onTap;

  const _HafizVerseCard({
    required this.progress,
    required this.isDue,
    required this.isOpening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mastery = progress.mastery.clamp(0.0, 1.0);
    final state = context.watch<AppState>();

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isOpening ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${progress.surahName} · '
                            '${state.tr(ru: 'аят', kk: 'аят', en: 'verse')} '
                            '${progress.verseNumber}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (isDue)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.goldLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              state.tr(
                                ru: 'Повторить',
                                kk: 'Қайталау',
                                en: 'Review',
                              ),
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: mastery,
                        minHeight: 7,
                        backgroundColor: AppColors.backgroundGrey,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.success),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      progress.masteryLabel,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 24,
                height: 24,
                child: isOpening
                    ? const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.sky,
                      )
                    : const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textLight,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
