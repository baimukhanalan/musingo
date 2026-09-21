import '../utils/app_locale.dart';
import 'learning_profile.dart';
import 'mentor_profile.dart';

enum MentorTipMood { welcome, focus, encourage, celebrate }

/// Local, source-of-truth coaching, not a claimed generative-AI response.
/// Never infer sensitive memories or send profile data to a third party.
class MentorTip {
  final String id;
  final String text;
  final MentorTipMood mood;
  final DateTime refreshAt;

  const MentorTip(
      {required this.id,
      required this.text,
      required this.mood,
      required this.refreshAt});

  static const cadence = Duration(hours: 12);

  static MentorTip build({
    required DateTime now,
    required AppLocale locale,
    required MentorProfile profile,
    String learnerName = '',
    LearningGoal? goal,
    String? nextLesson,
    LearningSkill? weakestSkill,
    int dueReviews = 0,
    int weakItems = 0,
    int todayProgress = 0,
    int dailyGoal = 3,
    int streak = 0,
    DateTime? lastStudyDate,
  }) {
    final window = now.millisecondsSinceEpoch ~/ cadence.inMilliseconds;
    final variant = window % 2;
    final refreshAt = DateTime.fromMillisecondsSinceEpoch(
        (window + 1) * cadence.inMilliseconds,
        isUtc: now.isUtc);
    String tr(String ru, String kk, String en) => switch (locale) {
          AppLocale.ru => ru,
          AppLocale.kk => kk,
          AppLocale.en => en,
        };
    final personal =
        profile.memoryEnabled && profile.personalizedRemindersEnabled;
    final rawName = personal
        ? (profile.preferredName.isNotEmpty
            ? profile.preferredName
            : learnerName)
        : '';
    final name = _short(rawName, 24);
    final address = name.isEmpty ? '' : '$name, ';
    final minutes = personal ? profile.preferredSessionMinutes.clamp(3, 30) : 5;
    MentorTip result(String kind, String text, MentorTipMood mood) => MentorTip(
          id: '$window-${locale.code}-$kind-$variant',
          text: '$address$text',
          mood: mood,
          refreshAt: refreshAt,
        );

    if (personal && profile.isBirthday(now)) {
      return result(
          'birthday',
          variant == 0
              ? tr(
                  'с днём рождения! Пусть сегодня будет время для себя — знакомый аят и спокойные $minutes минут.',
                  'туған күніңмен! Бүгін өзіңе уақыт бөл: таныс аят және $minutes минут тыныш оқу.',
                  'happy birthday! Make a little time for yourself: a familiar ayah and $minutes quiet minutes.')
              : tr(
                  'с днём рождения! Выбери любимый пройденный урок — сегодня можно учиться в своём темпе.',
                  'туған күніңмен! Өткен сабақтардың ішінен ұнағанын таңда — бүгін өз қарқыныңмен оқы.',
                  'happy birthday! Revisit a lesson you enjoyed and learn at your own pace today.'),
          MentorTipMood.celebrate);
    }
    if (todayProgress >= dailyGoal && dailyGoal > 0) {
      return result(
          'complete',
          variant == 0
              ? tr(
                  'дневная цель выполнена: $todayProgress/$dailyGoal. Теперь можно отдохнуть — завтра продолжим.',
                  'күндік мақсат орындалды: $todayProgress/$dailyGoal. Енді демалуға болады — ертең жалғастырамыз.',
                  'daily goal complete: $todayProgress/$dailyGoal. You can rest now — we’ll continue tomorrow.')
              : tr(
                  'сегодня уже $todayProgress уроков. Вспомни одну полезную мысль без подсказки и заверши занятие.',
                  'бүгін $todayProgress сабақ өтті. Бір пайдалы ойды көмексіз еске түсіріп, сабақты аяқта.',
                  'you’ve done $todayProgress lessons today. Recall one useful idea without hints, then call it a day.'),
          MentorTipMood.celebrate);
    }
    if (dueReviews > 0) {
      return result(
          'review',
          variant == 0
              ? tr(
                  'на повторение — $dueReviews. Начни со знакомого материала и выдели $minutes минут перед новым уроком.',
                  'қайталауға $dueReviews тапсырма бар. Жаңа сабаққа дейін таныс материалға $minutes минут бөл.',
                  '$dueReviews reviews are due. Spend $minutes minutes on familiar material before a new lesson.')
              : tr(
                  'сегодня ждут $dueReviews повторений. Сначала вспомни ответ сам, затем проверь себя по материалу.',
                  'бүгін $dueReviews қайталау күтіп тұр. Алдымен жауапты өзің еске түсір, содан кейін материалмен тексер.',
                  '$dueReviews reviews are waiting. Try recalling the answer first, then check it against the material.'),
          MentorTipMood.focus);
    }
    if (lastStudyDate != null && now.difference(lastStudyDate).inDays >= 3) {
      return result(
          'return',
          variant == 0
              ? tr(
                  'после перерыва начни со знакомого урока. $minutes минут достаточно для спокойного возвращения.',
                  'үзілістен кейін таныс сабақтан баста. Оқуға жайлап оралу үшін $minutes минут жеткілікті.',
                  'after a break, start with a familiar lesson. $minutes minutes is enough for a gentle return.')
              : tr(
                  'не нужно наверстывать всё сразу. Повтори один знакомый фрагмент и двигайся дальше, когда будешь готов.',
                  'бәрін бірден қуып жету міндет емес. Бір таныс үзіндіні қайталап, дайын болғанда жалғастыр.',
                  'there’s no need to catch up all at once. Review one familiar passage and continue when you’re ready.'),
          MentorTipMood.encourage);
    }
    if (weakItems > 0 || (weakestSkill != null && variant == 0)) {
      final skill = weakestSkill?.titleFor(locale) ??
          tr('Повторение', 'Қайталау', 'Review');
      return result(
          'skill',
          variant == 0
              ? tr(
                  'укрепим навык «$skill»: изучи один пример и объясни его своими словами.',
                  '«$skill» дағдысын нығайтамыз: бір мысалды қарап, өз сөзіңмен түсіндір.',
                  'let’s strengthen “$skill”: study one example and explain it in your own words.')
              : tr(
                  'для навыка «$skill» попробуй короткую проверку без подсказок. Затем вернись только к трудному месту.',
                  '«$skill» дағдысын көмексіз тексеріп көр. Содан кейін тек қиын тұсын қайтала.',
                  'try a short “$skill” check without hints, then revisit only the part that felt difficult.'),
          MentorTipMood.focus);
    }

    final focus = personal ? _short(profile.currentFocus, 48) : '';
    final topic = focus.isNotEmpty
        ? focus
        : goal?.titleFor(locale) ?? _short(nextLesson ?? '', 60);
    final chosen = topic.isEmpty
        ? tr('один небольшой урок', 'бір шағын сабақ', 'one short lesson')
        : '«$topic»';
    final text = variant == 0
        ? tr(
            'твой следующий шаг — $chosen. Выдели $minutes минут и в конце проверь, что сможешь вспомнить сам.',
            'келесі қадамың — $chosen. $minutes минут бөл де, соңында не есте қалғанын көмексіз тексер.',
            'your next step is $chosen. Set aside $minutes minutes, then check what you can recall on your own.')
        : profile.tone == MentorTone.focused && personal
            ? tr(
                'план на $minutes минут: $chosen, один пример, затем проверка без подсказок.',
                '$minutes минуттық жоспар: $chosen, бір мысал, содан кейін көмексіз тексеру.',
                'a $minutes-minute plan: $chosen, one example, then a check without hints.')
            : tr(
                'продолжим с $chosen. Не спеши: один понятный пример полезнее нескольких бегло просмотренных.',
                '$chosen тақырыбымен жалғастырайық. Асықпа: бірнешеуін жылдам қарағанша, бір мысалды түсінген пайдалы.',
                'let’s continue with $chosen. Take your time: one well-understood example beats skimming several.');
    return result(
        'next',
        text,
        streak > 0 || (personal && profile.tone == MentorTone.cheerful)
            ? MentorTipMood.encourage
            : MentorTipMood.welcome);
  }

  static String _short(String text, int limit) {
    final clean = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    return clean.runes.length <= limit
        ? clean
        : '${String.fromCharCodes(clean.runes.take(limit - 1))}…';
  }
}
