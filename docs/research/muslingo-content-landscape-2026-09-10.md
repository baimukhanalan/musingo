# Muslingo Content Landscape and Curriculum Gap Analysis

## Executive conclusion

Muslingo does not have too few lesson records. It has too little independently
verified curriculum breadth behind some of those records.

The application currently exposes 246 lessons and 2,664 lesson steps. That is a
credible product surface for an early release. However, 32 of the 100 Quran
lessons are generated reinforcement versions of earlier lessons, and 78 of the
100 Arabic lessons are three repeated phases around 26 letter units. The
effective breadth is therefore materially lower than the headline count.

The strongest existing area is the 36-lesson Tajwid course: every lesson has a
source URL, source references, listening, a knowledge check, matching, and a
pronunciation step. The weakest area is Foundations of Islam: ten lessons, no
listening-choice or word-order work, only one Quran-audio step, and incomplete
per-step sourcing. Quran lessons cover 602 unique Quran ayah references after
challenge enrichment, about 9.7% of the 6,236-ayah corpus, while only 33 of the
100 lessons have dedicated listening-choice and word-order exercises.

The strongest area structurally also contains the most urgent rights risk. All
36 Tajwid lessons currently point to Understand Al-Quran's “Learn Tajweed the
Easy Way” course. Its published terms prohibit copying or reproducing site
content without permission. Before production publication, Muslingo needs either
a written commercial adaptation license or a clean-room rewrite by its own
authors, approved by named qualified Tajwid reviewers.^16

The right next move is not to scrape and publish every available Islamic page or
video. That would create copyright, attribution, doctrinal, and quality risks.
The right move is to maintain an extensible source registry, compare curricula,
license or link to suitable materials, and commission original Muslingo lessons
through a documented scholarly review workflow.

## Research scope and limitations

This review combines:

1. A runtime export of every current Muslingo course, lesson, and step from
   `LessonData.getCourses()`.
2. A metadata-only harvest of 28 priority sources across Quran data, Quranic
   Arabic, Tajwid, memorization, Islamic studies, and learning-product design.
3. Direct review of primary product pages and official documentation.
4. Comparative research delegated across Quran/Tajwid, Arabic, Islamic studies,
   and product competitors.

There is no finite, defensible definition of “all Islamic materials on the
internet.” Search indexes change continuously, many courses require accounts or
payment, and public access does not imply a right to copy or adapt. The included
harvester therefore stores titles, descriptions, URLs, HTTP status, and a reuse
classification, not full copyrighted pages or videos. It can be extended by
adding reviewed seed URLs.

Snapshot date: 10 September 2026.

## Current Muslingo inventory

| Track | Lessons | Steps | Avg. steps | Fully sourced lessons | Lessons with source URL | Pronunciation | Listening choice | Word order |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Quran | 100 | 1,632 | 16.32 | 20 | 20 | 100 | 33 | 33 |
| Arabic | 100 | 714 | 7.14 | 84 | 0 | 100 | 84 | 84 |
| Tajwid | 36 | 252 | 7.00 | 36 | 36 | 36 | 36 | 0 |
| Foundations | 10 | 66 | 6.60 | 0 | 10 | 7 | 0 | 0 |
| **Total** | **246** | **2,664** | **10.83** | **140** | **66** | **243** | **153** | **117** |

“Fully sourced” means every step has at least one `sourceRefs` value. It does not
mean that the cited material is licensed, independently reviewed, or sufficiently
specific. For example, 78 Arabic letter-phase lessons cite an internal Muslingo
curriculum marked for expert review rather than an external authoritative source.

### What is already strong

- Every lesson has a valid completion path and at least one exercise.
- Every Quran and Arabic lesson includes pronunciation practice.
- The Tajwid sequence covers makharij, major letter qualities, qalqalah, ghunnah,
  nun sakinah/tanwin, mim sakinah, madd, lam, ra, and waqf.
