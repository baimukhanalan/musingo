# Learning-flow audits

Run commands from the repository root. `flutter` is installed locally at
`/Users/alanbaimukhan/dev/flutter/bin/flutter` on the current workstation.

## Default coverage

```sh
flutter test --no-pub
```

The original **246 Russian guided-lesson journeys remain enabled by default**.
The additional expensive journeys use deterministic boundary/long-copy samples:
first, middle, last, and longest text in each course/track (deduplicated).

| Widget journey | Default | Exhaustive |
| --- | ---: | ---: |
| Guided lessons, RU | 246 | 246 |
| Guided lessons, KK | 13 | 246 |
| Guided lessons, EN | 13 | 246 |
| Curriculum modules, RU | 16 | 570 |
| Curriculum modules, KK | 16 | 570 |
| Curriculum modules, EN | 16 | 570 |
| Official-video card flows | 36 | 36 |
| Major-page initial renders | 204 | 204 |

The default lesson total is **272**; the default module total is **48**.
`audit_coverage_selection_test.dart` asserts these exact current-data counts,
full-mode counts, and selection boundaries. Updating the source material can
change the longest-copy sample; review the matrix when this assertion changes.

All modes also retain nine module negative/retry/navigation journeys at
320/390/430 logical pixels and 1.5× text scale, three actual route close/re-entry/
back-to-library flows, unfinished-stage resume, and mid-step language switching.
Guided/module positive journeys rotate those
widths and sample 1.3× text scaling. The page smoke matrix uses 320×568 at 1×,
390×844 at 1.5×, 430×932 at 1×, and 844×390 landscape at 1×.

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

This completes **738 guided-lesson journeys and 1,710 module journeys**. The
module journeys answer all five challenges (8,550 answers), complete ordering
practice, verify saved completion/mastery, and check the next-module control.
Budget several minutes; there is no early exit or sampled curriculum in this
mode. Additional API and physical/browser tests remain separate.

## What these tests do not prove

- Lesson audio and speech are explicitly simulated to exercise replay, gating,
  controls, and progress. They do **not** prove a remote recording is reachable,
  audible, fast, or correctly transcribed on a real phone.
- Video openers are injected. Every official link and its failure/retry UI is
  checked, but this is not evidence that every YouTube video streamed.
- The 204 page configurations are initial-render smoke checks, not every action
  on all 17 pages. Rotated widths are not an exhaustive cross-product for every
  lesson and every device.
- Module save/mastery tests do not establish server-confirmed study-day or reward
  receipts. Client curriculum progress must not mint authenticated rewards.
- Stable IDs, answer indexes and Arabic targets do not by themselves establish
  pedagogical, religious, or full bilingual editorial accuracy.
