# Muslingo Product and Pedagogy Benchmark

## Executive conclusion

Muslingo does not have too few lesson records for an MVP. It has **246 lessons**: 100 Quran, 100 Arabic, 36 Tajwid, and 10 Islam foundations. The larger problem is that a lesson count does not prove a complete curriculum, reliable placement, durable retention, valid pronunciation feedback, or safe religious guidance.

The catalogue is uneven. The Quran and Arabic tracks are numerically substantial, and 36 Tajwid lessons can cover the core rule map. Ten Islam foundations lessons are materially too shallow for the product promise. Across all tracks, the main competitive gaps are diagnostic routing, item-level mastery, cumulative transfer assessment, qualified human review, source governance, child safeguards, and evidence that speech feedback measures what the interface claims.

No reviewed product owns the complete combination. Tarteel is strongest in error-directed hifz; HIFZ and Sadr in scheduled memorization; Naml in parent-led child practice; Quran.com in trustworthy Quran infrastructure; Arabic101 in qualified correction; AlifBee in Arabic depth and placement; Quranic in Quranic-Arabic retrieval; Yaqeen in scholarly review; Zad in curriculum breadth and cumulative assessment; Duolingo, Busuu, Memrise, Anki, and Pimsleur in learning mechanics. Muslingo's opportunity is to combine those strengths without pretending that automated word matching is certified tajwid instruction.

## Scope and evidence rules

Research cutoff: **11 September 2026**. The companion CSV contains 37 products and official product, help-center, policy, curriculum, or documentation pages. The sample spans Quran readers, memorization tools, Tajwid products, Quranic Arabic, Islamic studies, child learning, teacher-led programs, and general learning-method benchmarks.

Evidence labels are applied as follows:

- **Confirmed** means an official page or first-party document explicitly describes the capability.
- **Not confirmed** means no adequate official evidence was found in the reviewed public material. It does not prove the feature is absent.
- **Inference** is an analyst judgment derived from confirmed product behavior; it is not presented as a vendor claim or efficacy result.
- Marketing terms such as “AI,” “personalized,” “mastery,” and “tajwid feedback” receive no extra credit unless the public material explains the learner signal, task, or limitation.
- Product scores below are comparative judgments, not controlled efficacy measurements.

Public access is not a content license. Competitor lessons, videos, recordings, translations, quizzes, illustrations, and curriculum wording must not be copied into Muslingo without an applicable license or written permission. Official sources can inform clean-room structure and product mechanics.

## Muslingo baseline

The repository inventory records the following current state:

| Track | Lessons | Source coverage in inventory | Current interpretation |
| --- | ---: | ---: | --- |
| Quran | 100 | 11.0% of steps sourced; 20 lessons have a source URL | Good numerical base, weak lesson-level provenance |
| Arabic | 100 | 83.2% of steps sourced; no lesson-level source URL | Broad base, but source metadata is not consistently attached at lesson level |
| Tajwid | 36 | 100% of steps sourced; all 36 have a source URL | Topic breadth is plausible; assessment validity remains the harder gap |
| Islam foundations | 10 | 9.1% of steps sourced; all 10 have a source URL | Far below the promised breadth and age-specific depth |

These percentages describe metadata presence, not scholarly approval, licensing, learning effectiveness, or translation quality.

## Market map

### Quran reading and trusted content

**Quran.com** is the strongest infrastructure benchmark. Its official platform exposes Quran text, translations, tafsir, word-level data, recitations, search, OAuth-based user features, and offline content sync. Its current developer requirements also establish unusually clear expectations for provenance, least-privilege access, account deletion, sensitive religious data, and restrictions on training AI with user content.

**Quran Majeed**, **Qariah**, and **Muslim Pro** add useful reader and audio patterns: configurable repetition, multiple reciters, offline listening, riwayat representation, translations, playlists, and memorization buckets. These are valuable consumption and practice tools, but none of them publicly demonstrates a complete adaptive learning model.

**Inference for Muslingo:** use Quran.com or equivalently licensed authoritative datasets as the content substrate. Keep Muslingo's own value in diagnosis, practice, assessment, review, and explanation rather than rebuilding an unverified Quran corpus.

### Memorization and retention