- The Quran reader exposes all 114 surahs and protects the embedded Arabic text
  with canonical Tanzil comparison.
- The lesson engine supports text, audio, questions, matching, speech,
  word-order, and listening-choice steps.
- The application already has the right product primitives for spaced review,
  daily plans, Hafiz mode, and personalized recommendations.

### Where the count overstates depth

- Quran lessons 69-100 are reinforcement variants of lessons 1-32, not 32 new
  surah or skill units.
- Arabic lessons 23-100 use the same seven-step template in three phases for 26
  letter units. This is useful practice, but it does not replace vocabulary,
  morphology, grammar, or comprehension progression.
- Only 20 Quran lessons have complete per-step source metadata.
- The course reaches selected material from surahs 58-114 and Al-Baqarah 1-2,
  rather than a coherent staged route through wider Quran comprehension.
- Foundations contains only ten broad introductions. It cannot yet support the
  promised Academy or a serious beginner Islamic-studies pathway.
- RU/KZ/EN localization covers UI more than reviewed educational content.

## External source landscape

### Quran text, translation, tafsir, and audio

**Quran Foundation** is the strongest candidate for a production content
integration. Its current Content API includes Quran text, chapters, verses,
translations, tafsir, audio, recitations, word-level resources, and search. Its
terms require attribution and place limits on caching and redistribution; a
commercial application may display content, but may not resell or redistribute
raw datasets without the appropriate agreement.^1 ^2

**Tanzil** remains suitable for an embedded canonical Arabic text. Its Quran text
is CC BY 3.0, must remain verbatim, and requires attribution plus a link to track
updates.^3 This matches Muslingo’s current use, but the app should also retain the
license notice in distributed assets and automate upstream-version checks.

**QuranEnc** is a stronger candidate than an unversioned translation feed for
reviewed meaning translations because it exposes named editions and versioned
downloads in many languages, including Russian and Kazakh. Every chosen edition
still needs its own visible attribution and reuse record.

For recitation audio, the **King Fahd Glorious Quran Printing Complex** provides
an official governed source. Muslingo should archive the rights statement for
each selected recording, store the reciter and riwaya explicitly, and not infer
that one general developer page licenses every file or offline redistribution.

**Al Quran Cloud / Islamic Network CDN** currently supplies Muslingo metadata,
the Elmira Kuliev meaning translation, transliteration, and Alafasy audio. The
technical integration validates ayah counts and numbering, which is good. The
remaining problem is rights provenance: each translation, transliteration, and
recitation needs an explicit license record rather than only a provider name.

### Memorization and recitation products

**Tarteel** is the strongest direct benchmark for Quran recitation and hifz. Its
published feature set includes real-time missed/incorrect/skipped word detection,
memorization planning, mistake history, mistake playback, verse peeking,
analytics, goals, custom ranges, repeated audio, multiple mushafs, and cross-device
sync.^4 Muslingo’s transcript-based score is not yet equivalent to this word-level
recitation feedback. Tarteel’s own roadmap also shows demand for spaced-repetition
tests, Tajwid mistake detection, and random-place memorization testing.^5

**Quranly** is a strong habit benchmark rather than a teaching benchmark. It
centers daily reading goals, time/verse tracking, streaks, reading levels, and
private family/friend competition.^6 Muslingo already has most motivational
primitives, but should use them to schedule mastery evidence, not merely visits.

**Qariah** contributes a distinctive catalog of women reciters and has published
time-bounded hifz programs. Its Surah As-Sajdah curriculum combines daily meaning,
memorization, and review.^7 Any recitation or worksheet reuse would require direct
permission.

### Arabic literacy and Quranic Arabic

**Madinah Arabic** publishes a free 23-part Arabic reading route and then directs
learners into grammar.^8 Its main lesson for Muslingo is progression beyond
letter recognition: script fluency must lead to words, sentence patterns,
vocabulary, morphology, and grammar.

