# Muslingo product audit - 2026-09-10

## Scope

Repository-wide UI, UX, workflow, accessibility, release, and security review of the Flutter web, Android, iOS, widget, notification, lesson, account, league, Quran reader, and AI-assisted paths.

## User flows verified

- First launch, onboarding goals, guest continuation, registration entry points, and local progress.
- Home, daily ayah rotation, daily plan, streak, achievements, league, profile, install prompt, and bottom navigation.
- Learning-path switching and expansion for Quran, Arabic, Islam foundations, and Tajwid.
- All 246 lessons: 100 Quran, 100 Arabic, 36 Tajwid, and 10 Islam foundations.
- Listening, questions, matching, word ordering, pronunciation, retry, result, and lesson completion states.
- Quran list, chapter reading, search, audio controls, bookmarks, and lesson handoff.
- Academy, Hafiz-related progress, notification preferences, lock-screen privacy options, and home-widget content.

## Resolved findings

- Replaced static-feeling taps with consistent press-scale feedback across primary buttons, lesson answers, chips, matching cards, path nodes, audio controls, and navigation.
- Added restrained route, lesson-step, path-atmosphere, mascot, and state-transition motion while respecting Reduce Motion.
- Removed stale interactive layers between lesson steps and stabilized scroll position so hidden controls no longer intercept taps.
- Made long lesson content scrollable above the fixed action area and kept the bottom navigation stable.
- Corrected Arabic font fallback and eliminated missing-glyph boxes in questions and recognized text.
- Kept pronunciation retry available after success or failure, gated recording behind sample playback, and propagated authenticated speech tokens.
- Preserved installed-app detection so the install action disappears after successful PWA installation.
- Hardened progress rewards, guest imports, push privacy, CORS, secure token storage, Android backup policy, and speech-provider quotas.

## Verification health

- Flutter analyzer: healthy, zero issues.
- Flutter tests: healthy, 140 passed, including a complete interaction pass through every lesson.
- API tests: healthy, 158 passed.
- Production dependency audit: healthy, zero known vulnerabilities.
- Flutter web release: healthy; only the upstream `flutter_tts` WebAssembly compatibility warning remains. The production JavaScript build is unaffected.
- Android debug APK: healthy and built locally. A signed production APK still requires the owner's Android upload keystore secrets.
- iOS release: blocked by host setup, because full Xcode, signing identity, and provisioning profile are not installed.
- Physical-device microphone, push, lock-screen, and widget behavior: requires final signed-build checks on real iOS and Android devices.

## Security follow-up

The sealed security scan reports one medium and two low findings: email ownership is not verified before password login, lesson rewards are not yet bound to authoritative per-step outcomes, and distributed anonymous speech use can consume the globally capped provider budget. These are documented with source evidence and remediation tests in the generated security report.