**Tarteel** is the strongest current benchmark for hidden-text recall, historical mistakes, recency-aware weak-item tests, word/tashkeel mismatch feedback, recordings, and hifz analytics. Its own documentation provides the correct product boundary: fixed tajwid colors and word/tashkeel recognition are not the same as reliable live tajwid assessment.

**HIFZ** and **Sadr** expose a more explicit review model. HIFZ describes Sabaq, Sabqi, and Manzil; Sadr states that it combines adaptive SRS, voice recognition, and a personalized path. **Mualim** is especially useful because its official wording explicitly limits detection to Quran word/verse mismatches and says it does not assess tajwid or pronunciation.

**Naml** is the strongest child-hifz benchmark. It uses short parent-led sessions, listen-shadow-solo-recite phases, three mastery levels, mandatory cooldowns, separate child profiles, and parent-confirmed exams. It explicitly marks AI oral review as future work instead of advertising an unfinished feature as current.

**Inference for Muslingo:** the hifz product should be a persistent ayah-level review engine, not another fixed course. Every ayah needs separate recall strength, last review, error history, next due date, confidence, listening exposure, and teacher/parent confirmation state.

### Tajwid and speech feedback

**Learn Quran Tajwid** offers the clearest compact syllabus: 23 topics with a repeated Theory -> Practice -> Test structure. **TajweedMate** extends from letters to major tajwid rules and describes an offline recording workflow with explicit opt-in before a user donates audio for model training. **Arabic101** remains the strongest quality benchmark because qualified teachers provide direct correction, lesson reports, periodic exams, personalized plans, and four-week progress reviews.

The evidence does not support treating any reviewed consumer AI as equivalent to an ijazah holder or qualified tajwid teacher. A system may accurately identify the wrong ayah, missing word, or some vowel mismatches while still failing to evaluate makhraj, sifat, timing, waqf, breath, regional variation, or subtle rule application.

**Inference for Muslingo:** split the speech result into separately named signals:

1. Verse/word sequence match.
2. Tashkeel or vowel-pattern match where technically validated.
3. Timing and pause observations.
4. Probable phoneme issue with confidence and replay evidence.
5. Teacher-reviewed tajwid result.

Only the fifth state should be presented as qualified human tajwid correction. Automated scores need a published test set by age, gender, microphone class, accent, noise, surah, error type, and unseen speaker.

### Arabic learning

**AlifBee** is the depth leader in app-native Arabic: official material claims more than 1,000 lessons across 26 levels, four skills, placement, personal dictionary, spaced repetition, chatbot practice, self-assessment, and teacher-supported virtual school. **Busuu Arabic** documents 135+ lessons and 60+ hours from A1 to B2, with community feedback and AI review, but its official placement-test language list does not include Arabic. **Quranic** is narrower but more directly relevant: Quran vocabulary, grammar, stories, translation practice, customizable quizzes, and explicit spaced repetition.

**Arabic Unlocked**, **Understand Al Quran Academy**, **Bayyinah TV**, and **Arabic101** cover complementary strengths: gamified Quranic vocabulary, school pathways, deep meaning and explanation, and teacher correction. None alone combines all four Arabic skills with Quranic morphology, hifz, tajwid, and source-governed faith learning.

**Inference for Muslingo:** 100 Arabic lessons are not inherently too few, but they are not a complete Arabic program unless they have explicit exit outcomes. A defensible first pathway should state what a learner can decode, hear, produce, and understand after each level and should use unseen transfer items rather than recycling the taught example.

### Faith learning

The ten Muslingo foundations lessons are the clearest quantity gap. **Safar** provides a longitudinal child curriculum with age bands, textbooks, workbooks, teachers, and a writing/review process. **Yaqeen Curriculum** provides middle- and high-school units with learning objectives, lesson plans, presentations, worksheets, assessments, scholar approval, peer review, and a public correction/archive workflow. **Zad Academy** provides a two-year, four-semester adult curriculum across seven subjects, with 24-36 lectures per subject per semester and weekly, monthly, and final exams.

**SeekersGuidance**, **AMAU**, **Qalam**, and **Muslim Pro Academy** add structured scholarly tracks, junior programs, long-form audio, live classes, and topic breadth. The products differ in theological and legal scope; Muslingo cannot merge their wording into a supposedly neutral course without declaring doctrine, madhhab handling, reviewer authority, and rights.