**Duolingo’s Arabic reading tools** are useful for interaction design. Its
official description shows explicit training of letter forms and tracing with a
finger.^9 Muslingo currently has no writing or tracing step, and no spatial
assessment of connected letter forms.

**Quranic Arabic Corpus** is a high-value reference for word-by-word morphology,
syntax, and grammatical structure. It should be treated as a licensed/reference
dataset whose copyright and attribution are verified before ingestion, not as
text to copy opportunistically.

**Bayyinah**, **Arabic101**, and structured Madinah-book video series are useful
benchmarks for Quranic vocabulary, grammar, rhetorical explanation, stopping and
starting, and applied recitation. Subscription or public-video availability does
not grant adaptation rights. The practical route is linking/embedding under the
platform terms, obtaining a partnership, or writing original lessons against
primary Quran and language references.

### Islamic studies

**SeekersGuidance** provides a multi-level curriculum spanning beliefs, law,
spirituality, Quranic studies, and Arabic, taught by trained scholars and made
free to enroll.^10 It is a strong structure benchmark, but its jurisprudential
tracks must be represented accurately and its course material cannot be assumed
redistributable.

**Yaqeen Curriculum** offers scholar-approved, teacher-developed units with
learning objectives, presentations, worksheets, and assessments. Units are
typically three to five 50-minute lesson plans and target middle/high-school
audiences.^11 It is especially strong for contemporary faith questions and
critical discussion, but its materials are proprietary and need licensing or a
partnership.

No single external curriculum should become the Muslingo curriculum. A safe
product needs a neutral common-core layer, clearly labeled jurisprudential or
scholarly differences, original mobile pedagogy, and named reviewers.

## Competitor comparison

Scores are analytical judgments on a five-point scale based on public product
documentation. They are not laboratory measurements.

| Product/source | Guided curriculum | Quran reading | Hifz/review | Speech feedback | Meaning/Arabic | Source trust | Main lesson for Muslingo |
|---|---:|---:|---:|---:|---:|---:|---|
| Tarteel | 3 | 5 | 5 | 5 | 2 | 4 | Word-level recitation evidence and mistake history |
| Quran.com / Quran Foundation | 2 | 5 | 2 | 1 | 5 | 5 | Verified content and explicit integration terms |
| Quranly | 2 | 4 | 2 | 1 | 2 | 3 | Daily habit loop and private accountability |
| Qariah | 2 | 4 | 3 | 1 | 2 | 3 | Reciter diversity and bounded memorization programs |
| Duolingo Arabic | 5 | 2 | 3 | 3 | 3 | 3 | Writing-system drills, tracing, adaptive repetition |
| Madinah Arabic | 4 | 3 | 2 | 2 | 4 | 3 | Reading-to-grammar progression |
| Bayyinah | 4 | 3 | 2 | 1 | 5 | 4 | Quranic vocabulary, grammar, and thematic meaning |
| Arabic101 | 4 | 4 | 2 | 2 | 4 | 3 | Applied Tajwid, waqf/ibtida, visual explanations |
| SeekersGuidance | 5 | 3 | 2 | 1 | 4 | 4 | Multi-level scholar-led Islamic studies |
| Yaqeen Curriculum | 5 | 2 | 1 | 1 | 4 | 4 | Objectives, worksheets, assessment, youth relevance |
| Sajda | 2 | 4 | 2 | 1 | 3 | 3 | Broad ecosystem, but not Muslingo’s focused advantage |
| Muslingo now | 3 | 4 | 3 | 2 | 2 | 2 | Strong product shell; curriculum governance must catch up |

## Missing curriculum

### Priority 0: trust and governance

1. A source registry for every educational claim, translation, audio file, and
   generated explanation.
2. Rights status: public domain, open license, API terms, paid license,
   partnership, link-only, or prohibited.
3. Named Islamic reviewer, Arabic reviewer, audio reviewer, review date, and
   version for every published module.
