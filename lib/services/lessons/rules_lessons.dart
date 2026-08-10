import '../../models/lesson.dart';

final List<Lesson> rulesLessons = [
    const Lesson(
      id: 'r1',
      title: 'Вера и намерение',
      subtitle: 'С чего начинается обучение',
      course: CourseType.rules,
      order: 1,
      status: LessonStatus.available,
      sourceUrl: 'https://quran.com/98/5',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          explanation: 'Базовый урок перед сурами.',
          russianText: 'В исламе важны вера, искренность и намерение. '
              'Перед изучением Корана ученик вспоминает, что цель обучения — '
              'понимать смысл, исправлять чтение и применять знание спокойно.',
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'بِسْمِ اللَّهِ',
          transliteration: 'Бисмиллях',
          speechMode: SpeechMode.phrase,
          russianText: 'Произнеси короткую фразу перед началом.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой настрой, по уроку, помогает начать обучение правильно?',
          answers: [
            'Искреннее намерение (ният) и спокойная цель',
            'Стремление получить похвалу окружающих',
            'Желание закончить урок раньше других'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: '«Бисмиллях» (بِسْمِ اللَّهِ) переводится как «С именем ___». '
              'Какое слово пропущено?',
          answers: ['Аллаха', 'Пророка', 'Корана'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какую цель обучения описывает этот урок?',
          answers: [
            'Понимать смысл, исправлять чтение и спокойно применять знание',
            'Запомнить как можно больше слов за один день',
            'Пройти все уроки раньше остальных учеников'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая тройка понятий, по уроку, важна в исламе при обучении?',
          answers: [
            'Вера, искренность и намерение',
            'Вера, скорость и соперничество',
            'Искренность, спор и настойчивость'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r2',
      title: 'Что такое Коран',
      subtitle: 'Писание, чтение и уважение',
      course: CourseType.rules,
      order: 2,
      sourceUrl: 'https://quran.com/2/2',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          explanation: 'Короткая рамка перед чтением сур.',
          russianText: 'Коран для мусульман — речь Аллаха и руководство. '
              'В Muslingo ученик сначала слушает, затем читает, понимает '
              'перевод и только после этого проверяет себя.',
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь действие и цель',
          matchPairs: [
            LessonMatchPair(prompt: 'Слушать', answer: 'Уловить произношение'),
            LessonMatchPair(prompt: 'Понимать', answer: 'Связать текст со смыслом'),
            LessonMatchPair(prompt: 'Повторять', answer: 'Закрепить чтение'),
          ],
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 9,
          arabicText:
              'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
          transliteration:
              'Залика-ль-китабу ля райба фихи, худан лиль-муттакын',
          russianText: 'Это Писание, в котором нет сомнения...',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем, по уроку, является Коран для мусульман?',
          answers: [
            'Речью (словом) Аллаха и руководством',
            'Сборником рассказов о прошлых народах',
            'Собранием стихов арабских поэтов'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'В аяте 2:2 сказано: «Это Писание, в котором нет ___». '
              'Какое слово завершает мысль?',
          answers: ['сомнения', 'пользы', 'красоты'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Аят 2:2 называет Коран «худан лиль-муттакын». Что это значит?',
          answers: [
            'Руководство (худа) для богобоязненных',
            'Напоминание для забывчивых',
            'Испытание для сомневающихся'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой порядок обучения в Muslingo надёжнее?',
          answers: [
            'Сначала слушать и понимать, затем повторять и проверять себя',
            'Сначала проверять себя, а слушать в самом конце',
            'Повторять вслух, не слушая образец чтения'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r3',
      title: 'Пророк Мухаммад',
      subtitle: 'Пример мягкости и обучения',
      course: CourseType.rules,
      order: 3,
      sourceUrl: 'https://quran.com/33/21',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Мусульмане учатся Корану вместе с примером Пророка '
              'Мухаммада, мир ему. Этот урок напоминает: знание должно делать '
              'человека внимательнее, мягче и ответственнее.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что, по уроку, должно сопровождать знание?',
          answers: [
            'Хороший нрав и ответственность',
            'Гордость своими познаниями',
            'Желание превзойти других в спорах'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
          transliteration: 'Аллахумма салли аля Мухаммад',
          speechMode: SpeechMode.phrase,
          russianText: 'Повтори короткую формулу салавата.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Салават «Аллахумма салли аля Мухаммад» — это просьба к '
              'Аллаху о ___ для Пророка. Что пропущено?',
          answers: [
            'благословении',
            'прощении грехов ученика',
            'увеличении богатства'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Каким, по уроку, должно делать человека настоящее знание?',
          answers: [
            'Внимательнее, мягче и ответственнее',
            'Строже и высокомернее к другим',
            'Настойчивее в спорах о мелочах'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'С чьим примером, по уроку, мусульмане учатся Корану?',
          answers: [
            'С примером Пророка Мухаммада, мир ему',
            'С примером сподвижников вместо самого Пророка',
            'С примером известных поэтов своего времени'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r4',
      title: 'Молитва',
      subtitle: 'Связь с Аллахом',
      course: CourseType.rules,
      order: 4,
      sourceUrl: 'https://quran.com/4/103',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Намаз — центральная практика мусульманина. Вводный '
              'урок не заменяет обучение у учителя, но помогает понять: '
              'Коран и короткие суры часто нужны именно в молитве.',
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'اللَّهُ أَكْبَرُ',
          transliteration: 'Аллаху Акбар',
          speechMode: SpeechMode.phrase,
          russianText: 'Произнеси фразу спокойно и четко.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Намаз начинается с такбира «Аллаху ___». Какое слово верное?',
          answers: ['Акбар', 'Кабир', 'Акрам'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Зачем Muslingo помогает выучить короткие суры?',
          answers: [
            'Чтобы понимать их и читать в поклонении',
            'Чтобы проговаривать их как можно быстрее',
            'Чтобы заменить намаз прохождением тестов'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая практика, по уроку, названа центральной для мусульманина?',
          answers: ['Намаз', 'Пост в Рамадан', 'Паломничество (хадж)'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что этот вводный урок, по его словам, НЕ заменяет?',
          answers: [
            'Обучение у учителя',
            'Прослушивание аудио в приложении',
            'Чтение перевода на экране'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r5',
      title: 'Чистота и адаб',
      subtitle: 'Перед чтением и учебой',
      course: CourseType.rules,
      order: 5,
      sourceUrl: 'https://quran.com/56/79',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Адаб — это уважительное поведение. Перед чтением '
              'Корана важно выбрать спокойное место, не торопиться, слушать '
              'внимательно и относиться к тексту с уважением.',
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь понятие и его краткий смысл',
          matchPairs: [
            LessonMatchPair(prompt: 'Тахара', answer: 'Чистота тела и места'),
            LessonMatchPair(prompt: 'Адаб', answer: 'Уважительное поведение'),
            LessonMatchPair(
                prompt: 'Хушу', answer: 'Смирение и сосредоточенность'),
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что означает слово «адаб»?',
          answers: [
            'Уважительное поведение и вежливость',
            'Название одной из сур Корана',
            'Разновидность арабского почерка'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой набор действий полностью соответствует адабу перед '
              'чтением Корана?',
          answers: [
            'Спокойное место, неспешность и внимательность',
            'Спешка, шум и одновременные разговоры',
            'Громкий спор о том, чей перевод точнее'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Аят 56:79 напоминает, что к Корану прикасается только '
              'очистившийся. С каким понятием это прямо связано?',
          answers: [
            'Тахара (чистота)',
            'Закят (милостыня)',
            'Хадж (паломничество)'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r6',
      title: 'Как понимать перевод',
      subtitle: 'Смысл без самовольных выводов',
      course: CourseType.rules,
      order: 6,
      sourceUrl: 'https://quran.com/16/43',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Перевод помогает понять общий смысл, но не заменяет '
              'арабский текст и объяснение ученых. В приложении перевод нужен '
              'для обучения, а сложные вопросы следует уточнять у знающих.',
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь источник и его роль в обучении',
          matchPairs: [
            LessonMatchPair(prompt: 'Перевод', answer: 'Помогает понять смысл'),
            LessonMatchPair(prompt: 'Арабский текст', answer: 'Оригинал речи'),
            LessonMatchPair(prompt: 'Учёные', answer: 'Объясняют сложные места'),
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что важнее всего помнить о переводе Корана?',
          answers: [
            'Он помогает понять смысл, но не заменяет арабский текст',
            'Он полностью равен оригиналу во всех деталях',
            'Он делает изучение арабского ненужным'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Урок опирается на смысл аята 16:43: «спросите ___, если не '
              'знаете». Кого имеется в виду?',
          answers: [
            'Людей знания (учёных)',
            'Старших в своей семье',
            'Большинство окружающих людей'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как правильно поступать со сложными вопросами по смыслу '
              'аятов?',
          answers: [
            'Уточнять у знающих людей',
            'Решать их в громком споре',
            'Делать выводы самому наугад'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Для чего, по уроку, в приложении нужен перевод?',
          answers: [
            'Для обучения и понимания смысла',
            'Чтобы полностью заменить учителя',
            'Чтобы выигрывать споры о религии'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r7',
      title: 'Как учить суры',
      subtitle: 'Слушай, понимай, повторяй',
      course: CourseType.rules,
      order: 7,
      sourceUrl: 'https://quran.com/73/4',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Лучший порядок для новичка: прослушать всю суру, '
              'разобрать короткий фрагмент, понять перевод, повторить вслух '
              'и вернуться к ошибкам. Так построены уроки Muslingo.',
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Собери логику закрепления',
          matchPairs: [
            LessonMatchPair(prompt: 'Ошибка', answer: 'Вернуться к шагу'),
            LessonMatchPair(prompt: 'Образец', answer: 'Сначала прослушать'),
            LessonMatchPair(prompt: 'Голос', answer: 'Проверить после записи'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'الْحَمْدُ لِلَّهِ',
          transliteration: 'Аль-хамду лиллях',
          speechMode: SpeechMode.phrase,
          russianText: 'Повтори фразу благодарности.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: '«Аль-хамду лиллях» переводится как «___ Аллаху». Какое '
              'слово пропущено?',
          answers: ['Хвала', 'Пречист', 'Велик'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой порядок изучения суры описывает урок?',
          answers: [
            'Слушать, понять смысл, повторить и исправить ошибки',
            'Быстро прочитать текст и сразу перейти к следующей суре',
            'Пройти тест один раз без прослушивания и повторения'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что, по уроку, стоит делать сразу после ошибки при '
              'заучивании?',
          answers: [
            'Вернуться к нужному шагу и повторить',
            'Пропустить суру и идти дальше',
            'Ускориться, чтобы наверстать время'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r8',
      title: 'Шесть столпов веры',
      subtitle: 'Основы имана',
      course: CourseType.rules,
      order: 8,
      xpReward: 25,
      sourceUrl: 'https://quran.com/2/285',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          explanation: 'Общепризнанные основы веры (иман).',
          russianText: 'Иман — это вера сердцем. По широко признанному учению '
              'у веры шесть основ: вера в Аллаха, в Его ангелов, в Его Писания, '
              'в Его посланников, в Судный день и в предопределение (то, что всё '
              'происходит по знанию и воле Аллаха). Этот урок только знакомит '
              'с названиями, а подробности лучше изучать у знающих.',
          sourceRefs: ['Коран 2:285', 'Хадис Джибриля (Сахих Муслим, 8)'],
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'آمَنْتُ بِاللَّهِ',
          transliteration: 'Аманту билляхи',
          speechMode: SpeechMode.phrase,
          russianText: 'Произнеси фразу «Я уверовал в Аллаха».',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Сколько основ у веры (имана) по этому уроку?',
          answers: ['Пять', 'Шесть', 'Семь'],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь основу веры и её краткий смысл',
          matchPairs: [
            LessonMatchPair(
                prompt: 'Вера в Аллаха',
                answer: 'Единый Творец и Господь всего'),
            LessonMatchPair(
                prompt: 'Вера в Писания',
                answer: 'Ниспосланные книги, среди них Коран'),
            LessonMatchPair(
                prompt: 'Вера в Судный день',
                answer: 'День воскрешения и отчёта'),
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что из перечисленного относится к основам веры (имана)?',
          answers: [
            'Вера в ангелов и в Судный день',
            'Вера в святость определённых мест',
            'Вера в силу талисманов и амулетов'
          ],
          correctAnswerIndex: 0,
          sourceRefs: ['Коран 2:285'],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что из перечисленного НЕ входит в шесть основ имана, '
              'а относится к столпам ислама?',
          answers: [
            'Вера в предопределение',
            'Вера в посланников',
            'Обязательный пост в Рамадан'
          ],
          correctAnswerIndex: 2,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: '«Аманту билляхи» означает «Я ___ в Аллаха». Какое слово '
              'верное?',
          answers: ['уверовал', 'нуждаюсь', 'взываю'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что означает вера в предопределение по уроку?',
          answers: [
            'Что всё происходит по знанию и воле Аллаха',
            'Что человек не отвечает за свои поступки',
            'Что будущее можно точно предсказать заранее'
          ],
          correctAnswerIndex: 0,
          sourceRefs: ['Хадис Джибриля (Сахих Муслим, 8)'],
        ),
      ],
    ),
    const Lesson(
      id: 'r9',
      title: 'Пять столпов ислама',
      subtitle: 'Названия основ поклонения',
      course: CourseType.rules,
      order: 9,
      xpReward: 25,
      sourceUrl: 'https://sunnah.com/bukhari:8',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          explanation: 'Общий обзор названий, без деталей фикха.',
          russianText: 'По известному хадису ислам строится на пяти основах: '
              'шахада (свидетельство веры), намаз (молитва), закят '
              '(обязательная милостыня), пост в месяц Рамадан и хадж '
              '(паломничество для того, кто способен). Урок знакомит только '
              'с названиями; как их выполнять, изучают отдельно и у учителя.',
          sourceRefs: ['Сахих аль-Бухари, 8', 'Сахих Муслим, 16'],
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
          transliteration: 'Ля иляха илля Ллах',
          speechMode: SpeechMode.phrase,
          russianText: 'Произнеси свидетельство «Нет божества, кроме Аллаха».',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Сколько столпов у ислама по этому уроку?',
          answers: ['Три', 'Четыре', 'Пять'],
          correctAnswerIndex: 2,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь столп ислама и его краткое значение',
          matchPairs: [
            LessonMatchPair(
                prompt: 'Шахада', answer: 'Свидетельство веры'),
            LessonMatchPair(
                prompt: 'Закят', answer: 'Обязательная милостыня'),
            LessonMatchPair(
                prompt: 'Хадж', answer: 'Паломничество для способного'),
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: '«Ля иляха илля Ллах» означает «Нет ___, кроме Аллаха». '
              'Какое слово пропущено?',
          answers: ['божества', 'пророка', 'творения'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'В какой месяц соблюдается пост из числа столпов?',
          answers: ['В Рамадан', 'В любой месяц по выбору', 'Только зимой'],
          correctAnswerIndex: 0,
          sourceRefs: ['Коран 2:185'],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что из перечисленного относится к столпам ислама, а не '
              'к основам веры (имана)?',
          answers: [
            'Закят (обязательная милостыня)',
            'Вера в ангелов',
            'Вера в Судный день'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что из перечисленного действительно является столпом ислама?',
          answers: [
            'Намаз (молитва)',
            'Заучивание всего Корана наизусть',
            'Ежедневное посещение мечети'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r10',
      title: 'Короткие азкары',
      subtitle: 'Поминание Аллаха с переводом',
      course: CourseType.rules,
      order: 10,
      xpReward: 25,
      sourceUrl: 'https://sunnah.com/bukhari:6405',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          explanation: 'Простые общеизвестные слова поминания.',
          russianText: 'Азкар — это поминание Аллаха короткими словами. '
              'Самые известные: «СубханАллах» (Пречист Аллах), «Альхамдулиллях» '
              '(Хвала Аллаху), «Аллаху Акбар» (Аллах Велик) и «Ля иляха илля '
              'Ллах» (Нет божества, кроме Аллаха). Их легко повторять в течение '
              'дня; это мягкая и любимая многими практика.',
          sourceRefs: ['Сахих аль-Бухари, 6405', 'Сахих Муслим, 2694'],
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини поминание и его перевод',
          matchPairs: [
            LessonMatchPair(
                prompt: 'СубханАллах', answer: 'Пречист Аллах'),
            LessonMatchPair(
                prompt: 'Аллаху Акбар', answer: 'Аллах Велик'),
            LessonMatchPair(
                prompt: 'Ля иляха илля Ллах',
                answer: 'Нет божества, кроме Аллаха'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'سُبْحَانَ اللَّهِ',
          transliteration: 'СубханАллах',
          speechMode: SpeechMode.phrase,
          russianText: 'Произнеси «Пречист Аллах» спокойно и внятно.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «Альхамдулиллях»?',
          answers: [
            'Хвала Аллаху',
            'Пречист Аллах',
            'Аллах Велик'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: '«___ Аллах» означает «Пречист Аллах». Какое слово пропущено?',
          answers: ['Субхан', 'Хамду', 'Акбар'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какое поминание переводится как «Нет божества, кроме Аллаха»?',
          answers: [
            'Ля иляха илля Ллах',
            'СубханАллах',
            'Альхамдулиллях'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что такое азкар?',
          answers: [
            'Поминание Аллаха короткими словами',
            'Правила чтения нараспев (таджвид)',
            'Дополнительная ночная молитва'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «Аллаху Акбар»?',
          answers: ['Аллах Велик', 'Хвала Аллаху', 'Пречист Аллах'],
          correctAnswerIndex: 0,
        ),
      ],
    ),
];
