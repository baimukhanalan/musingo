import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mentor_profile.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';

class MentorMemoryScreen extends StatefulWidget {
  const MentorMemoryScreen({super.key});

  @override
  State<MentorMemoryScreen> createState() => _MentorMemoryScreenState();
}

class _MentorMemoryScreenState extends State<MentorMemoryScreen> {
  late final TextEditingController _name;
  late final TextEditingController _motivation;
  late final TextEditingController _focus;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final profile = context.read<AppState>().mentorProfile;
    _name = TextEditingController(text: profile.preferredName);
    _motivation = TextEditingController(text: profile.motivation);
    _focus = TextEditingController(text: profile.currentFocus);
    _loaded = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _motivation.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final profile = state.mentorProfile;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Row(children: [
                IconButton(
                  tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    state.tr(
                      ru: 'Память наставника',
                      kk: 'Тәлімгер жады',
                      en: 'Mentor memory',
                    ),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyDark,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr(
                        ru: 'Ты решаешь, что знает Айн',
                        kk: 'Айн нені білетінін сен шешесің',
                        en: 'You decide what Ayn knows',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      state.tr(
                        ru: 'Личные заметки видны здесь и никогда не выводятся на экран блокировки. Их можно удалить в любой момент.',
                        kk: 'Жеке жазбалар тек осында көрінеді және құлып экранына шықпайды. Оларды кез келген уақытта өшіруге болады.',
                        en: 'Private notes stay here and never appear on the Lock Screen. You can delete them at any time.',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        height: 1.4,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              PremiumCard(
                child: Column(children: [
                  _toggle(
                    state,
                    title: state.tr(
                        ru: 'Память включена',
                        kk: 'Жад қосулы',
                        en: 'Memory is on'),
                    subtitle: state.tr(
                        ru: 'Айн использует только подтверждённые факты',
                        kk: 'Айн тек расталған деректерді қолданады',
                        en: 'Ayn uses only confirmed facts'),
                    value: profile.memoryEnabled,
                    onChanged: (value) => state.updateMentorProfile(
                        profile.copyWith(memoryEnabled: value)),
                  ),
                  _toggle(
                    state,
                    title: state.tr(
                        ru: 'Задавать вопросы обо мне',
                        kk: 'Мен туралы сұрақтар қою',
                        en: 'Ask me personal questions'),
                    subtitle: state.tr(
                        ru: 'Не более одного уместного вопроса за диалог',
                        kk: 'Әңгімеде бір орынды сұрақтан артық емес',
                        en: 'At most one relevant question per conversation'),
                    value: profile.proactiveQuestionsEnabled,
                    onChanged: profile.memoryEnabled
                        ? (value) => state.updateMentorProfile(
                            profile.copyWith(proactiveQuestionsEnabled: value))
                        : null,
                  ),
                  _toggle(
                    state,
                    title: state.tr(
                        ru: 'Персональные напоминания',
                        kk: 'Жеке еске салулар',
                        en: 'Personal reminders'),
                    subtitle: state.tr(
                        ru: 'Имя, цель, урок и нужные повторения',
                        kk: 'Аты, мақсаты, сабағы және қайталауы',
                        en: 'Name, goal, lesson, and due reviews'),
                    value: profile.personalizedRemindersEnabled,
                    onChanged: (value) => state.updateMentorProfile(
                        profile.copyWith(personalizedRemindersEnabled: value)),
                  ),
                  _toggle(
                    state,
                    title: state.tr(
                        ru: 'Поздравлять с днём рождения',
                        kk: 'Туған күнмен құттықтау',
                        en: 'Birthday greetings'),
                    value: profile.birthdayCelebrationsEnabled,
                    onChanged: (value) => state.updateMentorProfile(
                        profile.copyWith(birthdayCelebrationsEnabled: value)),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field(
                        state,
                        _name,
                        state.tr(
                            ru: 'Как к тебе обращаться',
                            kk: 'Саған қалай жүгінген дұрыс',
                            en: 'What should Ayn call you')),
                    const SizedBox(height: 12),
                    _field(
                        state,
                        _motivation,
                        state.tr(
                            ru: 'Почему ты учишься',
                            kk: 'Неге оқып жүрсің',
                            en: 'Why you are learning'),
                        maxLines: 2),
                    const SizedBox(height: 12),
                    _field(
                        state,
                        _focus,
                        state.tr(
                            ru: 'Текущий фокус',
                            kk: 'Қазіргі фокус',
                            en: 'Current focus'),
                        maxLines: 2),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      children: MentorTone.values.map((tone) {
                        final label = switch (tone) {
                          MentorTone.gentle =>
                            state.tr(ru: 'Бережно', kk: 'Жұмсақ', en: 'Gentle'),
                          MentorTone.focused =>
                            state.tr(ru: 'По делу', kk: 'Нақты', en: 'Focused'),
                          MentorTone.cheerful => state.tr(
                              ru: 'Бодро', kk: 'Көңілді', en: 'Cheerful'),
                        };
                        return ChoiceChip(
                          label: Text(label),
                          selected: profile.tone == tone,
                          onSelected: (_) => state.updateMentorProfile(
                              profile.copyWith(tone: tone)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Material(
                      color: Colors.transparent,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.cake_outlined,
                            color: AppColors.coral),
                        title: Text(_birthdayLabel(state, profile)),
                        subtitle: Text(state.tr(
                            ru: 'Год рождения не нужен',
                            kk: 'Туған жыл қажет емес',
                            en: 'Birth year is not needed')),
                        trailing: profile.birthdayMonth == null
                            ? const Icon(Icons.chevron_right_rounded)
                            : IconButton(
                                tooltip: state.tr(
                                    ru: 'Удалить дату',
                                    kk: 'Күнді өшіру',
                                    en: 'Remove date'),
                                onPressed: () => state.updateMentorProfile(
                                    profile.copyWith(clearBirthday: true)),
                                icon: const Icon(Icons.close_rounded),
                              ),
                        onTap: () => _pickBirthday(state, profile),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => _saveTextFields(state),
                        child: Text(state.tr(
                            ru: 'Сохранить профиль',
                            kk: 'Профильді сақтау',
                            en: 'Save profile')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                state.tr(
                    ru: 'Что Айн помнит',
                    kk: 'Айн не біледі',
                    en: 'What Ayn remembers'),
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              if (profile.memories.isEmpty)
                Text(
                  state.tr(
                      ru: 'Пока ничего. Напиши в чате: «Запомни, что…»',
                      kk: 'Әзірге ештеңе жоқ. Чатта: «Есіңде сақта…» деп жаз.',
                      en: 'Nothing yet. Say “Remember that…” in chat.'),
                  style:
                      const TextStyle(color: AppColors.textGrey, height: 1.4),
                )
              else
                ...profile.memories.map((memory) => Card(
                      child: ListTile(
                        title: Text(memory.text),
                        trailing: IconButton(
                          tooltip:
                              state.tr(ru: 'Забыть', kk: 'Ұмыту', en: 'Forget'),
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => state.forgetCoachMemory(memory.id),
                        ),
                      ),
                    )),
              if (profile.memories.isNotEmpty)
                TextButton.icon(
                  onPressed: state.clearCoachMemories,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: Text(state.tr(
                      ru: 'Очистить всю память',
                      kk: 'Барлық жадты тазалау',
                      en: 'Clear all memory')),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmReset(state),
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(state.tr(
                  ru: 'Сбросить всю персонализацию',
                  kk: 'Барлық дербестендіруді қалпына келтіру',
                  en: 'Reset all personalization',
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle(AppState state,
          {required String title,
          String? subtitle,
          required bool value,
          required ValueChanged<bool>? onChanged}) =>
      Material(
        color: Colors.transparent,
        child: SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(title,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
          subtitle: subtitle == null ? null : Text(subtitle),
          value: value,
          onChanged: onChanged,
        ),
      );

  Widget _field(AppState state, TextEditingController controller, String label,
          {int maxLines = 1}) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        maxLength: maxLines == 1 ? 60 : 200,
        decoration: InputDecoration(labelText: label, counterText: ''),
      );

  String _birthdayLabel(AppState state, MentorProfile profile) {
    if (profile.birthdayMonth == null || profile.birthdayDay == null) {
      return state.tr(
          ru: 'Добавить день рождения',
          kk: 'Туған күнді қосу',
          en: 'Add birthday');
    }
    return '${profile.birthdayDay.toString().padLeft(2, '0')}.${profile.birthdayMonth.toString().padLeft(2, '0')}';
  }

  Future<void> _pickBirthday(AppState state, MentorProfile profile) async {
    const pickerYear = 2024;
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(
          pickerYear, profile.birthdayMonth ?? 1, profile.birthdayDay ?? 1),
      firstDate: DateTime(pickerYear),
      lastDate: DateTime(pickerYear, 12, 31),
      helpText: state.tr(ru: 'День рождения', kk: 'Туған күн', en: 'Birthday'),
    );
    if (selected == null) return;
    await state.updateMentorProfile(profile.copyWith(
        birthdayMonth: selected.month, birthdayDay: selected.day));
  }

  Future<void> _saveTextFields(AppState state) async {
    await state.updateMentorProfile(state.mentorProfile.copyWith(
      preferredName: _name.text,
      motivation: _motivation.text,
      currentFocus: _focus.text,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.tr(
            ru: 'Айн запомнил настройки',
            kk: 'Айн баптауларды есте сақтады',
            en: 'Ayn saved your preferences'))));
  }

  Future<void> _confirmReset(AppState state) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(state.tr(
              ru: 'Сбросить память Айн?',
              kk: 'Айн жадын қалпына келтіру керек пе?',
              en: 'Reset Ayn’s memory?',
            )),
            content: Text(state.tr(
              ru: 'Будут удалены личные настройки, подтверждённые факты и сохранённая история чата. Учебный прогресс останется.',
              kk: 'Жеке баптаулар, расталған деректер және сақталған чат тарихы өшіріледі. Оқу прогресі қалады.',
              en: 'Personal preferences, confirmed facts, and saved chat history will be deleted. Learning progress stays.',
            )),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child:
                    Text(state.tr(ru: 'Отмена', kk: 'Бас тарту', en: 'Cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(state.tr(
                    ru: 'Сбросить', kk: 'Қалпына келтіру', en: 'Reset')),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await state.resetMentorPersonalization();
    _name.clear();
    _motivation.clear();
    _focus.clear();
  }
}
