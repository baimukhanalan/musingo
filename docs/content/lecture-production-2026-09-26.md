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
The [shared URL availability checks](./lecture-source-url-checks-2026-09-27.json)
cover the twelve unique declared URLs: eleven official pages were reachable
when checked on 2026-09-27; the King Fahd Complex URL timed out, which is
**not** proof that it is broken. Page availability is separate from approval
of a religious claim, reuse rights or the exact source-to-objective match.
The ledger generator strips punctuation after two Corpus `.jsp` addresses in
the original plan so review links do not end in a stray semicolon.

## Baseline on 2026-09-26

| Track | Planned topics | Unique plan locators | Substantive lecture drafts | Human-approved new lectures |
| --- | ---: | ---: | ---: | ---: |
| Quran | 150 | 25 | 1 | 0 |
| Arabic | 170 | 68 | 1 | 0 |
| Tajwid | 70 | 1 | 0 | 0 |
| Foundations/Academy | 180 | 18 | 1 | 0 |
| **Total** | **570** | **112 within-track** | **3** | **0** |

The original editorial drafts are [`FND-001`](./lectures/FND-001.json),
[`QUR-001`](./lectures/QUR-001.json) and
[`ARB-001`](./lectures/ARB-001.json). Each exceeds 650 Russian words and has
paragraph-level source IDs, rights notes and an explicit review status. They
are **not in the app** and must not be labelled approved religious lectures.
The new Quran draft deliberately teaches only the verse map, without copying
or interpreting a translation. The Arabic draft uses original practice letter
pairs and the [Unicode Arabic joining rules](https://www.unicode.org/versions/Unicode17.0.0/core-spec/chapter-9/)
alongside the Quranic Arabic Corpus's phonetic reference; it does not claim
teacher-validated pronunciation or Quran example selection.

The current plan contains 70 Tajwid modules whose source string says exact
chapter/page mapping is pending. The 150 Quran modules have an exact surah range
but explicitly have no selected translation/tafsir. Many foundations modules
reuse a strand-level locator across ten different learning objectives. These
are legitimate planning references, not sufficient evidence for ten distinct
full-length lectures.
Two Arabic modules (ARB-169 and ARB-170) do not yet have even a direct source
URL or exact verse locator in their plan rows; the ledger flags them explicitly.
None of the 170 Arabic plan rows records a module-specific Quran word or verse
locator, even when a general Quranic Arabic Corpus documentation page is named.
The ledger distinguishes those linguistic references from exact examples.

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
  substitute for a pronunciation teacher. Its
  [data-download terms](https://corpus.quran.com/download/) also require
  attribution and preservation of the verbatim corpus file; product use needs
  a rights review rather than assuming that a public page is freely adaptable.
- The draft for FND-001 uses the exact locators
  [16:43](https://quran.com/16/43) and [49:6](https://quran.com/49/6), reads
  them in context, and does not republish Quran.com's translation or tafsir.
  An editor must still review its use of those verses.
- King Fahd Complex's *Al-Tajwid al-Muyassar* is a proposed Tajwid reference.
  The plan has not mapped its 70 titles to exact pages, and an accessible
  download is not evidence of adaptation or audio rights. A qualified Tajwid
  teacher must choose and verify the actual examples.

Rechecked against the publishers' own pages on 2026-09-27: Quran Foundation's
[Connected Apps policy](https://api-docs.quran.com/docs/connected-apps/)
explicitly requires human review for pre-generated AI religious content and
real, resolvable citations for religious claims. This is a potential partner
policy, not a statement that Muslingo has been approved as a Connected App.
The [Apple Speech documentation](https://developer.apple.com/documentation/speech/)
describes transcription and confidence outputs; those outputs are not a source
for Tajwid certification. The TAJ-001 research brief keeps that distinction.

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