4. A declared reading scope, initially Hafs an Asim, with no accidental mixing of
   qira’at or mushaf conventions.
5. A policy for differences of opinion: common core first, labeled views and
   scholar escalation where needed.
6. Citation display inside lessons, not only a source button at course level.
7. Verified RU/KZ/EN content localization; never machine-translate Quran text or
   a reviewed translation automatically.

### Priority 1: complete the learning engine

1. A real placement diagnostic for letters, harakat, connected reading,
   vocabulary, meaning, memorization, and recitation.
2. A prerequisite knowledge graph instead of a single linear order.
3. Per-skill mastery scores and scheduled retrieval practice.
4. Cumulative checkpoints that sample old and new material.
5. Random-start, continue-the-next-ayah, hidden-text, and delayed-recall hifz
   tests.
6. Error memory by letter, word, rule, ayah, meaning, and recall interval.
7. Writing/tracing for Arabic letters and connected forms.
8. Minimal-pair listening tests before pronunciation attempts.
9. Word-level recitation alignment; separate memorization accuracy from Tajwid
   coaching and never claim phoneme correctness from transcript similarity alone.
10. Teacher-review export for attempts that automated scoring cannot judge.

### Priority 1: Quran course

1. Replace generic reinforcement copies with purpose-built retrieval sessions.
2. Give every selected surah a consistent sequence: context, listening, chunked
   reading, key vocabulary, meaning, pronunciation, memorization, delayed review,
   and mastery test.
3. Add per-ayah segmentation for Juz Amma before extending breadth into longer
   surahs.
4. Add root and morphology notes for high-frequency Quranic words.
5. Add thematic links and carefully reviewed context without turning lessons into
   free-form tafsir generation.
6. Add comparison of nearby ayahs and commonly confused endings.
7. Add stopping/starting decisions where meaning can change.
8. Store exact translation edition and reciter resource IDs in lesson metadata.

### Priority 1: Arabic course

1. Handwriting and tracing for all 28 letters and their joining forms.
2. Complete coverage of hamza forms, alif maqsura, ta marbuta, dagger alif, and
   Quranic orthographic marks.
3. Progressive syllable decoding and timed fluency checks.
4. A high-frequency Quranic vocabulary deck with audio and root families.
5. Pronouns, demonstratives, gender, number, definiteness, and adjective
   agreement.
6. Nominal and verbal sentence patterns.
7. Attached pronouns, prepositions, particles, and common Quranic connectors.
8. Introductory morphology: roots, patterns, past/present/imperative, active and
   passive participles.
9. Word-by-word parsing and short-ayah comprehension.
10. Dictation, audio discrimination, and reading without transliteration.

### Priority 1: Tajwid course

1. Add applied word-order/segmentation where it supports stopping and meaning.
2. More minimal-pair listening for close makharij.
3. Separate recognition, isolated production, word production, and ayah transfer.
4. Add rule-density practice: one ayah containing several target rules.
5. Add common-error clips and learner diagnosis.
6. Add waqf and ibtida scenarios where different stops alter or obscure meaning.
7. Add cumulative oral checkpoints and teacher escalation.
8. Attach a reviewed audio exemplar to every pronunciation target.

### Priority 1: Foundations and Academy

The current ten lessons should become an introductory module, not the whole
course. Missing modules include:

- How Islamic knowledge and sources are classified.
- Quran and Sunnah; what tafsir and hadith grading mean.
- Six pillars of faith, five pillars of Islam, and ihsan in greater depth.
- Purification and prayer as clearly labeled, reviewed learning tracks.
- Fasting, zakat, Hajj, and Umrah fundamentals.
- Seerah from early life through the major Meccan and Medinan stages.
- Major prophets with Quran references and clear separation from folklore.
- Character: truthfulness, trust, parents, neighbors, speech, anger, repentance,
  gratitude, patience, and mercy.
