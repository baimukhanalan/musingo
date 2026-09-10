# Muslingo product audit - 2026-09-10

## Scope

Repository-wide UI, UX, workflow, accessibility, release, and security review of the Flutter web, Android, iOS, widget, notification, lesson, account, league, Quran reader, and AI-assisted paths.

## User flows verified

- First launch, onboarding goals, guest continuation, registration entry points, and local progress.
- Registered-account login, wrong-password handling, password change, token replacement, global session revocation, logout, repeat login, and account deletion.
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
- Added a complete password-change workflow in Profile and Settings with current-password verification, 8-128 character validation, password-reuse rejection, rate limiting, secure re-hashing, replacement tokens, and sign-out of other sessions.
- Fixed narrow-screen text clipping found during the production visual pass: long primary actions scale down without ellipsis and Quran chapter names remain fully visible at a 320 px viewport.
- Kept the Friends and Achievements headers on one line at narrow widths despite adjacent language and progress controls.

## Numbered workflow health

1. First launch and onboarding - healthy. Splash, carousel, goal selection, placement, and the recommended first lesson are covered by widget and state tests.
2. Continue without account - healthy. Guest progress, local learning profile, daily counters, memory scheduling, and clean reset are covered.
3. Registration - healthy. Server registration is rate limited, avoids email enumeration in its response, hashes passwords with scrypt, creates progress atomically, and imports guest learning state without trusting reward counters.
4. Login and session restore - healthy. Wrong email/password responses are generic, credential verification is timing balanced, tokens are signed and scoped, and invalid or expired sessions are rejected.
5. Password change - healthy. Production E2E verified wrong current password, reused password, successful change, old-token revocation, rejection of the old password, acceptance of the new password, and preservation of the active replacement session.
6. Home and daily plan - healthy. Daily ayah rotation, next lesson, streak, XP, hearts, recommendation, course switching, internal path scrolling, full-screen path, and the five-button bottom navigation are covered.
7. Quran learning path - healthy. All steps in all 100 lessons reach completion; canonical Quran text and audio-to-ayah mapping are validated.
8. Arabic learning path - healthy. All steps in all 100 lessons reach completion; answer ordering and matching are non-trivial and deterministic per attempt.
9. Tajwid learning path - healthy. All steps in all 36 lessons reach completion and core tajwid sections are present.
10. Islam foundations - healthy. All steps in all 10 lessons reach completion and preserve the approved curriculum order.
11. Pronunciation - healthy in automated and server tests. Sample playback gates recording, recorded audio is consent-gated, authenticated uploads are evaluated, weak partial matches fail, and retry remains available after success or failure.
12. Quran Reader - healthy. Surah list, localized search, juz and Hafiz tabs, chapter loading, cached fallback, Arabic text, audio mapping, and learning handoff are covered.
13. AI Coach - healthy within its source-grounded scope. Personal review context, curriculum actions, verified sources, unsupported-question refusal, and specialist escalation are covered.
14. League, friends, streak, achievements, Academy, Hafiz, premium, help, and settings - healthy. Routes render, guest gates are explicit, and navigation targets are exercised.
15. Notifications and widgets - healthy in configuration tests. Daily lesson and daily ayah scheduling, permission states, private lock-screen previews, iPhone Lock Screen families, and Android keyguard metadata are covered.
16. Install flow - healthy for web/PWA. The install screen fits mobile viewports and the install prompt is hidden after the browser confirms installation.
17. Account deletion - healthy. The production test account was deleted and subsequent login was rejected.

## Verification health

- Flutter analyzer: healthy, zero issues.
- Flutter tests: healthy. The Vercel clean build passed all 148 tests after the responsive fix, including every lesson; the subsequent narrow-header change passed analyzer plus 17 focused screen/navigation checks.
- API tests: healthy, 161 passed locally and in the Vercel clean build.
- Production dependency audit: healthy, zero known vulnerabilities.
- Flutter web release: healthy; only the upstream `flutter_tts` WebAssembly compatibility warning remains. The production JavaScript build is unaffected.
- Production deployment: healthy. Vercel built the repository from a clean checkout, ran all tests, produced the release bundle, and assigned `https://muslingo-mobile.vercel.app`.
- Production password E2E: healthy. Observed statuses were register 202, login 200, wrong current password 401, reused password 400, change 200, old session 401, old-password login 401, new-password login 200, new session 200, deletion 204, and post-deletion login 401.
- Android debug APK: healthy. The GitHub Java 17 workflow built the current app successfully; the local host lacks Java and could not repeat Gradle locally. A signed production APK still requires the owner's Android upload keystore secrets, so the release-publish job was correctly skipped.
- iOS release: blocked by host setup, because full Xcode, signing identity, and provisioning profile are not installed.
- Physical-device microphone, push, lock-screen, and widget behavior: requires final signed-build checks on real iOS and Android devices.

## Visual and accessibility evidence limits

- Current-run screenshots were inspected in the selected Codex in-app browser at a 319 px viewport for Home, Settings, Change password, Quran Reader, AI Coach, Hafiz, League, Friends, Achievements, Streak, Academy, Help, Premium, and Install. The visible clipping issues were fixed and covered by narrow-width checks.
- The browser capture surface displayed screenshots inline but did not provide a stable repository file path, so this audit does not claim a saved screenshot archive.
- Flutter's canvas exposed only the accessibility enable control to browser automation. Semantics, screen-reader order, keyboard focus, microphone permission prompts, push delivery, lock-screen presentation, and native widget resizing still require VoiceOver/TalkBack and physical-device checks; screenshot inspection alone cannot establish accessibility compliance.
- Password reset by verified email is not implemented. Logged-in users can securely change a known password; recovery after forgetting it needs a transactional email provider, verified-email ownership, and a short-lived reset-token flow.

## Security follow-up

The sealed security scan reports one medium and two low findings: email ownership is not verified before password login, lesson rewards are not yet bound to authoritative per-step outcomes, and distributed anonymous speech use can consume the globally capped provider budget. These are documented with source evidence and remediation tests in the generated security report.
