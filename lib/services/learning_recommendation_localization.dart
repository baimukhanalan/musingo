/// Authored onboarding recommendations can have been saved in any app language.
/// Match only known exact values; imported/custom recommendations stay intact.
class LearningRecommendationLocalization {
  static String? localize(String? source, String locale) {
    if (source == null) return null;
    final index = locale == 'kk'
        ? 1
        : locale == 'en'
            ? 2
            : 0;
    for (final variants in _recommendations) {
      if (variants.contains(source)) return variants[index];
    }
    return source;
  }

  static const _recommendations = [
    [
      'Начни с арабских букв и их звучания. Первый урок поможет увидеть различия и сразу потренировать слух.',
      'Араб әріптері мен олардың дыбысталуынан баста. Бірінші сабақ айырмашылықтарды көруге және есту қабілетін бірден жаттықтыруға көмектеседі.',
      'Start with the Arabic letters and their sounds. The first lesson helps you see the differences and train your ear right away.',
    ],
    [
      'Ты узнаёшь буквы. Начни со сборки слогов и чтения коротких сочетаний, не повторяя весь алфавит с нуля.',
      'Әріптерді танисың. Әліпбиді қайта бастамай, буындар мен қысқа тіркестерді оқудан баста.',
      'You recognize the letters. Start with syllables and short combinations instead of repeating the whole alphabet.',
    ],
    [
      'У тебя уверенная база. Пропускаем алфавит: начнем с коранических слов и чтения аятов.',
      'Негізің сенімді. Әліпбиді өткізіп, Құран сөздері мен аяттарды оқудан бастаймыз.',
      'You have a strong foundation. We will skip the alphabet and begin with Quranic words and verse reading.',
    ],
    [
      'Базовое чтение уже есть. Маршрут начнётся с огласовок, сложных букв и коранических слов.',
      'Негізгі оқу қалыптасқан. Бағыт харакаттардан, күрделі әріптерден және Құран сөздерінен басталады.',
      'Your basic reading is in place. The path will start with vowel marks, difficult letters, and Quranic words.',
    ],
    [
      'Начни с короткого вводного урока об исламе и Коране. После него маршрут добавит вопросы на понимание.',
      'Ислам мен Құран туралы қысқа кіріспе сабақтан баста. Одан кейін маршрут түсінуге арналған сұрақтар қосады.',
      'Start with a short introductory lesson about Islam and the Quran. After it, the path will add comprehension questions.',
    ],
    [
      'Сначала укрепим произношение знакомых фраз: образец, повторение и разбор вероятных ошибок.',
      'Алдымен таныс сөз тіркестерінің айтылуын бекітеміз: үлгі, қайталау және ықтимал қателерді талдау.',
      "First we'll strengthen the pronunciation of familiar phrases: a model, repetition and a review of likely mistakes.",
    ],
    [
      'Начни с Аль-Фатихи: разберем смысл по частям и свяжем перевод с арабскими словами.',
      'Әл-Фатихадан баста: мағынасын бөліктеп талдап, аударманы араб сөздерімен байланыстырамыз.',
      "Start with Al-Fatiha: we'll break down the meaning part by part and link the translation to the Arabic words.",
    ],
    [
      'Тебе подходит маршрут по коротким сурам. Начнем с Аль-Фатихи и будем добавлять новые аяты постепенно.',
      'Саған қысқа сүрелер бойынша маршрут сәйкес келеді. Әл-Фатихадан бастап, жаңа аяттарды біртіндеп қосамыз.',
      "A path through short surahs suits you. We'll start with Al-Fatiha and add new verses gradually.",
    ],
  ];
}
