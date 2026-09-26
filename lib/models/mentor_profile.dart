enum MentorTone { gentle, focused, cheerful }

class MentorMemory {
  final String id;
  final String text;
  final DateTime createdAt;

  const MentorMemory({
    required this.id,
    required this.text,
    required this.createdAt,
  });

  /// Learning preferences can be remembered; credentials, contact details,
  /// medical and intimate information must not enter persistent mentor memory.
  /// Strip Arabic marks before matching so diacritics do not bypass the guard.
  static bool isSensitiveText(String text) {
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[\u0640\u064b-\u065f\u0670\u06d6-\u06ed]'), '');
    return RegExp(
          r'(парол|password|құпия ?сөз|token|токен|otp|\bpin\b|банк|bank|карт|card|cvv|iban|иин|\biin\b|паспорт|passport|адрес|address|мекенжай|телефон|phone|email|e-mail|почт|медицин|medical|диагноз|diagnos|интим|intimate|сексуал|sexual|голосов.*запис|voice recording|كلم[ةه]\s*(?:ال)?(?:مرور|سر)|رمز\s*(?:ال)?(?:دخول|تحقق|سري)|رمزي\s*(?:السري|للتحقق)|بطاق|حسابي\s*(?:البنكي|المصرفي)|جواز\s*(?:ال)?سفر|رقم\s*(?:ال)?هوي|عنواني|عنوان\s*(?:ال)?(?:منزل|سكن)|اسكن\s*في|أسكن\s*في|هاتفي|هاتف|جوالي|بريدي|بريد\s*(?:إلكتروني|الكتروني)|تشخيص|مرضي|أعاني\s*من|اعاني\s*من|طبي|صحتي|علاجي|دوائي|ادويتي|أدويتي|علاق.*حميم|حيات.*جنس|جماع|جنس|تسجيل.*صوت)',
          caseSensitive: false,
        ).hasMatch(normalized) ||
        RegExp(r'[\w.+-]+@[\w.-]+\.[a-z]{2,}', caseSensitive: false)
            .hasMatch(normalized) ||
        RegExp(r'(?:[0-9٠-٩۰-۹][\s()+-]*){7,}').hasMatch(normalized);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MentorMemory.fromJson(Map<String, dynamic> json) => MentorMemory(
        id: _clean(json['id'], 80),
        text: _clean(json['text'], 240),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

class MentorProfile {
  final bool memoryEnabled;
  final bool proactiveQuestionsEnabled;
  final bool birthdayCelebrationsEnabled;
  final bool personalizedRemindersEnabled;
  final String preferredName;
  final int? birthdayMonth;
  final int? birthdayDay;
  final String motivation;
  final String currentFocus;
  final MentorTone tone;
  final int preferredSessionMinutes;
  final List<MentorMemory> memories;

  const MentorProfile({
    this.memoryEnabled = true,
    this.proactiveQuestionsEnabled = true,
    this.birthdayCelebrationsEnabled = true,
    this.personalizedRemindersEnabled = true,
    this.preferredName = '',
    this.birthdayMonth,
    this.birthdayDay,
    this.motivation = '',
    this.currentFocus = '',
    this.tone = MentorTone.gentle,
    this.preferredSessionMinutes = 6,
    this.memories = const [],
  });

  bool isBirthday(DateTime date) =>
      birthdayCelebrationsEnabled &&
      birthdayMonth == date.month &&
      birthdayDay == date.day;

  MentorProfile copyWith({
    bool? memoryEnabled,
    bool? proactiveQuestionsEnabled,
    bool? birthdayCelebrationsEnabled,
    bool? personalizedRemindersEnabled,
    String? preferredName,
    int? birthdayMonth,
    int? birthdayDay,
    bool clearBirthday = false,
    String? motivation,
    String? currentFocus,
    MentorTone? tone,
    int? preferredSessionMinutes,
    List<MentorMemory>? memories,
  }) =>
      MentorProfile(
        memoryEnabled: memoryEnabled ?? this.memoryEnabled,
        proactiveQuestionsEnabled:
            proactiveQuestionsEnabled ?? this.proactiveQuestionsEnabled,
        birthdayCelebrationsEnabled:
            birthdayCelebrationsEnabled ?? this.birthdayCelebrationsEnabled,
        personalizedRemindersEnabled:
            personalizedRemindersEnabled ?? this.personalizedRemindersEnabled,
        preferredName: _clean(preferredName ?? this.preferredName, 60),
        birthdayMonth:
            clearBirthday ? null : birthdayMonth ?? this.birthdayMonth,
        birthdayDay: clearBirthday ? null : birthdayDay ?? this.birthdayDay,
        motivation: _clean(motivation ?? this.motivation, 240),
        currentFocus: _clean(currentFocus ?? this.currentFocus, 160),
        tone: tone ?? this.tone,
        preferredSessionMinutes:
            (preferredSessionMinutes ?? this.preferredSessionMinutes)
                .clamp(3, 30),
        memories: (memories ?? this.memories).take(20).toList(growable: false),
      );

  Map<String, dynamic> toJson() => {
        'version': 1,
        'memoryEnabled': memoryEnabled,
        'proactiveQuestionsEnabled': proactiveQuestionsEnabled,
        'birthdayCelebrationsEnabled': birthdayCelebrationsEnabled,
        'personalizedRemindersEnabled': personalizedRemindersEnabled,
        'preferredName': preferredName,
        'birthdayMonth': birthdayMonth,
        'birthdayDay': birthdayDay,
        'motivation': motivation,
        'currentFocus': currentFocus,
        'tone': tone.name,
        'preferredSessionMinutes': preferredSessionMinutes,
        'memories': memories.map((item) => item.toJson()).toList(),
      };

  factory MentorProfile.fromJson(Map<String, dynamic> json) {
    final month = (json['birthdayMonth'] as num?)?.toInt();
    final day = (json['birthdayDay'] as num?)?.toInt();
    final validBirthday = month != null &&
        day != null &&
        month >= 1 &&
        month <= 12 &&
        day >= 1 &&
        day <= DateTime(2024, month + 1, 0).day;
    final rawMemories = json['memories'];
    final memories = rawMemories is List
        ? rawMemories
            .whereType<Map>()
            .map((item) => MentorMemory.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .where((item) => item.id.isNotEmpty && item.text.isNotEmpty)
            .take(20)
            .toList(growable: false)
        : const <MentorMemory>[];
    return MentorProfile(
      memoryEnabled: json['memoryEnabled'] != false,
      proactiveQuestionsEnabled: json['proactiveQuestionsEnabled'] != false,
      birthdayCelebrationsEnabled: json['birthdayCelebrationsEnabled'] != false,
      personalizedRemindersEnabled:
          json['personalizedRemindersEnabled'] != false,
      preferredName: _clean(json['preferredName'], 60),
      birthdayMonth: validBirthday ? month : null,
      birthdayDay: validBirthday ? day : null,
      motivation: _clean(json['motivation'], 240),
      currentFocus: _clean(json['currentFocus'], 160),
      tone: MentorTone.values.firstWhere(
        (item) => item.name == json['tone'],
        orElse: () => MentorTone.gentle,
      ),
      preferredSessionMinutes:
          ((json['preferredSessionMinutes'] as num?)?.toInt() ?? 6)
              .clamp(3, 30),
      memories: memories,
    );
  }
}

String _clean(Object? value, int max) {
  final text = value?.toString().trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
  return text.length <= max ? text : text.substring(0, max);
}
