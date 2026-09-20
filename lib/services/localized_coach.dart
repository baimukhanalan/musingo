import '../models/coach.dart';

/// Offline mentor responses are authored in each supported language, so a
/// provider outage never silently changes the learner's language to Russian.
class LocalizedCoach {
  static const kazakhSuggestions = [
    'Бүгін нені қайталауым керек?',
    'Маған қай сабақ қолайлы?',
    'Менің әлсіз тұстарым қандай?',
    'Тәжуидтің қай ережесін қайталайын?',
    'Маған шағын тест бер',
    'Келесі қай сүрені үйренейін?',
    'Сүрені жаттауға көмектес',
    '7 күндік жоспар құр',
  ];
  static const englishSuggestions = [
    'What should I review today?',
    'Which lesson suits me?',
    'What are my weak areas?',
    'Which tajwid rule should I review?',
    'Give me a short test',
    'Which surah should I learn next?',
    'Help me memorize a surah',
    'Make a 7-day plan',
  ];

  static CoachResponse answer(
      String question, CoachContext context, String locale) {
    final kk = locale == 'kk';
    String t(String kz, String en) => kk ? kz : en;
    final q = question.toLowerCase();
    bool has(List<String> words) => words.any(q.contains);
    final progress = CoachSource(
      title: t('Muslingo оқу барысы', 'Your Muslingo progress'),
      category: t('Жеке оқу деректері', 'Learning data'),
      verification: t('Осы құрылғыдағы нәтижелер', 'Results on this device'),
    );
    final lesson =
        context.recommendedLessonTitle ?? t('келесі сабақ', 'the next lesson');
    final start = t('Сабақты бастау', 'Start lesson');
    final why = context.dueReviewCount > 0
        ? t('${context.dueReviewCount} тапсырманы қайталау уақыты келді. Алдымен соларды бекітеміз.',
            '${context.dueReviewCount} items are due for review. We will reinforce these first.')
        : t('Бұл сабақ мақсатың мен қазіргі оқу деңгейіңе сәйкес келеді.',
            'This lesson matches your goal and current learning level.');

    if (has([
      'fatwa',
      'фетва',
      'дәрі',
      'диагноз',
      'medicine',
      'diagnosis',
      'халал ма'
    ])) {
      return CoachResponse(
        text: t(
            'Бұл сұрақты жеке жағдайыңды білетін білікті маманмен талқылаған дұрыс. Мен пәтуа немесе медициналық кеңес бермеймін.',
            'Please discuss this with a qualified specialist who understands your situation. I cannot issue a fatwa or medical advice.'),
        actionType: CoachActionType.contactSpecialist,
        actionLabel: t('Маманға сұрақ қою', 'Ask a specialist'),
        sources: [
          CoachSource(
            title:
                t('ҚМДБ: сұрақтар мен жауаптар', 'DUMK: questions and answers'),
            category: t('Маман кеңесі', 'Expert consultation'),
            verification: t('ҚМДБ ресми сайты', 'Official DUMK website'),
            url: 'https://www.muftyat.kz/kk/qa/',
          )
        ],
      );
    }
    if (RegExp(r'^(remember|есіңде сақта|запомни)', caseSensitive: false)
        .hasMatch(q)) {
      return CoachResponse(
          text: context.mentorProfile.memoryEnabled
              ? t('Тәлімгер жадын ашып, сақталған жазбаны көруге немесе өшіруге болады.',
                  'You can view or delete the saved note in Mentor memory.')
              : t('Тәлімгер жады өшірулі. Қаласаң, оны баптаулардан қосуға болады.',
                  'Mentor memory is turned off. You can enable it in settings.'));
    }
    if (has(['жатта', 'memorize', 'memorise', 'hafiz', 'хафиз'])) {
      return CoachResponse(
        text: t(
            'Бір аяттан бастайық: тыңда, бөліктерге бөліп қайтала, содан кейін мәтінге қарамай айтып көр. Қазір ${context.hafizDueCount} аятты қайталау керек; меңгерілгені — ${context.memorizedVerseCount}.',
            'Start with one ayah: listen, repeat in short sections, then recall it without looking. You have ${context.hafizDueCount} ayahs due and ${context.memorizedVerseCount} memorized.'),
        sources: [progress],
        actionType: CoachActionType.openHafiz,
        actionLabel: t('Жаттауды ашу', 'Open memorization'),
      );
    }
    if (has(['фатиха', 'fatih', 'meaning', 'мағына', 'түсіндір'])) {
      return CoachResponse(
        text: t(
            'Әл-Фатиха — Құранның бірінші сүресі. Аяттарды аудармасымен бірге оқып, мағыналарын салыстыр. Бұл оқу көмегі; ғалымның тәпсірін алмастырмайды.',
            'Al-Fatihah is the first surah of the Quran. Read the ayahs alongside their translation and compare their meanings. This learning aid does not replace scholarly tafsir.'),
        sources: [
          CoachSource(
            title: t('Құран, Әл-Фатиха 1:1–7', 'Quran, Al-Fatihah 1:1–7'),
            category: t('Құран', 'Quran'),
            verification:
                t('Аят пен сүреге сілтеме', 'Surah and ayah reference'),
            url: 'https://quran.com/1',
          )
        ],
        actionType: CoachActionType.openQuran,
        actionLabel: t('Құраннан оқу', 'Read in the Quran'),
      );
    }
    if (has(['тест', 'test', 'quiz', 'тексер'])) {
      return CoachResponse(
        text: t(
            'Қазіргі ${context.placementLevel}-деңгейіңе сай қысқа тексеру жасайық. Жауапты алдын ала көрсетпеймін: нәтижеге қарай қайталау жоспары жаңарады.',
            'Let’s check your understanding at level ${context.placementLevel}. The lesson will test you before revealing answers and update your review plan.'),
        sources: [progress],
        actionType: CoachActionType.startLesson,
        actionLabel: t('Тексеруді бастау', 'Start check'),
        lessonId: context.recommendedLessonId,
      );
    }
    if (has(['тәжуид', 'таджвид', 'tajwid', 'pronunc', 'дыбыс', 'айтыл'])) {
      return CoachResponse(
        text: t(
            'Алдымен үлгіні тыңда, дыбыстың созылуы мен шығу орнына назар аудар. Содан кейін өзің қайтала. Автоматты тексеру оқу үшін көмектеседі, бірақ тәжуид ұстазын алмастырмайды.',
            'Listen to the example first, paying attention to length and articulation, then repeat it. Automated feedback supports practice but does not replace a tajwid teacher.'),
        sources: [progress],
        reasoning: why,
        actionType: CoachActionType.startLesson,
        actionLabel: start,
        lessonId: context.recommendedLessonId,
      );
    }
    if (has(['7 күн', '7-day', 'week', 'апта'])) {
      return CoachResponse(
        text: t(
            '7 күндік жоспар: алғашқы екі күн — бұрынғы қателерді қайталау; 3–4-күн — жаңа сабақ пен тыңдау; 5-күн — мәтінге қарамай еске түсіру; 6-күн — әлсіз тұстар; 7-күн — қысқа тексеру. Күніне ${context.availableMinutes} минут жеткілікті.',
            'A 7-day plan: days 1–2, review previous mistakes; days 3–4, a new lesson and listening; day 5, recall without looking; day 6, weak areas; day 7, a short check. Aim for ${context.availableMinutes} minutes a day.'),
        sources: [progress],
        reasoning: why,
        actionType: CoachActionType.startLesson,
        actionLabel: start,
        lessonId: context.recommendedLessonId,
      );
    }
    if (has(['weak', 'әлсіз'])) {
      final weak = context.weakKnowledge.toList()
        ..sort((a, b) {
          final lapses = b.lapses.compareTo(a.lapses);
          return lapses != 0 ? lapses : a.strength.compareTo(b.strength);
        });
      if (weak.isNotEmpty) {
        final item = weak.first;
        return CoachResponse(
          text: t(
            'Нәтижелерің бойынша ${weak.length} тапсырманы бекіткен дұрыс. Алдымен ${item.lapses} рет қате кеткен тапсырмаға оралайық: үлгіні тыңда, жауапты есіңе түсір, содан кейін өзіңді тексер.',
            'Your results show ${weak.length} items to reinforce. Start with the item missed ${item.lapses} times: listen to the example, recall the answer, then check yourself.',
          ),
          sources: [progress],
          reasoning: t(
              'Бұл таңдау жалпы кеңеске емес, сенің қателеріңе негізделген.',
              'This choice is based on your recorded mistakes, not generic advice.'),
          actionType: CoachActionType.startLesson,
          actionLabel: t('Әлсіз тұсты бекіту', 'Practice the weak area'),
          lessonId: item.lessonId,
        );
      }
      return CoachResponse(
        text: t(
            'Әзірге әлсіз тұсты анықтауға жеткілікті қате тіркелмеген. «$lesson» сабағын аяқтаған соң нақты нәтижелерге сүйеніп жоспарды жаңартамыз.',
            'There are not enough recorded mistakes to identify a weak area yet. Complete “$lesson” and we will update the plan from your results.'),
        sources: [progress],
        actionType: context.recommendedLessonId == null
            ? null
            : CoachActionType.startLesson,
        actionLabel: start,
        lessonId: context.recommendedLessonId,
      );
    }
    if (has([
      'review',
      'lesson',
      'weak',
      'today',
      'next',
      'progress',
      'қайтал',
      'сабақ',
      'әлсіз',
      'бүгін',
      'келесі',
      'деңгей',
      'жетістік'
    ])) {
      return CoachResponse(
        text: t(
            'Бүгін «$lesson» сабағынан баста. Одан кейін қате кеткен тапсырмаларды қайта орында. Күндік мақсат: ${context.todayProgress}/${context.dailyGoal}.',
            'Start with “$lesson” today, then retry the items you missed. Daily goal: ${context.todayProgress}/${context.dailyGoal}.'),
        sources: [progress],
        reasoning: why,
        dailyPlan: [
          CoachPlanItem(
              title: lesson,
              detail: t('${context.availableMinutes} минут',
                  '${context.availableMinutes} minutes'),
              lessonId: context.recommendedLessonId,
              isReview: context.dueReviewCount > 0)
        ],
        actionType: context.recommendedLessonId == null
            ? null
            : CoachActionType.startLesson,
        actionLabel: start,
        lessonId: context.recommendedLessonId,
      );
    }
    return CoachResponse(
        text: t(
            'Мен оқу жоспарын құруға, сабақты таңдауға және қайталауға көмектесе аламын. Қазір нені үйренгің келеді?',
            'I can help you plan your learning, choose a lesson and review what you have studied. What would you like to work on?'));
  }
}