**Inference for Muslingo:** expand foundations only after the governance model exists. More unsourced AI-generated religious lessons would increase risk rather than quality.

## Pedagogy and product-mechanics benchmark

Scale: 0 absent/not evidenced, 1 basic, 2 structured, 3 strong, 4 defining. Scores are inferences based on the cited official evidence.

| Product | Placement | Adaptive path | SRS/retention | Speech | Human review | Curriculum depth | Assessment | Child safety | Offline/audio |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Tarteel | 1 | 3 | 3 | 4 | 0 | 2 | 4 | 1 | 3 |
| HIFZ | 1 | 3 | 4 | 3 | 1 | 3 | 3 | 1 | 2 |
| Sadr | 1 | 3 | 4 | 3 | 0 | 3 | 3 | 1 | 3 |
| Naml | 2 | 3 | 4 | 0 | 4 parent | 3 | 4 | 4 | 2 |
| Quran.com | 0 | 1 | 1 | 0 | 0 | 4 reference | 1 | 2 | 4 |
| Learn Quran Tajwid | 1 | 1 | 0 | 1 | 1 | 4 tajwid | 3 | 1 | 2 |
| TajweedMate | 1 | 1 | 0 | 3 | 0 | 3 tajwid | 3 | 2 | 4 |
| Arabic101 | 2 | 4 teacher | 1 | 4 human | 4 | 4 | 4 | 2 | 2 |
| Quranic | 1 | 2 | 4 | 0 | 0 | 4 Quranic Arabic | 3 | 1 | 3 |
| AlifBee | 4 | 3 | 4 | 3 language | 4 optional | 4 | 4 | 3 | 0 |
| Busuu Arabic | 0 Arabic | 3 | 3 | 3 language | 3 community | 4 | 3 | 1 | 3 |
| Duolingo Arabic | 1 | 4 | 4 | 2 language | 0 | 3 | 3 | 3 | 3 |
| Memrise | 1 | 3 | 4 | 3 language | 0 | 3 | 3 selected | 1 | 0 |
| Pimsleur | 0 | 1 | 4 | 3 language | 0 | 3 | 2 | 1 | 4 |
| Yaqeen Curriculum | 2 age | 3 teacher | 0 | 0 | 4 | 4 | 4 | 4 | 3 |
| Zad Academy | 1 | 2 gated | 1 | 0 | 3 | 4 | 4 | 1 | 2 |
| Safar | 3 age | 2 teacher | 1 | 1 human | 4 | 4 | 4 | 4 | 2 |

## What Muslingo is missing

### P0: quality gates before adding hundreds of lessons

1. **Real placement.** Diagnose letter recognition, sound discrimination, decoding, slow reading, known surahs, meaning, recall, and recitation separately. Route to the first unmet prerequisite. A goal-selection screen is not placement.
2. **A knowledge graph.** Track letter, grapheme form, vowel, word, root, grammar concept, ayah, translation, tajwid rule, phoneme, and faith concept independently. A completed lesson must not mark every underlying skill mastered.
3. **Evidence-based review.** Store attempts, hints, response time, confidence, lapse count, last review, and due date. Generate daily work from weakness and forgetting risk, not from catalogue order alone.
4. **Valid speech claims.** Separate word recognition from pronunciation and tajwid. Publish thresholds and error categories. Keep recordings private by default and require distinct consent for retention or model improvement.
5. **Qualified review.** Add asynchronous teacher review for selected recordings and scheduled audits of AI-labelled mistakes. Give users a correction appeal route.
6. **Cumulative transfer assessment.** Use unseen letters, words, ayat, mixed-rule passages, continuation prompts, delayed free recall, and explanation tasks. Avoid answer choices that reveal the solution through length or wording.
7. **Religious-content governance.** Every claim needs source, locator, translation/edition, authenticity category where applicable, madhhab/aqidah scope, author, language reviewer, Islamic reviewer, rights state, review date, and correction history.

### P1: production trust and reach

