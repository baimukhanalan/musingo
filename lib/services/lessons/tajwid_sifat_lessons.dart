part of 'tajwid_lessons.dart';

const _tajwidSifatSpecs = <_TajwidSpec>[
  _TajwidSpec(
    title: 'Хамс и джахр',
    subtitle: 'Выдох и удержание дыхания',
    explanation:
        'При хамсе заметно проходит воздух; буквы хамса: ف ح ث ه ش خ ص س ك ت. У остальных букв преобладает джахр — поток дыхания удерживается сильнее.',
    sample: _falaq1,
    listeningFocus: 'Выдох на ف и ح без потери четкости',
    listeningDistractors: ['Гунна на каждой букве', 'Удлинение всех гласных'],
    question: 'Какая буква входит в группу хамса?',
    answer: 'ف',
    distractors: ['ب', 'د'],
    pairs: [
      LessonMatchPair(prompt: 'Хамс', answer: 'Прохождение воздуха'),
      LessonMatchPair(prompt: 'Джахр', answer: 'Удержание воздуха'),
      LessonMatchPair(prompt: 'فحثهشخصسكت', answer: 'Буквы хамса')
    ],
  ),
  _TajwidSpec(
    title: 'Сила потока звука',
    subtitle: 'Шидда, тавассут, рихва',
    explanation:
        'Шидда полностью задерживает поток звука, рихва позволяет ему продолжаться, а тавассут занимает среднее положение. Качество слышно особенно ясно на букве с сукуном.',
    sample: _masad1,
    listeningFocus: 'Краткая задержка и отзвук на بْ',
    listeningDistractors: ['Постоянное удлинение ب', 'Носовой звук вместо ب'],
    question:
        'Что находится между полной задержкой и свободным течением звука?',
    answer: 'Тавассут',
    distractors: ['Шидда', 'Рихва'],
    pairs: [
      LessonMatchPair(prompt: 'Шидда', answer: 'Поток задержан'),
      LessonMatchPair(prompt: 'Тавассут', answer: 'Среднее положение'),
      LessonMatchPair(prompt: 'Рихва', answer: 'Поток продолжается')
    ],
  ),
  _TajwidSpec(
    title: 'Твердые буквы',
    subtitle: 'Истиаля и истифаль',
    explanation:
        'При истиаля задняя часть языка поднимается, создавая твердое звучание. Буквы истиаля: خ ص ض غ ط ق ظ. Остальные в основе относятся к истифаль.',
    sample: _fatihah6,
    listeningFocus: 'Твердость ص и ط в الصِّرَاطَ',
    listeningDistractors: ['Смягчение ص и ط', 'Гунна на обеих буквах'],
    question: 'Какая группа содержит только буквы истиаля?',
    answer: 'خ ص ض غ ط ق ظ',
    distractors: ['ف ح ث ه ش', 'ب م و ي ن'],
    pairs: [
      LessonMatchPair(
          prompt: 'Истиаля', answer: 'Задняя часть языка поднимается'),
      LessonMatchPair(prompt: 'Истифаль', answer: 'Основа тонкого звучания'),
      LessonMatchPair(prompt: 'خصضغطقظ', answer: 'Семь твердых букв')
    ],
  ),
  _TajwidSpec(
    title: 'Калькаля',
    subtitle: 'Отзвук ق ط ب ج د',
    explanation:
        'Калькаля — слышимый отскок звука у ق ط ب ج د, когда буква находится в состоянии сукуна. Не добавляй полноценную гласную после буквы.',
    sample: _falaq1,
    listeningFocus: 'Отзвук قْ при остановке на الْفَلَقِ',
    listeningDistractors: ['Добавление слога «ка»', 'Полное исчезновение ق'],
    question: 'Когда проявляется калькаля?',
    answer: 'Когда одна из ق ط ب ج د находится с сукуном',
    distractors: ['На любой букве с фатхой', 'Только на ن и م с шаддой'],
    pairs: [
      LessonMatchPair(prompt: 'قطبجد', answer: 'Буквы калькаля'),
      LessonMatchPair(prompt: 'Сукун', answer: 'Условие отзвука'),
      LessonMatchPair(prompt: 'Ошибка', answer: 'Добавленная гласная')
    ],
  ),
  _TajwidSpec(
    title: 'Гунна',
    subtitle: 'Носовой резонанс ن и م',
    explanation:
        'Гунна — носовой резонанс, связанный с ن и م. Особенно отчетливо он звучит при нун и мим с шаддой; длительность отсчитывают ровно, без затягивания.',
    sample: _qadr1,
    listeningFocus: 'Гунна в начале إِنَّا',
    listeningDistractors: [
      'Калькаля на ن',
      'Полное отсутствие носового резонанса'
    ],
    question: 'С какими буквами связана гунна?',
    answer: 'ن и م',
    distractors: ['ق и ط', 'ل и ر'],
    pairs: [
      LessonMatchPair(prompt: 'Гунна', answer: 'Носовой резонанс'),
      LessonMatchPair(prompt: 'نّ', answer: 'Явная гунна'),
      LessonMatchPair(prompt: 'مّ', answer: 'Явная гунна')
    ],
  ),
];
