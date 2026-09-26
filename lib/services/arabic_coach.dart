import '../models/coach.dart';

/// Authored Arabic fallback. No network answer is fabricated during outages.
class ArabicCoach {
  static const suggestions = [
    'ماذا أراجع اليوم؟',
    'أي درس يناسبني؟',
    'ما الجوانب التي أحتاج إلى تحسينها؟',
    'أي قاعدة تجويد أراجع؟',
    'أعطني اختبارًا قصيرًا',
    'أي سورة أتعلم بعد ذلك؟',
    'ساعدني على حفظ سورة',
    'ضع لي خطة لسبعة أيام',
  ];

  static const _progress = CoachSource(
    title: 'تقدمك في Muslingo',
    category: 'بيانات التعلم',
    verification: 'بناءً على النتائج المسجلة على هذا الجهاز',
  );

  static CoachResponse answer(String question, CoachContext context) {
    final q = question.trim();
    bool has(List<String> words) => words.any(q.contains);
    final lesson = context.recommendedLessonTitle ?? 'الدرس التالي';
    final why = context.dueReviewCount > 0
        ? 'لديك ${context.dueReviewCount} عناصر حان موعد مراجعتها. نبدأ بها لتثبيت ما تعلمته.'
        : 'هذا الدرس مناسب لهدفك ومستواك الحالي.';
    CoachResponse start(String text, {String label = 'ابدأ الدرس'}) =>
        CoachResponse(
          text: text,
          sources: const [_progress],
          reasoning: why,
          actionType: context.recommendedLessonId == null
              ? null
              : CoachActionType.startLesson,
          actionLabel: label,
          lessonId: context.recommendedLessonId,
        );

    if (q.isEmpty) {
      return const CoachResponse(
          text: 'اكتب سؤالك عن الدرس أو المراجعة أو الحفظ.');
    }
    if (has(['فتوى', 'تشخيص', 'دواء', 'طلاق', 'حلال', 'حرام'])) {
      return const CoachResponse(
        text:
            'لا أستطيع إصدار فتوى شخصية أو تشخيص طبي. يعتمد الحكم على تفاصيل الحالة؛ اسأل مختصًا مؤهلًا. يمكنك فتح قسم الأسئلة الرسمي للمجلس الديني لمسلمي كازاخستان.',
        actionType: CoachActionType.contactSpecialist,
        actionLabel: 'اسأل مختصًا',
        sources: [
          CoachSource(
            title: 'المجلس الديني لمسلمي كازاخستان: أسئلة وأجوبة',
            category: 'استشارة متخصصة',
            verification: 'الموقع الرسمي، متاح باللغة الكازاخية',
            url: 'https://www.muftyat.kz/kk/qa/',
          ),
        ],
      );
    }
    if (has(['حلم', 'أحلام', 'رؤيا', 'رؤى', 'منام'])) {
      return const CoachResponse(
        text:
            'لا أستطيع الجزم بمعنى حلم أو التنبؤ بالمستقبل من خلاله. لا تتخذ قرارًا مصيريًا اعتمادًا على تفسير غير موثوق. الاتصال بالمساعد غير متاح الآن، لذلك لن أختلق تفسيرًا أو أنسبه إلى مصدر ديني.',
      );
    }
    if (RegExp(r'^(تذكر|تذكّر|احفظ عني)').hasMatch(q)) {
      return CoachResponse(
        text: context.mentorProfile.memoryEnabled
            ? 'يمكنك مراجعة الملاحظات المحفوظة أو حذفها في «ذاكرة المرشد». لا أحفظ بيانات حساسة.'
            : 'ذاكرة المرشد معطلة. يمكنك تفعيلها من الإعدادات إذا أردت.',
      );
    }
    if (has(['حفظ', 'احفظ', 'حافظ'])) {
      return CoachResponse(
        text:
            'ابدأ بآية واحدة: استمع إليها، ثم كرر مقاطع قصيرة، ثم حاول استرجاعها دون النظر إلى النص. لديك ${context.hafizDueCount} آيات للمراجعة و${context.memorizedVerseCount} آيات مسجلة كمحفوظة.',
        sources: const [_progress],
        actionType: CoachActionType.openHafiz,
        actionLabel: 'افتح الحفظ',
      );
    }
    if (has(['اختبار', 'اختبر', 'امتحان'])) {
      return start(
        'لنراجع فهمك بمستوى يناسب المرحلة ${context.placementLevel}. أجب أولًا ثم راجع الشرح، وسنستخدم نتيجتك لتحديد ما يحتاج إلى تكرار.',
        label: 'ابدأ الاختبار',
      );
    }
    if (has(['تجويد', 'نطق', 'مخارج'])) {
      return start(
          'استمع إلى النموذج أولًا، وانتبه إلى طول الصوت ومخرجه، ثم كرره. التقييم الآلي أداة تدريب، وليس بديلًا عن معلم التجويد.');
    }
    if (has(['أسبوع', 'سبعة', '7 أيام'])) {
      return start(
          'خطة أسبوعية: يومان لمراجعة الأخطاء، ثم يومان لدرس جديد والاستماع، ثم يوم للاسترجاع دون النظر، ويوم للجوانب الصعبة، واليوم الأخير لمراجعة قصيرة. خصص نحو ${context.availableMinutes} دقائق يوميًا وعدّل الخطة بحسب نتيجتك.');
    }
    if (has(['ضعف', 'ضعيف', 'تحسين', 'صعب'])) {
      final weak = context.weakKnowledge.toList()
        ..sort((a, b) {
          final lapses = b.lapses.compareTo(a.lapses);
          return lapses != 0 ? lapses : a.strength.compareTo(b.strength);
        });
      if (weak.isNotEmpty) {
        return CoachResponse(
          text:
              'توضح نتائجك أن ${weak.length} عناصر تحتاج إلى تثبيت. لنبدأ بالعنصر الذي تكرر الخطأ فيه ${weak.first.lapses} مرات: استمع، ثم استرجع الإجابة، ثم تحقق منها.',
          sources: const [_progress],
          reasoning:
              'اخترت هذا التدريب بناءً على الأخطاء المسجلة، لا على افتراضات عنك.',
          actionType: CoachActionType.startLesson,
          actionLabel: 'ابدأ التدريب',
          lessonId: weak.first.lessonId,
        );
      }
      return start(
          'لا توجد نتائج كافية لتحديد جانب ضعيف بعد. أكمل «$lesson» لنبني التوصية على محاولتك الفعلية.');
    }
    if (has(
        ['راجع', 'مراجعة', 'درس', 'اليوم', 'تعلم', 'سورة', 'خطة', 'تقدم'])) {
      return CoachResponse(
        text:
            'ابدأ اليوم بـ«$lesson»، ثم راجع ما أخطأت فيه. تقدمك نحو هدف اليوم: ${context.todayProgress} من ${context.dailyGoal}.',
        sources: const [_progress],
        reasoning: why,
        dailyPlan: [
          CoachPlanItem(
            title: lesson,
            detail: '${context.availableMinutes} دقائق',
            lessonId: context.recommendedLessonId,
            isReview: context.dueReviewCount > 0,
          ),
        ],
        actionType: context.recommendedLessonId == null
            ? null
            : CoachActionType.startLesson,
        actionLabel: 'ابدأ الدرس',
        lessonId: context.recommendedLessonId,
      );
    }
    return const CoachResponse(
      text:
          'الاتصال بالمساعد غير متاح الآن. أستطيع محليًا مساعدتك في اختيار درس ومراجعة تقدمك وخطة الحفظ، لكنني لن أختلق جوابًا دينيًا بلا مصدر. حاول الاتصال مجددًا لسؤالك التفصيلي.',
    );
  }
}
