part of '../quran_screen.dart';

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.sky),
          const SizedBox(height: 14),
          Text(
            state.tr(
                ru: 'Загружаем проверенный текст…',
                kk: 'Тексерілген мәтін жүктелуде…',
                en: 'Loading verified text…'),
            style: const TextStyle(
                fontFamily: 'Nunito', color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColors.textLight),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label:
                  Text(state.tr(ru: 'Повторить', kk: 'Қайталау', en: 'Retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttributionFooter extends StatelessWidget {
  const _AttributionFooter();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          // Заметка-футер по прототипу 1e.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_download_rounded,
                      size: 18, color: AppColors.gold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.tr(
                        ru: '114 сур · аудио офлайн — в Muslingo+',
                        kk: '114 сүре · аудио офлайн — Muslingo+ ішінде',
                        en: '114 surahs · offline audio — in Muslingo+'),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Icon(Icons.verified_rounded, color: AppColors.navy, size: 22),
          const SizedBox(height: 6),
          const Text(
            'Арабский текст: Tanzil Project, CC BY 3.0.\n'
            'Перевод смыслов: Эльмир Кулиев. '
            'Аудио: Мишари Рашид Аль-Афаси.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              height: 1.5,
              color: AppColors.textGrey,
            ),
          ),
          TextButton(
            onPressed: () =>
                _openSource('https://tanzil.net/docs/Text_License'),
            child: Text(state.tr(
                ru: 'Лицензия и источник',
                kk: 'Лицензия және дереккөз',
                en: 'License and source')),
          ),
        ],
      ),
    );
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.tr(
                  ru: 'Источники Корана',
                  kk: 'Құран дереккөздері',
                  en: 'Quran sources'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.tr(
                ru: 'Арабский Uthmani-текст встроен в приложение как неизменённая '
                    'копия Tanzil Project. Al Quran Cloud используется для '
                    'метаданных, транслитерации, перевода смыслов и аудио. '
                    'Русский текст — перевод смыслов, а не сам Коран.',
                kk: 'Араб Usmani мәтіні қосымшаға Tanzil Project-тің өзгертілмеген '
                    'көшірмесі ретінде енгізілген. Al Quran Cloud метадеректер, '
                    'транслитерация, мағына аудармасы және аудио үшін қолданылады. '
                    'Орыс мәтіні — мағына аудармасы, Құранның өзі емес.',
                en: 'The Arabic Uthmani text is embedded in the app as an '
                    'unchanged copy of the Tanzil Project. Al Quran Cloud is used '
                    'for metadata, transliteration, meaning translation and audio. '
                    'The Russian text is a translation of meanings, not the Quran itself.',
              ),
              style: const TextStyle(
                fontFamily: 'Nunito',
                height: 1.5,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.description_outlined, color: AppColors.navy),
              title: const Text('Tanzil Project'),
              subtitle: Text(state.tr(
                  ru: 'Арабский Uthmani-текст, CC BY 3.0',
                  kk: 'Араб Usmani мәтіні, CC BY 3.0',
                  en: 'Arabic Uthmani text, CC BY 3.0')),
              onTap: () => _openSource('https://tanzil.net/docs/Text_License'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_outlined, color: AppColors.navy),
              title: const Text('Al Quran Cloud'),
              subtitle: Text(state.tr(
                  ru: 'Каталог, перевод, транслитерация и аудио',
                  kk: 'Каталог, аударма, транслитерация және аудио',
                  en: 'Catalog, translation, transliteration and audio')),
              onTap: () => _openSource('https://alquran.cloud/api'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openSource(String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