8. **Age-banded foundations.** Separate child, teen, new-Muslim, and adult tracks. Do not expose children to public profiles, open chat, unrestricted voice sharing, or behavioral advertising.
9. **Accessibility.** Test screen-reader order, Arabic pronunciation labels, dynamic text, contrast, reduced motion, keyboard navigation, captions, transcripts, color-independent tajwid cues, and a no-microphone path.
10. **Offline-first core.** Download assigned Quran text, approved translations, lesson audio, today's reviews, and pending attempts. Queue sync safely and make content version/provenance visible after reconnecting.
11. **Pricing boundary.** Keep Quran text, essential pronunciation models, basic review, deletion/export, and safety controls free. Charge for advanced analytics, expanded plans, family dashboards, teacher review, and premium audio—not for correcting a learner's religious text after an error.
12. **Outcome analytics.** Measure delayed recall, unseen transfer, error recurrence, teacher agreement with AI, review return rate, and next-week retention. XP and streak are engagement metrics, not learning outcomes.

## Recommended curriculum expansion

The following is a product recommendation, not a sourced market fact.

| Track | Current | Recommended production target | Why |
| --- | ---: | ---: | --- |
| Quran reading and short-surah study | 100 | 120-150 polished units | Add diagnostic branches, unseen decoding, meaning, context, delayed recall and mixed assessments |
| Arabic | 100 | 180-220 units across explicit levels | Add morphology, grammar, listening, production, Quranic frequency bands, cumulative reviews and exit tests |
| Tajwid | 36 | 60-80 units | Keep the 23-36 rule map but add contrastive listening, rule transfer, timed practice, waqf, mixed passages and teacher-reviewed checkpoints |
| Islam foundations | 10 | 80-120 age-banded units | Cover belief, Quran literacy, worship, seerah, prophets, ethics, hadith literacy, source literacy and contemporary scenarios with declared scope |
| Hifz | Not meaningfully measured by lessons | Full 114-surah/ayah review engine | Hifz depth should be measured by supported ayat, review state and retention, not lesson count |

This yields roughly **440-570 polished instructional units**, plus a full-Quran memory engine. The target should not be reached by templating shallow questions. Every added unit needs a defined prerequisite, learning outcome, transfer item, delayed-review item, source record, reviewer, accessibility variant, and measurable completion rule.

## Recommended learning architecture

1. **Diagnostic session:** 2-4 minutes, confidence-aware and skippable, with separate sub-scores.
2. **Daily plan:** two due reviews, one weak-skill repair, one new item, one meaning task, and one optional voice task.
3. **Instruction loop:** hear -> notice -> guided practice -> retrieval -> explain -> recite -> targeted feedback -> retry.
4. **Mastery threshold:** multiple correct attempts across different contexts and at least one delayed attempt; never one multiple-choice answer.
5. **Review loop:** FSRS-like item scheduling for vocabulary/concepts; Sabaq-Sabqi-Manzil constraints for hifz; teacher-set overrides for recitation.
6. **Assessment:** short level checks plus cumulative free recall and unseen transfer.
7. **Escalation:** probable speech issue -> replay and micro-drill -> persistent issue -> teacher review; personal religious ruling -> qualified scholar.
8. **Audit trail:** content version, source, reviewer, model version, confidence, user correction, and teacher disposition.

## Build, partner, and license decisions

### Build internally

- Learner model, knowledge graph, daily recommendation engine, spaced review, lesson runtime, attempts, accessibility variants, progress integrity, and child account controls.
- Original micro-interactions and assessments written from approved source material.
- Transparent speech-result UI and evaluation harness.

### Integrate under explicit terms

- Quran text, translations, tafsir, word metadata, and recitation metadata from Quran Foundation or another edition-specific authorized provider.
- Speech infrastructure only with strict retention, region, consent, deletion, and model-training controls.

### Partner

- Qualified tajwid teachers for rubric design, evaluation data, disagreement review, and learner escalation.
- A scholarly/editorial board for faith content, corrections, and translation review.
- Age-specific curriculum experts for child and teen foundations.

### Do not scrape into the product

- Proprietary competitor lessons, paywalled videos, quizzes, illustrations, coursebooks, teacher recordings, or translations.
- YouTube audio/video outside permitted playback/embed terms.
- Religious explanations without edition-level citations and reviewer approval.

## Decision