- Daily worship literacy: intention, dua, dhikr, and respectful Quran study.
- New-Muslim pathway and age-appropriate teen pathway.
- Ramadan, Dhul Hijjah, prayer, and Al-Fatiha time-bounded academies.
- Digital ethics, media literacy, mental health boundaries, and when to consult a
  scholar or clinician.

## Recommended target architecture

Do not set “500 lessons” as the product goal. Set independently reviewable skill
outcomes, then let the lesson count follow.

| Track | Current | Recommended next reviewed release | Definition |
|---|---:|---:|---|
| Quran learning path | 100 | 160 | 80 new/reworked skill lessons + 80 scheduled retrieval/mastery sessions |
| Arabic/Quranic Arabic | 100 | 180 | 60 literacy, 50 vocabulary, 40 morphology/grammar, 30 comprehension |
| Tajwid | 36 | 72 | 36 concepts + 24 applied transfer labs + 12 cumulative oral checks |
| Foundations/Academy | 10 | 120 | 15 modules of 6 lessons plus 30 review/case lessons |
| **Total** | **246** | **532** | Every lesson source-complete and review-versioned |

This is a target curriculum architecture, not permission to bulk-generate 286
religious lessons. The first release gate should be 60 reworked or new lessons:
20 Quran, 20 Arabic, 10 Tajwid transfer labs, and 10 Foundations lessons. That is
large enough to prove quality without creating an unreviewable content backlog.

## Content production workflow

1. **Discover:** save source metadata and rights status only.
2. **Select:** map a source to a specific learning objective and audience.
3. **License:** confirm whether the item may be quoted, adapted, embedded, linked,
   or only used as background research.
4. **Author:** create original Muslingo explanations and exercises.
5. **Content review:** check pedagogy, answer ambiguity, difficulty, and age fit.
6. **Islamic review:** verify claims, citations, terminology, and differences of
   opinion.
7. **Language review:** review Arabic and each RU/KZ/EN version independently.
8. **Audio review:** verify reciter, text alignment, pronunciation target, and
   recording rights.
9. **QA:** run structural tests and complete each lesson through the app.
10. **Publish:** store reviewer, date, source version, rights version, and content
    hash.
11. **Monitor:** accept corrections and unpublish affected lessons quickly.

## Required data-model additions

Each publishable lesson or claim should carry:

```text
source_id
source_type
source_title
source_url
publisher_or_author
edition_or_hadith_grade
license_type
license_url
reuse_scope
language
doctrinal_scope
jurisprudential_scope
review_status
islamic_reviewer
arabic_reviewer
audio_reviewer
reviewed_at
source_version
content_hash
correction_status
```

The CMS should reject publication when rights, source specificity, or required
review fields are missing. `sourceRefs: ['Muslingo curriculum']` is not adequate
for a production religious-learning claim.

## Immediate implementation backlog

### Week 1-2: source integrity

- Import the source catalog into a proper CMS table.
- Resolve the exact reuse terms for Al Quran Cloud, Kuliev translation,
  transliteration, Islamic Network audio, MP3Quran audio, and every Tajwid source.
- Add per-step source metadata to the 80 incomplete Quran lessons and all ten
  Foundations lessons.
- Replace internal “expert review required” references with reviewed records.
- Add source and license validation to CI.

### Week 3-6: depth pilot

- Rebuild Al-Fatiha and five short surahs using the full nine-stage learning loop.
- Add 20 Arabic bridge lessons from letters into high-frequency Quran vocabulary.
- Add ten Tajwid transfer labs with minimal pairs and ayah practice.
- Add ten Foundations lessons on sources, worship basics, seerah, and character.
- Test difficulty and ambiguity with target learners, not only automated tests.

### Week 7-12: personalized evidence

