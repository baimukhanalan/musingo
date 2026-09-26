# 570 lectures: source and publication readiness

This document separates the **570-topic curriculum plan** from finished
lecture manuscripts. The plan's `published_owner_verified` field records the
owner's earlier curriculum review; it does not certify the accuracy, rights,
translation or audio of any newly written lecture. Run
`node tool/audit_lecture_readiness.mjs` for the current machine-readable audit.
The [per-module source ledger](./lecture-source-ledger-570.json) covers all
570 IDs with the original locator, discovered URLs/verse references,
provenance, rights flags and open gates. It is reproducible using
`node tool/build_lecture_source_ledger.mjs`; `--check` detects stale output.
Its links are **declared, not automatically verified source-to-claim matches**.
Four manually checked research briefs are in
[`lecture-next-batch-2026-09-26.json`](./lecture-next-batch-2026-09-26.json).

## Baseline on 2026-09-26

| Track | Planned topics | Unique plan locators | Substantive lecture drafts | Human-approved new lectures |
| --- | ---: | ---: | ---: | ---: |
| Quran | 150 | 25 | 0 | 0 |
| Arabic | 170 | 68 | 0 | 0 |
| Tajwid | 70 | 1 | 0 | 0 |
| Foundations/Academy | 180 | 18 | 1 | 0 |
| **Total** | **570** | **112 within-track** | **1** | **0** |

The first original, approximately 700-word editorial draft is
[`FND-001.json`](./lectures/FND-001.json). It is **not in the app** and must
not be labelled an approved religious lecture. It demonstrates paragraph-level
source IDs, exact verse links, rights notes and an explicit review status.

The current plan contains 70 Tajwid modules whose source string says exact
chapter/page mapping is pending. The 150 Quran modules have an exact surah range
but explicitly have no selected translation/tafsir. Many foundations modules
reuse a strand-level locator across ten different learning objectives. These
are legitimate planning references, not sufficient evidence for ten distinct
full-length lectures.
Two Arabic modules (ARB-169 and ARB-170) do not yet have even a direct source
URL or exact verse locator in their plan rows; the ledger flags them explicitly.

## Verified source roles and rights

- The [Tanzil text license](https://tanzil.net/docs/Text_License) permits
  attributed, unchanged copies of its Arabic text under CC BY 3.0. It does not
  clear a translation, commentary or reciter's recording.
- [Quran Foundation's developer terms](https://api-docs.quran.com/legal/developer-terms/)
  allow in-app display via the specified integration subject to attribution,
  context, caching and resource-specific conditions. Quran Foundation content
  must not be scraped or packaged as a new Muslingo dataset. Its
  [Connected Apps policy](https://api-docs.quran.com/docs/connected-apps/)
  calls for verifiable rights and extra scrutiny of AI-generated religious
  content.
- The [Quranic Arabic Corpus phonetic reference](https://corpus.quran.com/documentation/phonetic.jsp)
  is a language reference, not blanket permission to copy the corpus or a
  substitute for a pronunciation teacher.
- The draft for FND-001 uses the exact locators
  [16:43](https://quran.com/16/43) and [49:6](https://quran.com/49/6), reads
  them in context, and does not republish Quran.com's translation or tafsir.
  An editor must still review its use of those verses.
- King Fahd Complex's *Al-Tajwid al-Muyassar* is a proposed Tajwid reference.
  The plan has not mapped its 70 titles to exact pages, and an accessible
  download is not evidence of adaptation or audio rights. A qualified Tajwid
  teacher must choose and verify the actual examples.

## Production gate for each topic and language

1. Resolve each claim to a precise edition, verse, hadith or page, recording
   the source's role (primary evidence, commentary, linguistic reference or
   pedagogical benchmark). Replace strand-level or pending locators.
2. Write an original lecture of appropriate length, with paragraph-level
   source links. Separate text, translation, interpretation, school-specific
   positions and practical advice. Record valid differences instead of
   flattening them into a single answer.
3. Add exercises that test the actual lecture, not recognition of the module
   title or plan metadata. Do not create a source question whose answer is a
   generic landing page.
4. Record independent Islamic/Arabic/Tajwid review where applicable, language
   review for RU/KK/EN/AR, rights clearance, revision hash and re-review date.
5. Record a licensed human voice or publish a text lecture. Quran recitation
   requires a separately cleared qualified reciter and riwayah. Synthetic
   speech must never be represented as Quran recitation or teacher-verified
   Tajwid.
6. Only then mark the lecture approved and connect it to “Учиться” and, if
   audio exists, “Слушать”. Listening alone must not award lesson mastery.

Do not generate 569 remaining manuscripts by expanding the plan's objectives.
That would produce long but ungrounded prose. The next editorial batch should
first resolve sources and commission human review for a small set across all
four tracks; the same schema and validator can then scale safely.
