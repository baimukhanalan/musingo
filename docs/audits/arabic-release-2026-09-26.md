# Arabic and mobile verification — 26 September 2026

## Implemented scope

- Arabic is a Settings language (also offered during first-time onboarding).
  Material localizations provide right-to-left layout and system dialogs.
- Arabic UI copy, notification copy, daily tips, native widget fallback and
  layout direction, coach suggestions and offline replies are included.
- All 902 new Quran reading units use Arabic instructions and preserve every
  original ayah byte-for-byte. The 570-topic catalog has Arabic titles and
  objectives. These are not new scholarly translations or recorded lectures.
- The original 246 guided lessons do not yet have a complete Arabic body
  translation. A first-step notice discloses this; source content is never
  replaced with an unrelated generic translation.

## Provider checks and configuration

No API key is stored in this report, app assets, source code, or test fixtures.
The existing local OpenAI key returned `429 / credit_balance_exhausted`.
Adding credits is an owner action, not a code fix.

The user supplied an Atria key and identified its issuer. A server-only adapter
uses the documented `Atria-Dawn-Preview` model and fixed HTTPS endpoint. It is
selected only by `COACH_AI_PROVIDER=atria` with `ATRIA_API_KEY`; credentials alone
do not silently change the recipient of learner conversations. Explicit Atria
mode never forwards failed requests to another vendor.

Live checks used only synthetic, non-personal greetings/study questions:

- Non-streaming Chat Completions: no response within 30 seconds.
- Responses: no response within 55 seconds.
- Streaming Chat Completions: HTTP 200 after about 8.7 seconds, but stream did
  not finish within 25 seconds. This is not proof of a usable full answer.
- A further bounded streaming check returned no headers or content within
  55 seconds.

Therefore Atria is implemented but **not enabled as the production provider**.
The 18-second application timeout and visible offline fallback prevent an
unbounded spinner. No zero-retention promise is made for Atria. Review its
data-processing terms and repeat latency/answer-quality checks before enabling
it for real learner conversations. Its text API does not replace the separate
speech-transcription provider.

Provider contract: https://api.atria-asi.ai/docs

## Native evidence

On the iPhone 17 Pro iOS 26.5 simulator, a daily reminder was set through the
app UI to 21:20. Muslingo was backgrounded and the screen locked. The reminder
arrived at 21:20 with private-preview content hidden. Screenshot evidence:
`/tmp/muslingo-simulator-20260926/scheduled-reminder-locked.png`.

The initial notification-open action resumed Settings rather than the lesson.
Inspection found the missing iOS notification-center delegate and background
plugin registrant. Both have been added; native retesting is required after
rebuilding. Simulator delivery does not establish physical-iPhone reliability,
multi-day delivery, Focus-mode behavior, or widget installation by the user.

Cold-start routing now guards against the splash timer replacing an opened
lesson, and the notification handler explicitly requests a frame. A regression
opens the production handler at 1450 ms: it passes with the guard and fails
after the splash timeout without it. At 23:59, a coincident evening reminder
is skipped while the independent ayah schedule is preserved. The combined
routing, schedule, and onboarding suite passes all 15 tests.

## Release-candidate checks

- Static analysis: no issues.
- Latest focused suite: 45 tests passed, including 16 persistence/account-switch
  completion cases, onboarding, notification wiring, and coverage selection.
- Backend suite: 246 tests passed, including the opt-in Atria contract.
- Additional focused suites passed: 50 module/video/content/native tests and
  43 selected KK/EN/AR lesson journeys under actual Material locale delegates.
- A prior full run found two onboarding layout failures; the layout was fixed
  and its targeted tests now pass. A fresh full suite remains a deployment
  gate; these focused results do not replace that gate.

## Verification boundaries

Data tests verify all 114 surahs / 6236 ayahs and all 570 catalog entries.
Widget journeys simulate lesson audio and speech. They do not prove every
remote audio recording is audible or every video streams. Arabic UI coverage
does not constitute theological review of translated educational content.