Muslingo should not respond to the market by simply changing “246 lessons” to a larger number. The next production milestone is a **trusted mastery system**:

- a placement result that changes the path;
- an ayah/skill memory model that changes tomorrow's lesson;
- speech feedback whose scope is technically honest;
- teacher and scholar review for high-stakes cases;
- age-safe foundations content;
- cumulative assessment that proves delayed recall and transfer;
- source and correction metadata visible to the learner.

After those foundations are in place, expand first in this order: Islam foundations, Arabic level depth, Tajwid practice labs, Quran meaning/context, then full Hifz coverage. This sequence closes the largest quality gaps without turning Muslingo into a generic Islamic super-app.

## Official source index

The companion CSV provides row-level sources and separates confirmed evidence, missing evidence, and inference. Core official sources used for the principal conclusions include:

1. Tarteel Help Center, [Tarteel Features](https://support.tarteel.ai/en/collections/15105266-tarteel-features) and [Free vs Premium](https://support.tarteel.ai/en/articles/12267535-can-i-use-tarteel-for-free).
2. Quran Foundation, [Developer documentation](https://api-docs.quran.com/), [Content Sync](https://api-docs.quran.com/docs/tutorials/content-sync/getting-started/), and [Developer Privacy Policy Packet](https://api-docs.quran.com/legal/developer-privacy/).
3. HIFZ, [Product](https://gethifz.com/) and [Support](https://gethifz.com/support).
4. Mualim, [Official product page](https://mualim-app.com/en).
5. Sadr, [Terms](https://sadr.app/terms) and [Privacy](https://sadr.app/privacy).
6. Naml, [Product and pedagogy](https://naml-app.com/en) and [Pricing](https://naml-app.com/en/pricing).
7. TajweedMate, [Product](https://tajweedmate.com/) and [Privacy](https://tajweedmate.com/privacy.html).
8. Learn Quran Tajwid, [Curriculum](https://tajwid.learn-quran.co/).
9. Quranic, [Learner product](https://www.getquranic.com/learners/) and [Pricing](https://www.getquranic.com/pricing/).
10. AlifBee, [Product](https://www.alifbee.com/en), [Placement](https://help.alifbee.com/hc/en-us/articles/9421698273821--Placement-test), and [Premium curriculum](https://store.alifbee.com/products/alifbee-premium).
11. Arabic101, [Courses](https://academy.arabic101.org/courses/) and [teacher-led plans](https://academy.arabic101.org/tiersplans3/).
12. Arabic Unlocked, [App method](https://arabicunlocked.com/) and [Academy](https://arabicunlocked.com/academy/).
13. Busuu, [Arabic course](https://www.busuu.com/en/course/learn-arabic-online) and [Placement Test](https://help.busuu.com/hc/en-gb/articles/16526383831569-What-is-a-Placement-Test).
14. Duolingo, [learner model](https://blog.duolingo.com/how-we-learn-how-you-learn/) and [spaced repetition](https://blog.duolingo.com/spaced-repetition-for-learning/).
15. Memrise, [method](https://www.memrise.com/about) and [current app changes](https://www.memrise.com/blog/changes-to-memrise-app).
16. Yaqeen Institute, [Curriculum](https://yaqeeninstitute.org/curriculum) and [Scholarly Rigor](https://yaqeeninstitute.org/about-us/our-commitment-to-scholarly-rigor).
17. Zad Academy, [Curriculum](https://zad-academy.com/en/curriculum) and [Exams](https://support.zad-academy.com/en/275805-Exams).
18. Safar, [Curriculum](https://www.safaracademy.org/curriculum/) and [Islamic Studies Primary](https://safarpublications.org/islamic-studies-primary/).
19. Pimsleur, [Official method and product](https://www.pimsleur.com/).
20. LingQ, [Mobile/SRS/offline](https://www.lingq.com/en/ios-app/) and [teacher workflow](https://www.lingq.com/en/schools/).
21. Quizlet, [Younger-user safeguards](https://help.quizlet.com/hc/articles/360029923632/) and [assessment boundary](https://help.quizlet.com/hc/en-au/articles/360030640912-Student-activity-data).
22. Anki, [Scheduler background](https://docs.ankiweb.net/background.html) and [deck options](https://docs.ankiweb.net/deck-options.html).
