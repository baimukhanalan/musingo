# Muslingo: functional userflow and workflow audit

Date: 2026-08-16

## Scope

- 21 top-level application screens.
- 5 persistent bottom-navigation destinations.
- 205 interactive callbacks across screens and shared widgets.
- 43 named navigation calls plus local `MaterialPageRoute` transitions.
- Guest, local-account and backend-account branches where they differ.
- Mobile layout at 390x844 and 402x874.

## Result

No blocking navigation conflict remains in the tested production paths. The
bottom navigation was rebuilt to the requested Instagram-style interaction:
five equal icon-only targets, outlined/filled active states, a thin divider,
no labels, pills, floating container or shadow. Accessible labels and tooltips
remain available, and every destination is exercised by a widget test.

## Userflow matrix

| Step | Flow | Health | Evidence and limits |
| --- | --- | --- | --- |
| 1 | Splash -> onboarding | Healthy | Splash and first onboarding viewport render tests pass. |
| 2 | Goal choice -> five-question diagnostic -> first lesson | Healthy | Full diagnostic interaction is covered by a widget test. |
| 3 | Login/register/continue as guest | Healthy | Guest creation, local hashed password login and legacy-password migration are tested. Remote login still depends on configured production API and network. |
| 4 | Home -> daily lesson | Healthy | Recommendation renders, lesson route receives a real `Lesson`, zero-heart gating and restore path are implemented. |
| 5 | Home -> Quran/Arabic/Basics learning paths | Healthy | All three modes switch without a modal conflict; the lesson path has internal scrolling and expanded mode preserves the bottom bar. |
| 6 | Home -> Academy | Healthy | Academy entry and lesson opening are wired; locked lessons preserve prerequisite gating. |
| 7 | Bottom navigation: Home/Quran/Coach/Hafiz/Profile | Healthy | All five icon buttons are tapped in sequence and the selected `IndexedStack` index is asserted. |
| 8 | Quran -> Surahs/Juz/Hafiz tabs | Healthy | All three selectors are tested; 30 juz boundaries and 114-surah canonical content are validated. |
| 9 | Quran -> chapter -> verse audio/Hafiz | Healthy with network dependency | Routes and repository fallbacks are implemented. Remote recitation availability depends on the audio source/network. |
| 10 | Lesson listen -> answer -> matching/order -> microphone -> review | Healthy | Gameplay tests cover answer gating, two-part reasoning, word order, matching, microphone prerequisites, completion and reward integrity. Browser microphone still requires user permission. |
| 11 | AI Coach suggestions/input -> response -> source/action | Healthy with backend fallback | Personal context, due reviews, safe source/action parsing and local fallback are tested. Generative answers require a configured AI backend. |
| 12 | Hafiz empty state/progress -> Quran/verse practice | Healthy | Empty state opens Quran; saved verse progress, due state and mastery persistence are tested. |
| 13 | Profile -> streak/achievements | Healthy | Both routes are wired and screens use real progress state. |
| 14 | Profile -> friends -> weekly league | Healthy with account dependency | Guest receives an honest sign-in state; backend users load real friends and leaderboard data, with retry/error states. |
| 15 | Profile -> reminders/settings/help/privacy | Healthy | Routes and external privacy URL are wired; failures show feedback. |
| 16 | Settings -> language/audio/reminder time/test notification | Healthy with permission dependency | State changes and reminder messaging are tested. Background delivery depends on OS/browser permission and push configuration. |
| 17 | Settings -> delete account/logout/start over | Healthy | Confirmation and local/backend cleanup paths are implemented; destructive actions require explicit confirmation. |
| 18 | Install -> PWA/APK | Healthy with platform limits | Installed state hides the home banner. PWA installation depends on browser support; Android APK download is exposed where available. App Store/Google Play installation is not claimed without signed store releases. |
| 19 | Muslingo+ plan selection | Non-blocking limitation | Plan selection works, but checkout is intentionally labelled "coming soon"; no fake purchase success is shown. |
| 20 | Unknown/deep-link routes | Healthy | Missing lesson/review and unknown routes render recoverable fallback screens instead of blank pages. |

## Fixes made in this audit

1. Replaced the labelled/pill bottom bar with an Instagram-style icon-only bar.
2. Added stable keys and a regression test that taps every bottom destination.
3. Preserved minimum 52px-high targets, screen-reader labels and hover/long-press tooltips.
4. Removed the decorative navigation shadow and active background capsule.
5. Updated navigation tests so hidden `IndexedStack` children do not create false failures.

## Verification

- Flutter static analysis: pass.
- Flutter tests: pass, including complete bottom-navigation traversal.
- API tests: 147 pass.
- Web production build: required before deployment and recorded in the release commit.

## Visual evidence limit

The production Flutter canvas remained interactive and exposed its semantic DOM,
but the in-app browser timed out on `Page.captureScreenshot`. Test-rendered PNGs
were rejected because the Flutter test font replaced user-facing glyphs. For that
reason this report does not present those images as valid visual evidence. Layout
health is instead backed by render tests at two mobile viewports; a real-device
screen-reader, microphone-permission and push-delivery pass remains necessary for
store certification.
