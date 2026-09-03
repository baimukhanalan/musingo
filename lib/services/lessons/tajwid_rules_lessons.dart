part of 'tajwid_lessons.dart';

const _tajwidRulesSpecs = <_TajwidSpec>[
  _TajwidSpec(
    title: 'Изхар',
    subtitle: 'Ясный нун и танвин',
    explanation:
        'Если после نْ или танвина идет одна из горловых букв ء ه ع ح غ خ, звук нун произносится ясно, без слияния со следующей буквой.',
    sample: _qadr3,
    listeningFocus: 'Ясный نْ перед أ в مِنْ أَلْفِ',
    listeningDistractors: ['Полное слияние ن', 'Замена ن на م'],
    question: 'Перед какой группой действует изхар нун сакина и танвина?',
    answer: 'ء ه ع ح غ خ',
    distractors: ['ي ن م و', 'ق ط ب ج د'],
    pairs: [
      LessonMatchPair(prompt: 'Изхар', answer: 'Ясное произнесение'),
      LessonMatchPair(prompt: 'نْ / танвин', answer: 'Объект правила'),
      LessonMatchPair(prompt: 'ءهعحغخ', answer: 'Горловые буквы')
    ],
  ),
  _TajwidSpec(
    title: 'Идгам с гунной',
    subtitle: 'Слияние перед ي ن م و',
    explanation:
        'Нун сакина или танвин сливается со следующей ي ن م و с гунной. Следи, чтобы переход был единым, а носовой звук — контролируемым.',
    sample: _falaq4,
    listeningFocus: 'Переход مِنْ شَرِّ как контраст к слиянию',
    listeningDistractors: ['Замена любого ن на م', 'Калькаля на ن'],
    question: 'Какие буквы вызывают идгам с гунной?',
    answer: 'ي ن م و',
    distractors: ['ل ر', 'ء ه ع ح غ خ'],
    pairs: [
      LessonMatchPair(prompt: 'ي ن م و', answer: 'Идгам с гунной'),
      LessonMatchPair(prompt: 'ل ر', answer: 'Идгам без гунны'),
      LessonMatchPair(prompt: 'Гунна', answer: 'Носовой переход')
    ],
  ),
  _TajwidSpec(
    title: 'Идгам без гунны',
    subtitle: 'Слияние перед ل и ر',
    explanation:
        'Перед ل или ر нун сакина и танвин сливаются без гунны. Важно не оставлять отдельный звук ن и не добавлять носовую задержку.',
    sample: _ikhlas2,
    listeningFocus: 'Четкая ل в اللَّهُ без лишнего носового звука',
    listeningDistractors: ['Долгая гунна перед ل', 'Калькаля на ل'],
    question: 'Какие две буквы вызывают идгам без гунны?',
    answer: 'ل и ر',
    distractors: ['م и ن', 'غ и خ'],
    pairs: [
      LessonMatchPair(prompt: 'ل', answer: 'Слияние без гунны'),
      LessonMatchPair(prompt: 'ر', answer: 'Слияние без гунны'),
      LessonMatchPair(prompt: 'Ошибка', answer: 'Сохранить отдельный ن')
    ],
  ),
  _TajwidSpec(
    title: 'Икляб',
    subtitle: 'Нун перед ب',
    explanation:
        'Перед ب нун сакина или танвин переходит в скрытый звук م с гунной. Губы готовятся к ب, но не создают два отдельных мим.',
    sample: _baqara27,
    listeningFocus: 'Икляб в مِنْ بَعْدِ перед ب',
    listeningDistractors: ['Ясный ن перед ب', 'Слияние без гунны'],
    question: 'Что происходит с نْ или танвином перед ب?',
    answer: 'Переход в скрытый م с гунной',
    distractors: [
      'Ясное произнесение ن без изменений',
      'Полное удаление звука без гунны'
    ],
    pairs: [
      LessonMatchPair(prompt: 'Икляб', answer: 'Переход к скрытому م'),
      LessonMatchPair(prompt: 'ب', answer: 'Условие икляба'),
      LessonMatchPair(prompt: 'Гунна', answer: 'Сохраняется')
    ],
  ),
  _TajwidSpec(
    title: 'Ихфа',
    subtitle: 'Скрытие перед 15 буквами',
    explanation:
        'Ихфа находится между ясным нун и полным слиянием. Оно действует перед ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك; положение языка готовится к следующей букве.',
    sample: _falaq2,
    listeningFocus: 'Скрытие نْ перед ش в مِنْ شَرِّ',
    listeningDistractors: ['Полностью ясный ن', 'Замена ن на долгую гласную'],
    question: 'Как описать ихфа точнее всего?',
    answer: 'Скрытие нун между ясным произнесением и слиянием с гунной',
    distractors: [
      'Полное удаление нун без следа',
      'Любое удлинение гласной перед буквой'
    ],
    pairs: [
      LessonMatchPair(prompt: 'Ихфа', answer: 'Скрытие с гунной'),
      LessonMatchPair(prompt: 'مِنْ شَرِّ', answer: 'نْ перед ش'),
      LessonMatchPair(prompt: '15 букв', answer: 'Условия ихфа')
    ],
  ),
  _TajwidSpec(
    title: 'Мим сакина',
    subtitle: 'Три губных правила',
    explanation:
        'Для مْ: перед ب действует ихфа шафави, перед م — идгам шафави, перед остальными буквами — изхар шафави. Во всех случаях контролируй губы и гунну.',
    sample: _fil4,
    listeningFocus: 'Ихфа шафави в هِمْ بِحِجَارَةٍ',
    listeningDistractors: ['Идгам без гунны перед ب', 'Калькаля на م'],
    question: 'Какое правило действует для مْ перед ب?',
    answer: 'Ихфа шафави',
    distractors: ['Идгам шафави', 'Изхар халки'],
    pairs: [
      LessonMatchPair(prompt: 'مْ + ب', answer: 'Ихфа шафави'),
      LessonMatchPair(prompt: 'مْ + م', answer: 'Идгам шафави'),
      LessonMatchPair(prompt: 'مْ + остальные', answer: 'Изхар шафави')
    ],
  ),
];
