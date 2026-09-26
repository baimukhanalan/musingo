# Learning-flow audits

Run commands from the repository root. `flutter` is installed locally at
`/Users/alanbaimukhan/dev/flutter/bin/flutter` on the current workstation.

## Default coverage

```sh
flutter test --no-pub
```

All **1,148 Russian guided-lesson journeys remain enabled by default**:
1,002 Quran lessons (100 introductory + 902 full-Quran units), 100 Arabic,
36 Tajwid, and 10 Islam basics lessons. The complete-Quran path covers 114 surahs
and 6,236 ayahs; `LessonData.initialize()` must finish before counting the catalog.
The additional expensive journeys use deterministic boundary/long-copy samples:
first, middle, last, and longest text in each course/track (deduplicated).

| Widget journey | Default | Exhaustive |
| --- | ---: | ---: |
| Guided lessons, RU | 1,148 | 1,148 |
| Guided lessons, KK | 14 | 1,148 |
| Guided lessons, EN | 14 | 1,148 |
| Guided lessons, AR | 15 | 1,148 |
| Curriculum modules, RU | 16 | 570 |
| Curriculum modules, KK | 16 | 570 |
| Curriculum modules, EN | 16 | 570 |
| Curriculum modules, AR | 16 | 570 |
| Official-video card flows | 52 | 52 |
| Major-page initial renders | 288 | 288 |

The default totals are **1,191 guided-lesson journeys and 64 module journeys**.
The guided-lesson audit runs in groups of at most 50 lessons so each test has
bounded state and a useful failure location. The 2026-09-26 local release run
completed all 478 default Flutter tests, including every Russian lesson
(``/tmp/muslingo-release-full-sharded-20260926.log``).
Vercel's smaller builder runs every other Flutter test and the API suite before
building the site; the full guided-lesson walkthrough must also pass locally
before a production release.
Kazakh and English select 4 Quran + 4 Arabic + 3 Tajwid + 3 basics lessons;
Arabic selects 4 + 4 + 3 + 4. The longest-copy sample can change when translations
change. `audit_coverage_selection_test.dart` loads the complete catalog, checks
all four locales and these counts, verifies sample boundaries, and prints the
exact source-dependent matrix:

```sh
flutter test --no-pub --reporter expanded test/audit_coverage_selection_test.dart
```

These lesson/module counts were confirmed by the passing coverage report on
2026-09-26 (`/tmp/muslingo-coverage-final-20260926.log` on the current workstation).
That report validates selection/counting, not completion of all widget journeys.
The 52 video journeys are 13 catalog cards × 4 languages; the 288 page renders
are 18 pages × 4 languages × 4 viewport/text-scale configurations.

All modes also retain twelve module negative/retry/navigation journeys at
320/390/430 logical pixels and 1.5× text scale, four actual route close/re-entry/
back-to-library flows, unfinished-stage resume, and mid-step language switching.
Guided/module positive journeys rotate those
widths and sample 1.3× text scaling. The page smoke matrix uses 320×568 at 1×,
390×844 at 1.5×, 430×932 at 1×, and 844×390 landscape at 1×.
Test hosts install the production localization delegates and selected locale;
Arabic page, lesson, module, and video journeys explicitly verify RTL direction.

The flag does not reduce existing data-integrity, localization, safety,
completion, or gameplay tests. Those continue checking the complete catalogs.

## Exhaustive audit before a release

```sh
flutter test --no-pub --dart-define=MUSLINGO_EXHAUSTIVE_AUDIT=true \
  test/all_lessons_e2e_test.dart \
  test/all_curriculum_module_flows_test.dart \
  test/all_lesson_video_flows_test.dart \
  test/all_pages_responsive_test.dart \
  test/audit_coverage_selection_test.dart \
  test/arabic_terminology_regression_test.dart \
  test/learning_title_localization_test.dart
```

This mode exercises **4,592 guided-lesson journeys and 2,280 module journeys**
across Russian, Kazakh, English, and Arabic. The module journeys answer all five
challenges (11,400 answers), complete ordering
practice, verify saved completion/mastery, and check the next-module control.
Budget substantially more time than the default run; there is no early exit or
sampled curriculum in this mode. Additional API and physical/browser tests
remain separate.

## What these tests do not prove

- Lesson audio and speech are explicitly simulated to exercise replay, gating,
  controls, and progress. They do **not** prove a remote recording is reachable,
  audible, fast, or correctly transcribed on a real phone.
- Video openers are injected. Every official link and its failure/retry UI is
  checked, but this is not evidence that every YouTube video streamed.
- The 288 page configurations are initial-render smoke checks, not every action
  on all 18 pages. Rotated widths are not an exhaustive cross-product for every
  lesson and every device.
- Module save/mastery tests do not establish server-confirmed study-day or reward
  receipts. Client curriculum progress must not mint authenticated rewards.
- Native notification scheduling mocks and source checks do not prove lock-screen
  delivery, a working notification tap, device time-zone behaviour, permission
  dialogs, or background audio. Record simulator and physical-device checks
  separately, including whether the app was locked, backgrounded, or terminated.
- These numbers describe configured test coverage, not a completed run. Keep the
  run log, command/flags and result when reporting that an audit passed.
- Stable IDs, answer indexes and Arabic targets do not by themselves establish
  pedagogical, religious, or full four-language editorial accuracy.
