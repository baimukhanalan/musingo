import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_state.dart';
import '../services/profile_avatar_store.dart';
import '../utils/colors.dart';
import 'cat_character.dart';

class EditableProfileAvatar extends StatefulWidget {
  final String storageScope;
  final bool isPremium;
  final Future<XFile?> Function()? pickImage;

  const EditableProfileAvatar({
    super.key,
    required this.storageScope,
    this.isPremium = false,
    this.pickImage,
  });

  @override
  State<EditableProfileAvatar> createState() => _EditableProfileAvatarState();
}

class _EditableProfileAvatarState extends State<EditableProfileAvatar> {
  final _store = ProfileAvatarStore();
  Uint8List? _photo;
  bool _busy = false;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(EditableProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storageScope != widget.storageScope) {
      _photo = null;
      _busy = false;
      _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_generation;
    final scope = widget.storageScope;
    final bytes = await _store.load(scope);
    if (!mounted || generation != _generation) return;
    setState(() => _photo = bytes);
    // Android may recreate its activity while the gallery is open. Recover
    // only the explicitly saved owner; never attach a previous user's image.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final pendingScope =
            prefs.getString(ProfileAvatarStore.pendingScopeKey);
        final result = await ImagePicker().retrieveLostData();
        await prefs.remove(ProfileAvatarStore.pendingScopeKey);
        if (pendingScope == scope &&
            mounted &&
            generation == _generation &&
            result.files?.isNotEmpty == true) {
          await _useFile(result.files!.first, scope);
        }
      } catch (_) {
        // A dismissed or lost picker never breaks the default avatar.
      }
    }
  }

  Future<void> _edit() async {
    final state = context.read<AppState>();
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  state.tr(
                    ru: 'Фото профиля · только на этом устройстве\nJPG, PNG или WebP до 5 МБ',
                    kk: 'Профиль суреті · тек осы құрылғыда\n5 МБ-қа дейін JPG, PNG немесе WebP',
                    en: 'Profile photo · only on this device\nJPG, PNG or WebP up to 5 MB',
                  ),
                  style:
                      const TextStyle(color: AppColors.textGrey, height: 1.5),
                ),
              ),
              ListTile(
                key: const ValueKey('avatar-pick-photo'),
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(state.tr(
                    ru: 'Выбрать фото',
                    kk: 'Сурет таңдау',
                    en: 'Choose photo')),
                onTap: () => Navigator.pop(sheetContext, 'pick'),
              ),
              if (_photo != null)
                ListTile(
                  key: const ValueKey('avatar-reset-photo'),
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: Text(state.tr(
                      ru: 'Вернуть Айна',
                      kk: 'Айнды қайтару',
                      en: 'Restore Ayn')),
                  onTap: () => Navigator.pop(sheetContext, 'reset'),
                ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child:
                    Text(state.tr(ru: 'Отмена', kk: 'Бас тарту', en: 'Cancel')),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null) return;
    final scope = widget.storageScope;
    setState(() => _busy = true);
    try {
      if (action == 'reset') {
        await _store.remove(scope);
        if (mounted && widget.storageScope == scope) {
          setState(() => _photo = null);
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(ProfileAvatarStore.pendingScopeKey, scope);
        try {
          final file = await (widget.pickImage?.call() ??
              ImagePicker().pickImage(
                source: ImageSource.gallery,
                requestFullMetadata: false,
              ));
          if (file != null && mounted && widget.storageScope == scope) {
            await _useFile(file, scope);
          }
        } finally {
          await prefs.remove(ProfileAvatarStore.pendingScopeKey);
        }
      }
    } catch (error) {
      if (mounted && widget.storageScope == scope) _showError(error);
    } finally {
      if (mounted && widget.storageScope == scope) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _useFile(XFile file, String scope) async {
    if (await file.length() > ProfileAvatarStore.maxInputBytes) {
      throw AvatarValidationError.tooLarge;
    }
    final normalized =
        await ProfileAvatarStore.normalize(await file.readAsBytes());
    if (!mounted || widget.storageScope != scope) return;
    await _store.save(scope, normalized);
    if (mounted && widget.storageScope == scope) {
      setState(() => _photo = normalized);
    }
  }

  void _showError(Object error) {
    final state = context.read<AppState>();
    final message = error == AvatarValidationError.tooLarge
        ? state.tr(
            ru: 'Выбери фото до 5 МБ и 25 мегапикселей.',
            kk: '5 МБ және 25 мегапиксельге дейінгі суретті таңда.',
            en: 'Choose a photo up to 5 MB and 25 megapixels.')
        : error == AvatarValidationError.unsupported ||
                error == AvatarValidationError.invalidImage
            ? state.tr(
                ru: 'Не удалось прочитать фото. Попробуй JPG, PNG или WebP.',
                kk: 'Суретті оқу мүмкін болмады. JPG, PNG не WebP таңда.',
                en: 'Could not read this photo. Try JPG, PNG or WebP.')
            : state.tr(
                ru: 'Фото не сохранено. Проверь доступ к галерее и попробуй ещё раз.',
                kk: 'Сурет сақталмады. Галереяға рұқсатты тексеріп, қайтала.',
                en: 'Photo was not saved. Check gallery access and try again.');
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Semantics(
      button: true,
      label: state.tr(
          ru: 'Изменить фото профиля',
          kk: 'Профиль суретін өзгерту',
          en: 'Change profile photo'),
      child: InkWell(
        key: const ValueKey('profile-avatar-edit'),
        onTap: _busy ? null : _edit,
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          width: 96,
          height: 108,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    color: AppColors.skyLight.withValues(alpha: 0.6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: _photo == null
                        ? const CatCharacter(mood: CatMood.idle, size: 96)
                        : Image.memory(
                            _photo!,
                            key: const ValueKey('profile-avatar-photo'),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) => const CatCharacter(
                                mood: CatMood.idle, size: 96),
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: _busy
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.edit_rounded,
                          size: 14, color: Colors.white),
                ),
              ),
              if (widget.isPremium)
                const Positioned(
                  top: 3,
                  right: 3,
                  child: Icon(Icons.workspace_premium_rounded,
                      color: AppColors.gold, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
