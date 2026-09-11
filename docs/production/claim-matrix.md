# Muslingo product claim matrix

Updated: 2026-09-11

This file is the publishing boundary for the website, store listings, press,
partnerships, and in-product copy. A claim may move to a stronger category only
after the named evidence exists.

## Supported now

| Claim | Evidence required and present |
| --- | --- |
| Muslingo offers a local first-use experience without registration. | Guest onboarding and local persistence are covered by widget and state tests. |
| The diagnostic scores letters, decoding, surah recall, meaning, and tajwid knowledge separately and changes the recommended start. | Deterministic item scoring, persisted skill profile, and route-selection tests. |
| The curriculum contains 100 Quran, 100 Arabic, 36 Tajwid, and 10 Islam-foundation lessons. | Catalog invariant and full lesson-flow tests. |
| Every speech exercise requires the learner to play the sample first and allows another recording after success. | Dedicated positive and retry widget tests. |
| Failed speech attempts do not permanently block a lesson. | Dedicated two-failure and skip test; the skip is recorded as a weak step. |
| Voice is used for recognition only after consent when server processing is needed, and Muslingo does not retain the submitted recording. | Client consent dialog, bounded API payload, no persistence path, and API tests. |
| Completed learning data can be exported without account credentials or voice recordings. | Export-schema and exclusion tests. |
| A guest can safely merge a Muslingo export while XP, streak, identity, tokens, and voice data are ignored. | Import preview, schema validation, allow-listed lesson IDs, and merge tests. |
| Daily reminders use the due queue and selected learning goal and open the assigned daily path. | Reminder selection tests and notification route handling. |

## Beta or limited claims

| Claim | Required qualifier |
| --- | --- |
| AI pronunciation feedback | Educational word/phrase matching with a confidence score. It is not a qualified tajwid assessment and may make recognition errors. |
| AI Coach | Uses the learner profile and approved source links when the configured provider is available; otherwise the app uses its local recommendation engine. It does not issue fatwas. |
| Email verification and password recovery | Product and API flows are implemented. Delivery is available only after a verified sender and `RESEND_API_KEY` are configured. |
| Android download | A CI-built test APK may be offered. Store-ready release signing requires the owner's keystore and Play Console process. |
| iOS and lock-screen widget | Native targets exist. Distribution and final device behavior require Apple signing and physical-device validation. |
| Kazakh and English | Interface localization is available. Faith-content translations must not be described as complete until expert review is recorded. |

## Prohibited until independently proven

- "Muslingo detects every tajwid or makhraj mistake."
- "More accurate than Tarteel, Quranly, Quranic, Sajda, or any named product."
- "Qualified teacher replacement" or "scholar-approved" without named reviewers and versioned records.
- Guaranteed spiritual, medical, financial, or material outcomes from a surah or ayah.
- "Available in the App Store" or "Available on Google Play" before the public listings are live.
- "All content is fully verified" before every faith claim has a source locator, rights state, reviewer, version, and correction history.
- "Your recording never leaves the device" when server transcription is enabled and consented.
- Retention, learning, speech-accuracy, or competitor-switching numbers without a documented production cohort and methodology.

## Evidence promotion rule

Product analytics, speech evaluation, and religious review evidence must be
versioned, reproducible, privacy-reviewed, and tied to the exact released build.
Screenshots, development mocks, passing builds, and internal opinions are not
enough to promote a limited claim to a supported claim.
