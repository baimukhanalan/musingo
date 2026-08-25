part of '../settings_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final faqs = [
      {
        'q': state.tr(
            ru: 'Как начать учёбу?',
            kk: 'Оқуды қалай бастаймын?',
            en: 'How do I start learning?'),
        'a': state.tr(
            ru: 'Нажми на любой урок на главном экране и следуй шагам. Каждый урок занимает 3-7 минут.',
            kk: 'Негізгі экрандағы кез келген сабақты басып, қадамдарды орында. Әр сабақ 3-7 минут алады.',
            en: 'Tap any lesson on the home screen and follow the steps. Each lesson takes 3-7 minutes.')
      },
      {
        'q': state.tr(
            ru: 'Как работают жизни?',
            kk: 'Жандар қалай жұмыс істейді?',
            en: 'How do lives work?'),
        'a': state.tr(
            ru: 'У тебя 5 жизней. Каждая ошибка забирает одну. Без жизней нужно ждать восстановления или купить muslingo+.',
            kk: 'Сенде 5 жан бар. Әр қате біреуін алады. Жансыз қалғанда қалпына келуін күту немесе muslingo+ сатып алу керек.',
            en: 'You have 5 lives. Each mistake takes one. With no lives, wait for them to recover or get muslingo+.')
      },
      {
        'q': state.tr(
            ru: 'Что такое страйк?',
            kk: 'Страйк дегеніміз не?',
            en: 'What is a streak?'),
        'a': state.tr(
            ru: 'Страйк — дни учёбы подряд. Если ты занимаешься каждый день, страйк растёт. Не забывай заниматься!',
            kk: 'Страйк — қатарынан оқыған күндер. Күн сайын оқысаң, страйк өседі. Оқуды ұмытпа!',
            en: 'A streak is your run of consecutive study days. Study every day and it grows. Do not forget to practice!')
      },
      {
        'q': state.tr(
            ru: 'Как получить XP?',
            kk: 'XP-ны қалай аламын?',
            en: 'How do I earn XP?'),
        'a': state.tr(
            ru: 'XP начисляется за уроки (+25), правильные ответы (+5) и повторение аятов (+2).',
            kk: 'XP сабақтар (+25), дұрыс жауаптар (+5) және аяттарды қайталау (+2) үшін беріледі.',
            en: 'XP is awarded for lessons (+25), correct answers (+5), and reviewing ayahs (+2).')
      },
      {
        'q': state.tr(
            ru: 'Когда появится Muslingo+?',
            kk: 'Muslingo+ қашан шығады?',
            en: 'When will Muslingo+ arrive?'),
        'a': state.tr(
            ru: 'Подписка откроется после подключения безопасной оплаты через App Store и Google Play.',
            kk: 'Жазылым App Store және Google Play арқылы қауіпсіз төлем қосылғаннан кейін ашылады.',
            en: 'The subscription will open once secure payments through the App Store and Google Play are connected.')
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _ScreenHeader(
                  title: state.tr(ru: 'Помощь', kk: 'Көмек', en: 'Help')),
              const SizedBox(height: 20),
              ...faqs.map((f) => _FaqTile(question: f['q']!, answer: f['a']!)),
              const SizedBox(height: 12),
              PremiumCard(
                color: AppColors.skyLight.withValues(alpha: 0.55),
                child: Column(
                  children: [
                    Text(
                        state.tr(
                            ru: 'Не нашёл ответа?',
                            kk: 'Жауап таппадың ба?',
                            en: 'Did not find an answer?'),
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navyDark)),
                    const SizedBox(height: 8),
                    Text(
                        state.tr(
                            ru: 'Напиши нам — ответим в течение 24 часов',
                            kk: 'Бізге жаз — 24 сағат ішінде жауап береміз',
                            en: 'Write to us — we reply within 24 hours'),
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                            height: 1.35),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    _SupportButton(
                      onPressed: () async {
                        final uri = Uri(
                          scheme: 'mailto',
                          path: 'support@muslingo.app',
                          queryParameters: {'subject': 'Поддержка Muslingo'},
                        );
                        final opened = await launchUrl(uri);
                        if (!opened && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.tr(
                                  ru: 'Не удалось открыть почтовое приложение',
                                  kk: 'Пошта қолданбасын ашу мүмкін болмады',
                                  en: 'Could not open the mail app')),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Volumetric sky support button (self-contained so it can carry the async
/// mailto handler as an onPressed callback).
class _SupportButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SupportButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.navyDark.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.sky.withValues(alpha: 0.4),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 19, color: AppColors.white),
                      const SizedBox(width: 8),
                      Text(
                          state.tr(
                              ru: 'Написать в поддержку',
                              kk: 'Қолдау қызметіне жазу',
                              en: 'Contact support'),
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppColors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border:
            _open ? Border.all(color: AppColors.pistachio, width: 1.5) : null,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.pistachio.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.help_outline_rounded,
                        color: AppColors.pistachio, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(widget.question,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark))),
                  Icon(
                      _open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.pistachio),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(62, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.answer,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                        height: 1.5)),
              ),
            ),
        ],
      ),
    );
  }
}
