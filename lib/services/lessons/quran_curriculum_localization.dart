/// Controlled reading-path UI templates only. Never translates Arabic, source
/// references, verse addresses or claims that a generated text is tafsir.
String? localizeQuranCurriculumText(String source, String locale) {
  if (locale == 'ar') return _arabic(source);
  if (locale != 'kk' && locale != 'en') return null;
  final kk = locale == 'kk';
  final title = RegExp(r'^Коран (\d+:\d+(?:–\d+)?)$').firstMatch(source);
  if (title != null) return '${kk ? 'Құран' : 'Quran'} ${title[1]}';
  final subtitle =
      RegExp(r'^Чтение и слушание · ≈(\d+) мин$').firstMatch(source);
  if (subtitle != null) {
    return kk
        ? 'Оқу және тыңдау · ≈${subtitle[1]} мин'
        : 'Read and listen · ≈${subtitle[1]} min';
  }
  final audio = RegExp(r'^Коран (\d+:\d+) · слушай и следи за текстом$')
      .firstMatch(source);
  if (audio != null) {
    return kk
        ? 'Құран ${audio[1]} · тыңдап, мәтінге қарап отыр'
        : 'Quran ${audio[1]} · listen and follow the text';
  }
  final order =
      RegExp(r'^Восстанови начало аята (\d+:\d+)$').firstMatch(source);
  if (order != null) {
    return kk
        ? '${order[1]} аятының басын ретімен құрастыр'
        : 'Rebuild the opening of verse ${order[1]}';
  }
  final recall = RegExp(r'^Каким словом заканчивается аят (\d+:\d+)\?$')
      .firstMatch(source);
  if (recall != null) {
    return kk
        ? '${recall[1]} аяты қай сөзбен аяқталады?'
        : 'Which word ends verse ${recall[1]}?';
  }
  final intro =
      RegExp(r'^Аяты (\d+:\d+(?:–\d+)?). .*Ориентир — (\d+) мин;', dotAll: true)
          .firstMatch(source);
  if (intro != null) {
    return kk
        ? '${intro[1]} аяттары. Жазбаны тыңдап, арабша мәтінге қарап отыр, '
            'содан кейін өз қарқыныңмен қайтала. Бұл — оқу жаттығуы, аударма '
            'немесе тәпсір емес. Шамамен ${intro[2]} мин; қосымша қайталауға '
            'көбірек уақыт қажет.\n\n'
            'Арабша мәтін: Tanzil Project (CC BY 3.0), https://tanzil.net.'
        : 'Verses ${intro[1]}. Listen to the recording and follow the Arabic '
            'text, then repeat at your own pace. This is reading practice, '
            'not translation or tafsir. About ${intro[2]} min; additional '
            'replays take longer.\n\n'
            'Arabic text: Tanzil Project (CC BY 3.0), https://tanzil.net.';
  }
  final pair = _templates[source];
  return pair == null ? null : (kk ? pair.$1 : pair.$2);
}

String? _arabic(String source) {
  final title = RegExp(r'^Коран (\d+:\d+(?:–\d+)?)$').firstMatch(source);
  if (title != null) return 'القرآن ${title[1]}';
  final subtitle =
      RegExp(r'^Чтение и слушание · ≈(\d+) мин$').firstMatch(source);
  if (subtitle != null) return 'قراءة واستماع · نحو ${subtitle[1]} دقائق';
  final audio = RegExp(r'^Коран (\d+:\d+) · слушай и следи за текстом$')
      .firstMatch(source);
  if (audio != null) return 'القرآن ${audio[1]} · استمع وتابع النص';
  final order =
      RegExp(r'^Восстанови начало аята (\d+:\d+)$').firstMatch(source);
  if (order != null) return 'رتّب كلمات بداية الآية ${order[1]}';
  final recall = RegExp(r'^Каким словом заканчивается аят (\d+:\d+)\?$')
      .firstMatch(source);
  if (recall != null) return 'بأي كلمة تنتهي الآية ${recall[1]}؟';
  final intro =
      RegExp(r'^Аяты (\d+:\d+(?:–\d+)?). .*Ориентир — (\d+) мин;', dotAll: true)
          .firstMatch(source);
  if (intro != null) {
    return 'الآيات ${intro[1]}. استمع إلى التسجيل وتابع النص العربي، ثم كرّر '
        'بالوتيرة المناسبة لك. هذا تدريب على القراءة، وليس ترجمة أو تفسيرًا. '
        'المدة التقديرية ${intro[2]} دقائق؛ وتستغرق الإعادات الإضافية وقتًا أطول.\n\n'
        'النص العربي: Tanzil Project (CC BY 3.0)، https://tanzil.net.';
  }
  return _arabicTemplates[source];
}

const _arabicTemplates = <String, String>{
  'Это начальный фрагмент уже прочитанного аята. Восстанови порядок слов по исходному тексту.':
      'هذه بداية آية قرأتها للتو. أعد ترتيب الكلمات وفق النص الأصلي.',
  'Вспомни окончание только что прочитанного аята. Все варианты взяты из изученного арабского текста.':
      'تذكّر نهاية الآية التي قرأتها للتو. جميع الخيارات مأخوذة من النص العربي الذي درسته.',
  'Вернись к трудным местам и повтори их спокойно. Этот урок отмечает практику чтения и узнавания текста; он не подтверждает заучивание, понимание тафсира или правильность таджвида. Для проверки чтения нужен преподаватель.':
      'عُد إلى المواضع الصعبة وكرّرها بهدوء. يسجّل هذا الدرس تدريبًا على القراءة والتعرّف إلى النص؛ ولا يثبت الحفظ أو فهم التفسير أو صحة التجويد. تحتاج مراجعة التلاوة إلى معلّم.',
};

const _templates = <String, (String, String)>{
  'Это начальный фрагмент уже прочитанного аята. Восстанови порядок слов по исходному тексту.':
      (
    'Бұл — оқылған аяттың бастапқы үзіндісі. Сөздердің ретін түпнұсқа бойынша қалпына келтір.',
    'This is the opening excerpt of a verse you just read. Restore the word order from the source text.'
  ),
  'Вспомни окончание только что прочитанного аята. Все варианты взяты из изученного арабского текста.':
      (
    'Жаңа ғана оқылған аяттың соңын еске түсір. Барлық нұсқалар оқылған арабша мәтіннен алынған.',
    'Recall the end of the verse you just read. Every option is taken from the Arabic text you studied.'
  ),
  'Вернись к трудным местам и повтори их спокойно. Этот урок отмечает практику чтения и узнавания текста; он не подтверждает заучивание, понимание тафсира или правильность таджвида. Для проверки чтения нужен преподаватель.':
      (
    'Қиын жерлерге оралып, асықпай қайтала. Бұл сабақ оқу мен мәтінді тану жаттығуын белгілейді; жаттап алғаныңды, тәпсірді түсінгеніңді немесе тәжуидтің дұрыстығын растамайды. Оқуды тексеру үшін ұстаз қажет.',
    'Return to difficult passages and repeat calmly. This lesson records reading and text-recognition practice; it does not certify memorization, tafsir understanding or correct tajwid. A teacher is needed to check your recitation.'
  ),
};
