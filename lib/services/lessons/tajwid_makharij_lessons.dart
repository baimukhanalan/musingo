part of 'tajwid_lessons.dart';

const _tajwidMakharijSpecs = <_TajwidSpec>[
  _TajwidSpec(
    title: 'Что такое таджвид',
    subtitle: 'Цель и границы курса',
    explanation:
        'Таджвид помогает читать Коран, сохраняя места выхода и качества букв. Muslingo дает учебную обратную связь, но не выдает ее за заключение квалифицированного учителя.',
    sample: _fatihah1,
    listeningFocus: 'Точное и спокойное произнесение каждой буквы',
    listeningDistractors: [
      'Максимальная скорость чтения',
      'Только громкость голоса'
    ],
    question: 'Что является главной практической целью таджвида?',
    answer: 'Сохранять правильное произношение букв и правила чтения',
    distractors: [
      'Читать любой текст как можно быстрее',
      'Заменить изучение смысла Корана'
    ],
    pairs: [
      LessonMatchPair(prompt: 'Таджвид', answer: 'Правильное чтение'),
      LessonMatchPair(prompt: 'Образец', answer: 'Сначала слушаем'),
      LessonMatchPair(prompt: 'Практика', answer: 'Затем повторяем')
    ],
  ),
  _TajwidSpec(
    title: 'Пять зон махраджа',
    subtitle: 'Карта речевого аппарата',
    explanation:
        'Пять общих зон образования звука: полость рта, горло, язык, губы и носовая полость. Конкретная буква требует более точного места внутри своей зоны.',
    sample: _fatihah2,
    listeningFocus: 'Переход звука между горлом, языком и губами',
    listeningDistractors: ['Число слов в переводе', 'Высота голоса чтеца'],
    question: 'Какая группа перечисляет пять общих зон махраджа?',
    answer: 'Полость рта, горло, язык, губы, носовая полость',
    distractors: [
      'Грудь, зубы, небо, язык, уши',
      'Горло, сердце, дыхание, нос, подбородок'
    ],
    pairs: [
      LessonMatchPair(prompt: 'Аль-джавф', answer: 'Полость рта'),
      LessonMatchPair(prompt: 'Аль-хальк', answer: 'Горло'),
      LessonMatchPair(prompt: 'Аш-шафатан', answer: 'Губы')
    ],
  ),
  _TajwidSpec(
    title: 'Полость рта и мадд',
    subtitle: 'Свободный длинный звук',
    explanation:
        'Из полости рта выходят буквы естественного удлинения ا و ي при подходящих огласовках. Воздух идет свободно, без полного перекрытия.',
    sample: _fil1,
    listeningFocus: 'Долгий звук в слове الْفِيلِ',
    listeningDistractors: ['Гунна в каждой букве', 'Калькаля на букве ف'],
    question: 'Какие буквы могут быть буквами мадда?',
    answer: 'ا و ي при соответствующих условиях',
    distractors: ['ق ط ب во всех положениях', 'ن م только с шаддой'],
    pairs: [
      LessonMatchPair(prompt: 'ا', answer: 'После фатхи'),
      LessonMatchPair(prompt: 'و', answer: 'После даммы'),
      LessonMatchPair(prompt: 'ي', answer: 'После касры')
    ],
  ),
  _TajwidSpec(
    title: 'Глубокая часть горла',
    subtitle: 'Буквы ء и ه',
    explanation:
        'Буквы ء и ه относят к самой глубокой части горла. Важно не превращать ه в сильный русский «х» и не терять четкость ء.',
    sample: _ikhlas1,
    listeningFocus: 'Четкое начало أَحَدٌ без замены звука',
    listeningDistractors: ['Удвоение буквы ل', 'Носовой звук на ر'],
    question: 'Какая пара относится к глубокой части горла?',
    answer: 'ء и ه',
    distractors: ['ع и ح', 'غ и خ'],
    pairs: [
      LessonMatchPair(prompt: 'ء', answer: 'Глубокая часть горла'),
      LessonMatchPair(prompt: 'ه', answer: 'Мягкий выдох из горла'),
      LessonMatchPair(prompt: 'خ', answer: 'Верхняя часть горла')
    ],
  ),
  _TajwidSpec(
    title: 'Средняя часть горла',
    subtitle: 'Буквы ع и ح',
    explanation:
        'ع и ح образуются в средней части горла. ع нельзя заменять обычной гласной, а ح требует чистого дыхательного звука без русского «х».',
    sample: _fatihah2,
    listeningFocus: 'Различие ع в الْعَالَمِينَ и ح в الْحَمْدُ',
    listeningDistractors: [
      'Одинаковое звучание ع и ح',
      'Калькаля на обеих буквах'
    ],
    question: 'Какие буквы образуются в средней части горла?',
    answer: 'ع и ح',
    distractors: ['ء и ه', 'غ и خ'],
    pairs: [
      LessonMatchPair(prompt: 'ع', answer: 'Не обычная гласная «а»'),
      LessonMatchPair(prompt: 'ح', answer: 'Чистый горловой выдох'),
      LessonMatchPair(prompt: 'Среднее горло', answer: 'Общая зона пары')
    ],
  ),
  _TajwidSpec(
    title: 'Верхняя часть горла',
    subtitle: 'Буквы غ и خ',
    explanation:
        'غ и خ выходят из верхней части горла, ближе ко рту. Звуки родственны по месту, но غ звонкий, а خ глухой.',
    sample: _falaq3,
    listeningFocus: 'Буква غ в слове غَاسِقٍ',
    listeningDistractors: ['Буква غ как обычная «г»', 'Полное исчезновение غ'],
    question: 'Как верно различить غ и خ?',
    answer: 'Они близки по месту, но غ звонкий, а خ глухой',
    distractors: ['Они полностью одинаковы', 'غ губная, а خ носовая'],
    pairs: [
      LessonMatchPair(prompt: 'غ', answer: 'Звонкий горловой звук'),
      LessonMatchPair(prompt: 'خ', answer: 'Глухой горловой звук'),
      LessonMatchPair(prompt: 'Обе', answer: 'Верхняя часть горла')
    ],
  ),
  _TajwidSpec(
    title: 'Губные буквы',
    subtitle: 'Буквы ب م و',
    explanation:
        'ب и م образуются смыканием губ; و без мадда произносится сближением округленных губ. Для م также важна носовая составляющая.',
    sample: _masad1,
    listeningFocus: 'Работа губ в تَبَّتْ и لَهَبٍ',
    listeningDistractors: [
      'Работа только середины языка',
      'Горловое произношение ب'
    ],
    question: 'Что объединяет ب, م и согласную و?',
    answer: 'Их произнесение связано с губами',
    distractors: [
      'Все они выходят из горла',
      'Все всегда произносятся с калькаля'
    ],
    pairs: [
      LessonMatchPair(prompt: 'ب', answer: 'Смыкание губ'),
      LessonMatchPair(prompt: 'م', answer: 'Смыкание губ и гунна'),
      LessonMatchPair(prompt: 'و', answer: 'Округление губ')
    ],
  ),
  _TajwidSpec(
    title: 'Буква ف',
    subtitle: 'Губа и верхние зубы',
    explanation:
        'ف образуется соприкосновением внутренней стороны нижней губы с краями верхних резцов. Не заменяй ее более твердым смычным звуком.',
    sample: _nasr1,
    listeningFocus: 'Чистая ف в слове الْفَتْحُ',
    listeningDistractors: [
      'Смыкание обеих губ как для ب',
      'Горловой звук вместо ف'
    ],
    question: 'Как образуется ف?',
    answer: 'Нижняя губа касается краев верхних резцов',
    distractors: [
      'Обе губы полностью смыкаются',
      'Корень языка касается мягкого неба'
    ],
    pairs: [
      LessonMatchPair(prompt: 'ف', answer: 'Нижняя губа + верхние резцы'),
      LessonMatchPair(prompt: 'ب', answer: 'Смыкание двух губ'),
      LessonMatchPair(prompt: 'ق', answer: 'Задняя часть языка')
    ],
  ),
  _TajwidSpec(
    title: 'Межзубные ث ذ ظ',
    subtitle: 'Кончик языка у резцов',
    explanation:
        'Для ث ذ ظ кончик языка приближается к краям верхних резцов или слегка выходит между зубами. Эти буквы нельзя сводить к س, ز или обычной «з».',
    sample: _zalzalah7,
    listeningFocus: 'Межзубная ذ в слове ذَرَّةٍ',
    listeningDistractors: ['Буква ذ как ز', 'Полное смыкание губ'],
    question: 'Что важно для ث ذ ظ?',
    answer: 'Положение кончика языка у верхних резцов',
    distractors: ['Смыкание двух губ', 'Только носовой резонанс'],
    pairs: [
      LessonMatchPair(prompt: 'ث', answer: 'Глухая межзубная'),
      LessonMatchPair(prompt: 'ذ', answer: 'Звонкая межзубная'),
      LessonMatchPair(prompt: 'ظ', answer: 'Твердая межзубная')
    ],
  ),
  _TajwidSpec(
    title: 'Буквы ت د ط',
    subtitle: 'Кончик языка и десны',
    explanation:
        'ت د ط имеют близкое место выхода у основания верхних резцов, но различаются качествами. ط произносится твердо, ت — с выдохом, د — звонко.',
    sample: _fatihah6,
    listeningFocus: 'Твердая ط в слове الصِّرَاطَ',
    listeningDistractors: ['Мягкая замена ط на ت', 'Гунна на букве ط'],
    question: 'Почему ت, د и ط нельзя считать одним звуком?',
    answer: 'При близком месте выхода у них разные качества',
    distractors: ['Они выходят из разных губ', 'Только одна из них арабская'],
    pairs: [
      LessonMatchPair(prompt: 'ت', answer: 'Глухая с выдохом'),
      LessonMatchPair(prompt: 'د', answer: 'Звонкая'),
      LessonMatchPair(prompt: 'ط', answer: 'Твердая')
    ],
  ),
  _TajwidSpec(
    title: 'Свистящие ز س ص',
    subtitle: 'Тонкая и твердая буквы',
    explanation:
        'ز س ص сопровождаются направленной струей воздуха и свистящим оттенком. ص отличается твердостью; س остается тонкой, ز — звонкая.',
    sample: _asr1,
    listeningFocus: 'Твердая ص в слове الْعَصْرِ',
    listeningDistractors: ['Замена ص на س', 'Носовой звук на ص'],
    question: 'Какая из букв ز س ص является твердой?',
    answer: 'ص',
    distractors: ['س', 'ز'],
    pairs: [
      LessonMatchPair(prompt: 'ز', answer: 'Звонкая'),
      LessonMatchPair(prompt: 'س', answer: 'Тонкая глухая'),
      LessonMatchPair(prompt: 'ص', answer: 'Твердая глухая')
    ],
  ),
  _TajwidSpec(
    title: 'Середина языка',
    subtitle: 'Буквы ج ش ي',
    explanation:
        'Согласные ج ش и ي образуются средней частью языка напротив твердого неба. Не смешивай согласную ي с буквой мадда.',
    sample: _fil4,
    listeningFocus: 'Буква ج в слове بِحِجَارَةٍ',
    listeningDistractors: ['Горловое произношение ج', 'Смыкание губ на ج'],
    question: 'Какая группа связана с серединой языка?',
    answer: 'ج ش ي',
    distractors: ['ق ك غ', 'ب م و'],
    pairs: [
      LessonMatchPair(prompt: 'ج', answer: 'Середина языка'),
      LessonMatchPair(prompt: 'ش', answer: 'Середина языка'),
      LessonMatchPair(prompt: 'ي согласная', answer: 'Середина языка')
    ],
  ),
  _TajwidSpec(
    title: 'Бок языка: ض и ل',
    subtitle: 'Разные участки края языка',
    explanation:
        'ض выходит с боковой стороны языка у верхних коренных зубов. ل образуется ближе к переднему краю языка и верхним деснам.',
    sample: _fatihah2,
    listeningFocus: 'Четкая ل без замены на другой звук',
    listeningDistractors: [
      'Одинаковый махрадж ض и ل',
      'Произнесение обеих губами'
    ],
    question: 'Какое утверждение точнее?',
    answer: 'ض и ل используют бок языка, но разные его участки',
    distractors: [
      'ض и ل имеют полностью одинаковый махрадж',
      'Обе буквы образуются только в горле'
    ],
    pairs: [
      LessonMatchPair(prompt: 'ض', answer: 'Бок языка у коренных зубов'),
      LessonMatchPair(prompt: 'ل', answer: 'Передний край языка у десен'),
      LessonMatchPair(prompt: 'Общее', answer: 'Участие края языка')
    ],
  ),
  _TajwidSpec(
    title: 'Задняя часть языка',
    subtitle: 'Буквы ق и ك',
    explanation:
        'ق образуется глубже задней частью языка и произносится твердо. ك выходит немного ближе ко рту и остается тонкой.',
    sample: _falaq1,
    listeningFocus: 'Твердая ق в конце الْفَلَقِ',
    listeningDistractors: ['Замена ق на ك', 'Произнесение ق губами'],
    question: 'Чем в базовой практике отличается ق от ك?',
    answer: 'ق глубже и тверже, ك ближе ко рту и тоньше',
    distractors: ['ك глубже и тверже ق', 'Различия между ними нет'],
    pairs: [
      LessonMatchPair(prompt: 'ق', answer: 'Глубже и тверже'),
      LessonMatchPair(prompt: 'ك', answer: 'Ближе и тоньше'),
      LessonMatchPair(prompt: 'Обе', answer: 'Задняя часть языка')
    ],
  ),
  _TajwidSpec(
    title: 'Кончик языка: ل ن ر',
    subtitle: 'Три близких махраджа',
    explanation:
        'ل, ن и ر формируются у передней части языка и верхних десен, но не в одной точке. ر требует контролируемого касания без лишней многократной вибрации.',
    sample: _nas1,
    listeningFocus: 'Различие ر и ن в بِرَبِّ النَّاسِ',
    listeningDistractors: [
      'Слияние ر и ن в один звук',
      'Горловое произношение обеих'
    ],
    question: 'Что опасно при произнесении ر?',
    answer: 'Лишняя многократная вибрация языка',
    distractors: [
      'Любое касание языка к деснам',
      'Округление губ перед звуком'
    ],
    pairs: [
      LessonMatchPair(prompt: 'ل', answer: 'Передний край языка'),
      LessonMatchPair(prompt: 'ن', answer: 'Кончик языка + гунна'),
      LessonMatchPair(prompt: 'ر', answer: 'Контролируемое касание')
    ],
  ),
  _TajwidSpec(
    title: 'Контроль махраджей',
    subtitle: 'Сравнение близких букв',
    explanation:
        'Проверь цепочку: определи зону, найди точное место, добавь качества и сравни с образцом. Ошибка в одном этапе может превратить букву в другую.',
    sample: _falaq3,
    listeningFocus: 'Различие غ, ق и ب в одном аяте',
    listeningDistractors: ['Только число слогов', 'Только громкость окончания'],
    question: 'Какой порядок самопроверки наиболее надежен?',
    answer: 'Зона → точное место → качества → сравнение с образцом',
    distractors: [
      'Скорость → громкость → перевод',
      'Название буквы → запоминание без слуха'
    ],
    pairs: [
      LessonMatchPair(prompt: '1', answer: 'Определи зону'),
      LessonMatchPair(prompt: '2', answer: 'Уточни место и качества'),
      LessonMatchPair(prompt: '3', answer: 'Сравни с образцом')
    ],
  ),
];
