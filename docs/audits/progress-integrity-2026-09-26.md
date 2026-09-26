# Progress integrity review — 2026-09-26

## Guest-to-account boundary

The live `/api/progress/sync` caller deliberately applies `sanitizeGuestImport`
before `mergeLearningState`. Guest learning preferences can transfer, but
client-only completion claims, XP, streaks, ayah counts and study time are not
accepted as verified rewards or unlocks. The new `totalStudySeconds` field is
cleared alongside `totalMinutes`. This policy has **not** been weakened.

A direct call to the pure merge helper with unsanitized guest data is not an
end-to-end signup reproduction. An initial review found old helper caps of
1,000 lessons/300 ayahs and absent seconds merging. That finding was reclassified
after tracing the actual HTTP caller. The visible product limitation is broader:
verified guest-to-account progress transfer requires durable receipts and is a
separate task. This iteration does not add private/unverified history silently.

## Corrections within the existing boundary

- The merge helper recognizes exactly the same 1,148 guided lesson IDs as the
  completion route; lesson counts use unique known IDs and Quran progress uses
  the union of canonical ayah addresses (at most 6,236).
- Existing server progress is no longer truncated by old guest import caps.
- Server study time, including sub-minute remainder, has priority. Old minute
  histories migrate to seconds. Guest-only helper inputs remain bounded by the
  existing three-attempts-per-known-lesson budget and the 7,200-second attempt
  ceiling; repeated merges use the maximum, never additive double counting.
- Existing server reward receipts take priority over guest history, preserving
  completion replay guards. An older guest study date cannot move the server's
  last study date backwards.

## Verification scope

`server_test/progress-import-registry.test.js` covers registry parity, sanitized
signup behavior, preservation of all 1,148/6,236 existing server counts, exact
seconds/remainders, duplicate/unknown IDs and retained receipt replay guards.
These are deterministic helper/caller-boundary tests, not a live database signup
or device test. The account-transfer limitation remains explicit above.
