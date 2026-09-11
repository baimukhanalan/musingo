# Muslingo strategic implementation status

Updated: 2026-09-11

This status maps the 22 moves in the competitor-research backlog to the current
production candidate. It is intentionally stricter than a feature checklist.

## Release candidate

| Move | Status | Current evidence or remaining gate |
| --- | --- | --- |
| Production readiness gates | Partial | Identity recovery, authoritative lesson receipts, voice privacy, quotas, and native projects are implemented. Email delivery, signed store builds, physical-device QA, and expert ownership remain external gates. |
| Diagnostic that changes the path | Implemented | Five separate skill scores persist locally and alter the starting course and recommendation. A production learning-outcome experiment is still needed. |
| Honest speech contract | Implemented within stated scope | Sample-first, consent, retry, confidence, failure feedback, safe skip, no server retention, and distributed quotas are covered. Phoneme-level tajwid grading remains out of scope until a validated model and teacher rubric exist. |
| One daily decision | Implemented | The home action combines the recommendation, due review, weak skill, and current course. Notification taps open the assigned daily path. |
| Source and reviewer trust layer | Partial | Quran and selected lesson source locators plus source-grounded coach links exist. Named reviewers, rights ledger, correction history, and 100% coverage require CMS and expert operations. |
| Switching diagnostic | Partial | Existing learners can demonstrate skills and start beyond lesson one without importing competitor credentials. The optional source-app question and seven-day switching report are not yet productized. |
| Claim discipline | Implemented as governance | `docs/production/claim-matrix.md` defines supported, limited, and prohibited claims. Publishing approval remains an organizational responsibility. |
| Ayah and skill memory engine | Implemented foundation | Per-item knowledge and Hafiz schedules, weak-step capture, and due review exist. Longitudinal D30 validation remains outstanding. |
| Meaning inside recitation | Implemented in lesson loop | Quran lessons combine listening, meaning, retrieval, ordering, and speech where authored. Licensed multilingual translation coverage remains an editorial gate. |
| RU-KZ market wedge | Partial | RU/KZ/EN interface selection is real and persistent. Complete reviewed KZ faith content and regional speech evaluation are not yet complete. |
| Ethical retention system | Implemented foundation | Due-aware reminders, quiet user-controlled settings, rollback on scheduling failure, varied text, and non-blocking hearts are present. Production experimentation needs consented analytics. |
| Progress portability | Implemented for Muslingo local mode | Safe JSON export, preview, and guest merge exclude rewards and secrets. Cloud account imports remain server-authoritative. |
| No-account value before registration | Implemented | Diagnostic, recommendation, first lesson, progress, XP, and memory work locally before account creation. |
| Audio learning mode | Partial | Listen, repeat, voice response, and audio explanations exist per lesson. A continuous interruption-safe hands-free session is not yet complete. |
| Quran Foundation Connected Apps | External partnership | Requires approval, OAuth scope agreement, rights review, and a published integration contract. No scraping or competitor credential collection will be used. |

## Deliberately not presented as complete

The following moves are partner or operations programs rather than features that
can be truthfully finished in one repository pass: private teacher escalation,
teacher and mosque cohorts, family safeguarding, public evidence dashboard,
competitor transition marketing pages, scholar marketplace, and institutional
mastery API. They remain in the 6-12 month backlog until identity, payments,
moderation, privacy, evidence volume, and qualified reviewers are in place.

## Automated release evidence

- Flutter static analysis: clean.
- Flutter tests: 167 passing, including every step of all 246 lessons.
- API tests: 181 passing.
- Catalog: 100 Quran, 100 Arabic, 36 Tajwid, and 10 Islam-foundation lessons.
- Known production dependency vulnerabilities must be checked again immediately
  before each release.

## External owner inputs still required

1. A verified sending domain plus `RESEND_API_KEY` and `MUSLINGO_EMAIL_FROM`.
2. Android upload keystore secrets and Google Play Console access for an AAB.
3. Apple Developer membership, certificates, profiles, and App Store Connect access.
4. Physical iPhone and Android acceptance checks for microphone permissions,
   notification delivery, lock-screen copy, widgets, offline behavior, and upgrades.
5. Named qualified reviewers, review scope, source rights, versioning, and a
   correction process for Quran translation, tajwid, and Islamic-studies content.
6. Legal entity, payment recipient, terms, refund policy, and store billing setup
   before Muslingo+ or donations can accept money.