- Add placement diagnostics and concept-level mastery.
- Replace duplicate review lessons with generated schedules over reviewed tasks.
- Add random recall and continuation tests to Hafiz mode.
- Add word-aligned recitation analysis and explicit uncertainty.
- Build reviewer dashboards and correction/unpublish workflows.

## Repository artifacts

- `muslingo-content-inventory-2026-09-10.json`: complete runtime lesson/step
  inventory.
- `islamic-source-seeds.json`: reviewed seed list and preliminary reuse status.
- `islamic-source-metadata-2026-09-10.json`: metadata-only harvest results.
- `islamic-source-catalog-2026-09-10.csv`: spreadsheet-ready source catalog.
- `tool/export_lesson_inventory.dart`: reproducible internal curriculum exporter.
- `tool/harvest_source_metadata.mjs`: bounded metadata harvester.
- `agents/Muslingo_Quran_Content_Research_2026-09-10.xlsx`: 22-resource,
  20-gap, 56-source Quran and Tajwid research workbook.
- `agents/muslingo_quranic_arabic_course_research_2026-09-10.md`: detailed
  Quranic-Arabic curriculum comparison; its companion CSV contains direct URLs.
- `agents/muslingo-islamic-studies-curricula-research.md`: 36-source comparison
  of Islamic-studies curricula and a reviewed pilot outline.
- `agents/muslingo-competitive-pedagogy-2026-09-10.md`: 12-product learning
  mechanics and competitor analysis with 55 cited sources.

## Sources

1. Quran Foundation. [API Reference](https://api-docs.quran.com/docs/api-reference/). Accessed 10 September 2026.
2. Quran Foundation. [Frequently Asked Questions](https://api-docs.quran.com/docs/tutorials/faq/). Accessed 10 September 2026.
3. Tanzil Project. [Quran Text License](https://tanzil.net/docs/Text_License). Accessed 10 September 2026.
4. Tarteel. [Premium features and pricing](https://tarteel.ai/en/pricing). Accessed 10 September 2026.
5. Tarteel. [Public roadmap and feature requests](https://feedback.tarteel.ai/). Accessed 10 September 2026.
6. Quranly. [Habit-building Quran app](https://www.quranly.app/). Accessed 10 September 2026.
7. Qariah. [Surah As-Sajdah curriculum](https://qariah.app/Surah_Sajdah_Curriculum.pdf). Accessed 10 September 2026.
8. Madinah Arabic. [Arabic Reading Course](https://madinaharabic.com/free-content/reading). Accessed 10 September 2026.
9. Duolingo. [Learning other writing systems](https://blog.duolingo.com/learning-other-writing-systems/). Accessed 10 September 2026.
10. SeekersGuidance. [Academy curriculum](https://academy.seekersguidance.org/?redirect=0&track=odc). Accessed 10 September 2026.
11. Yaqeen Institute. [Yaqeen Curriculum](https://yaqeeninstitute.org/curriculum). Accessed 10 September 2026.
12. Quran Foundation. [Connected Apps requirements](https://api-docs.quran.com/docs/connected-apps/). Accessed 10 September 2026.
13. Quran Foundation. [Content Sync](https://api-docs.quran.com/docs/tutorials/content-sync/getting-started/). Accessed 10 September 2026.
14. Tarteel. [Feature documentation](https://support.tarteel.ai/en/collections/15105266-tarteel-features). Accessed 10 September 2026.
15. Yaqeen Institute. [The morality toolkit](https://yaqeeninstitute.org/curriculum/the-everyday-ethics-of-life/the-morality-toolkit). Accessed 10 September 2026.
16. Understand Al-Quran Academy. [Terms and Conditions](https://understandquran.com/term-conditions/). Accessed 10 September 2026.
17. QuranEnc. [Translations of the meanings of the Quran](https://quranenc.com/en/home). Accessed 10 September 2026.
18. King Fahd Glorious Quran Printing Complex. [Hafs recitations](https://qurancomplex.gov.sa/category/moratal/hafs/). Accessed 10 September 2026.
