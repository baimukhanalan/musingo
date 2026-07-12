# Muslingo Production Plan 2026-07-11

## Goal

Bring Muslingo to a production-ready Duolingo-like learning app for Quran study, Arabic learning, and Islamic foundations with working account flow, full Quran reading/listening, gamification, speech practice, haptics, offline support, deployment, and full workflow audit.

## Current State

- Quran text flow supports 114 surahs and 6236 ayahs through the Quran screen.
- Surah screen has full-surah audio above ayahs, full text sheet, Arabic/Russian toggle, and individual ayah cards.
- Full-surah audio now prefers a downloaded local mp3 when available and otherwise streams one complete mp3 file.
- Offline Quran reading cache exists for all 114 surahs.
- Per-surah offline audio download exists for native platforms and saves downloaded chapter numbers in the user profile.
- Batch full-Quran audio download control exists for native platforms and downloads each surah as one mp3 file.
- Web full-surah audio remains streaming-only; full offline audio on web still needs Cache API.
- Login screen no longer exposes guest entry.
- Duplicate registration errors are mapped from `Value must be unique` to a readable existing-email message.
- Lessons screen has Quran/Arabic mode switching.
- Arabic mode asks native language once and stores Russian/Kazakh/Uzbek choice.
- Seven Islamic foundation lessons are placed before surah study.
- Lessons include mistake replay, speech steps, energy, haptics, and Quran reward chests.
- Native speech no longer fails before `speech_to_text`; native platforms evaluate recognized transcript.
- Web speech recorder can capture audio bytes and send them with transcript.

## Production Gaps

1. Restore Flutter/Dart SDK execution on the Mac.
   - Current blocker: `dart --version`, `flutter --version`, `dart format`, Node syntax checks, Flutter tests, and Flutter build hang on this machine.
   - Attempted: removed `com.apple.provenance`, reset Flutter cache temporarily, restored cache backup.
   - Next action: reinstall Flutter stable arm64 SDK or repair current clone/cache, then rerun all checks.

2. Replace transcript-only speech scoring with true AI audio evaluation.
   - Current behavior: app records/sends audio on web and uses `speech_to_text` transcript; backend scores transcript similarity.
   - Production behavior: backend should transcribe audio, compare Quran/Arabic pronunciation, return weak phoneme/word feedback, and keep local fallback.

3. Add native audio recording bytes for iOS/Android.
   - Current behavior: native no-op recorder allows speech flow to continue via `speech_to_text`.
   - Production behavior: add native recorder package, request permissions, submit real audio bytes, and keep `speech_to_text` as fallback.

4. Harden offline audio for all surahs.
   - Current behavior: per-surah native download and batch full-Quran audio download controls exist; all-text offline cache works.
   - Production behavior: add storage estimate, pause/resume, delete-all, Wi-Fi warning, checksum/size validation, and web Cache API support.

5. Expand Arabic curriculum.
   - Current behavior: initial gamified Arabic path exists.
   - Production behavior: full alphabet, harakat, joining forms, listening drills, reading fluency, review, placement, and spaced repetition.

6. Expand surah curriculum.
   - Current behavior: short surahs and Al-Baqarah intro lessons exist.
   - Production behavior: every selected surah split into explanation, listening, meaning, recitation, mistake review, and final test.

7. Harden backend migrations and auth.
   - Current behavior: gamification fields and routes are added.
   - Production behavior: run PocketBase migrations on a clean DB, verify unique email handling, profile restore, delete account, leaderboard, progress completion, and audio download sync.

8. Run final workflow audit.
   - Login/register.
   - Quran full text, full-surah audio, ayah audio, offline text, offline audio.
   - Quran lessons, Arabic lessons, Islamic foundation lessons.
   - Speech steps, wrong-answer loop, reward chests, energy spend, haptics.
   - Profile/settings/help/delete account.
   - Mobile and desktop responsive checks.

9. Deploy to Vercel.
   - Build command is configured in `vercel.json`.
   - Deployment must wait until Flutter SDK can build a fresh `build/web`.

## Required Verification Before Release

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- `flutter build web --release`
- Backend hook syntax/migration check.
- Local browser preview of the fresh build.
- Manual audio click test in a real browser.
- Manual microphone permission and speech test.
- Vercel production deployment and smoke test.

## Current Blocker

Fresh preview and Vercel deploy are blocked by local SDK execution: even `flutter --version` and direct Dart binary invocation time out. The app code has been advanced, but it cannot be honestly certified or deployed until the Flutter toolchain is repaired.
