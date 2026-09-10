# Muslingo Video and Audio Content Landscape

## Executive summary

The verified registry contains **70 distinct public collections**: 29 official YouTube channels or playlists and 41 institutional, teacher-led, product, developer, or audio-library collections. Every row points to a direct public primary page rather than a search-results page. The inventory is deliberately a metadata and partnership registry; it does not copy, download, transcribe, or redistribute third-party media.

The market does not suffer from a shortage of Quran videos. It suffers from fragmentation. High-quality recitation, tajwid explanation, Quranic-Arabic courses, live teachers, hifz tools, and child-friendly animation usually live in separate products. The core opportunity for Muslingo is therefore not to accumulate a larger media shelf, but to turn carefully licensed media and expert-reviewed micro-content into one adaptive loop: diagnose, listen, imitate, record, explain the probable error, retry, schedule revision, and escalate uncertain cases to a teacher.

The strongest immediately actionable source is the [King Fahd Complex audio library](https://qc-dev.qurancomplex.gov.sa/quran-audios/), whose page expressly permits the listed digital recitations to be used free of charge in applications and websites. The strongest integration candidates after contractual review are [Quran.com/Quran.Foundation](https://quran.com/about-us?locale=en), [MP3Quran](https://www.mp3quran.net/eng/api), and the dataset-specific resources in [QUL](https://qul.tarteel.ai/docs/tutorial-recitation-end-to-end). The strongest teaching and partnership benchmarks are [Arabic101 Quran Mastery](https://academy.arabic101.org/course-2-quran-mastery/), [Maqraa Al-Harmain](https://maqraa.prh.gov.sa/en), [Riwaq Al Quran](https://riwaqalquran.com/courses/recitation-with-tajweed/), [Kalimah Center](https://kalimah-center.com/), [Understand Al-Quran](https://understandquran.com/learn-tajweed-the-easy-way-english/), and [Bayyinah Dream Arabic](https://explore.bayyinahtv.com/arabic/).

## Scope and method

Included sources had to satisfy all of the following:

- a direct public URL to an official site, channel, playlist, course, service guide, API, or institutional document;
- meaningful video, audio, live audiovisual instruction, or voice-learning functionality relevant to Quran reading, tajwid, hifz, or Quranic Arabic;
- identifiable publisher or teacher authority, with official-site cross-linking, institutional domain, named instructors, or published credentials;
- enough primary-page evidence to classify language, topic, format, learner level, quality indicators, currentness, access, and rights posture;
- a distinct collection URL, with no search pages or duplicated URLs.

YouTube channel identity was checked through the channel's canonical ID. Where a public Atom feed returned an item, its latest publication date was recorded as a currentness signal. A missing or old feed item is reported as a limitation rather than interpreted as evidence that a course is unavailable. Playlist names and publishers were checked through YouTube oEmbed.

The research does **not** assert that a publisher's educational or religious claims are correct merely because they appear on an official page. Teacher credentials, chains of transmission, institutional affiliations, testimonial claims, and scholarly review processes require documentary due diligence before a partnership or publication decision.

## Registry profile

| Segment | Collections | What it contributes | Principal limitation |
|---|---:|---|---|
| Official YouTube channels and playlists | 29 | Discoverability, demonstrations, long-form teaching, animation, multilingual samples | Standard YouTube access is not a commercial reuse license |
| Structured self-paced or cohort courses | 17 | Sequencing, prerequisites, assessments, workbooks, outcomes | Mostly proprietary; often too long for daily mobile learning |
| Live teacher and government platforms | 12 | Talaqqi, correction, placement, certification, ijazah pathways | Scheduling, cost, capacity, and no reusable lesson-media rights |
| Native audio/API/data candidates | 6 | Recitation audio, timings, riwayat, metadata | Recording-level licenses and provenance still vary |
| Voice and hifz product benchmarks | 6 | Recitation matching, revision scheduling, testing and progress | Proprietary algorithms; tajwid scoring often limited or opaque |
| **Total** | **70** |  |  |

The 70-row count refers to distinct collections, not 70 unrelated companies. Multiple entries from one publisher are retained only where they are genuinely different products or curated playlists, such as Arabic101's recitation-mastery playlist versus its Quranic-Arabic course.

## Current Muslingo baseline

The current product inventory at `docs/research/muslingo-content-inventory-2026-09-10.json` reports **246 lessons and 2,664 steps** across four courses:

| Muslingo course | Lessons | Steps | Audio | Speak | Listen choice | Word order | Source-linked evidence in inventory |
|---|---:|---:|---:|---:|---:|---:|---|
| Quran | 100 | 1,632 | 830 | 108 | 33 | 33 | 11.0% of steps; 20 lessons with a course source URL; 602 unique ayat referenced |
| Arabic | 100 | 714 | 97 | 100 | 84 | 84 | 83.2% of steps marked sourced, but no course-level source URL |
| Tajwid | 36 | 252 | 36 | 36 | 36 | 0 | 100% of steps marked sourced; 36 lessons with source URLs; only 19 unique ayat referenced |
| Foundations of Islam | 10 | 66 | 1 | 7 | 0 | 0 | 9.1% of steps marked sourced; 10 lessons carry a course source URL |

This confirms that raw lesson count is no longer the main bottleneck. The Quran course is large but still needs stronger source traceability and a more deliberate progression from listening to independent recitation. Tajwid has complete source flags but a comparatively narrow example set and only one listen-choice plus one speaking step per lesson. Arabic has stronger interaction variety, yet the absence of course-level source URLs makes editorial provenance harder to audit. The source registry should therefore drive a quality and provenance pass before it drives another bulk lesson-count increase.

## Highest-value findings

### 1. Rights-safe native audio is scarce but not absent

The [King Fahd Complex audio page](https://qc-dev.qurancomplex.gov.sa/quran-audios/) is unusually clear: it states that the listed digital recitations are made available for free general use in computer applications, websites, broadcast channels, and private or government works inside and outside Saudi Arabia. The Complex also describes specialist supervision of its Quran audio recordings on its [organizational page](https://qurancomplex.gov.sa/en/kfgqpc/kfq-structure/). Muslingo should archive the exact rights statement, retrieval date, reciter, riwayah, source URL, file checksum, and any file-level notice before ingestion.

[MP3Quran](https://www.mp3quran.net/eng/contact-us) states that rights are available to everyone and permits copying site material or using its URLs. Its [API](https://www.mp3quran.net/eng/api) exposes reciters, riwayat, surah coverage, radio, and multilingual metadata. That is promising but less precise than the King Fahd statement for commercial offline packaging, so Muslingo should request written confirmation covering native apps, caching, offline downloads, derivatives such as timed segmentation, and commercial subscription use.

[Quran.com](https://quran.com/about-us?locale=en) provides high-quality recitations, word-level follow-along, translations, and a developer program under Quran.Foundation. Its developer terms and Connected Apps rules govern caching, attribution, commercial limits, and synchronization. The correct route is approved API integration, not scraping. [QUL](https://qul.tarteel.ai/docs/tutorial-recitation-end-to-end) is highly useful for gapped/gapless recitation and word/ayah timing, but each dataset has its own license; QUL explicitly warns against hotlinking audio and the repository's MIT license does not grant rights to every dataset.

### 2. YouTube is a player and discovery layer, not a content warehouse

YouTube's [official license guidance](https://support.google.com/youtube/answer/2797468?hl=en) says the Standard YouTube License is the default and that only videos explicitly marked Creative Commons Attribution provide that separate reuse route. YouTube itself cannot grant rights to somebody else's upload. Its [Terms of Service](https://uk.youtube.com/t/terms) permit showing videos through the embeddable YouTube player but prohibit downloading, reproducing, altering, or otherwise using content outside the permitted service or written authorization.

For Muslingo, the safe default is:

1. Store only permitted metadata and the canonical YouTube video or playlist ID.
2. Play through the official YouTube player, include the full `origin`, and preserve controls/attribution.
3. Handle player errors `101`/`150` as “embedding disabled by owner,” as documented in the [IFrame Player API](https://developers.google.com/youtube/iframe_api_reference).
4. Never download, cache, isolate audio, suppress attribution, rehost, or cut a lesson into Muslingo steps without written permission or a verified per-video CC BY license.
5. Recheck availability, license, publisher, and embedability before publication because channels and settings change.

This makes official YouTube collections excellent for optional “watch the teacher” enrichment and content benchmarking, but unsuitable as the default offline course corpus.

### 3. The best pedagogy is teacher-corrected and mastery-gated

[Arabic101 Quran Mastery](https://academy.arabic101.org/course-2-quran-mastery/) publishes the clearest progression in this sample: literacy, practical recitation, applied tajwid, itqan, and ijazah. It identifies lesson volumes, prerequisites, outcomes, active listening, teacher correction, quizzes, and mastery gates. Its companion [Quranic-Arabic track](https://academy.arabic101.org/course-3-how-to-understand-the-quran-in-arabic/) sequences high-frequency vocabulary through 50%, 65%, and 85% coverage.

[Understand Al-Quran's Tajweed course](https://understandquran.com/learn-tajweed-the-easy-way-english/) packages each concept as watch, read, write, test, worksheet, and exam. [Riwaq Al Quran](https://riwaqalquran.com/courses/recitation-with-tajweed/) publishes a ten-level path from letters through advanced ijazah and requires the teacher to confirm mastery by ear before progression. [Studio Arabiya](https://studioarabiya.com/lp/tajweed-courses/), [Kalimah Center](https://kalimah-center.com/), and [Maqraa Al-Harmain](https://maqraa.prh.gov.sa/en) similarly combine placement, direct correction, structured levels, and progress records.

Muslingo should adopt the principles, not copy the materials: explicit prerequisites; listen-before-record; minimal-pair discrimination; immediate retry; cumulative review; and human escalation when the model is uncertain.

### 4. Hifz products expose an important honesty boundary

[Tasmi](https://www.tasmi.app/) clearly states that it checks words, not tajwid. That is a model for trustworthy product language. [Tarteel](https://tarteel.ai/) demonstrates voice follow-along, memorization testing, and mistake highlighting, while its support material distinguishes product modes. [HIFZ](https://gethifz.com/support) translates the traditional Sabaq/Sabqi/Manzil balance into listen-read-repeat-recall and scheduled review.

Muslingo should separate three scores in both UI and data:

- **text match**: omissions, additions, substitutions, and order;
- **timing/fluency signals**: pauses, duration, restart stability, and pace;
- **probable pronunciation signals**: low-confidence letter or segment differences that require replay and, when material, human confirmation.

It should never turn an ASR text match into a claim of certified tajwid accuracy. Advanced makharij, sifaat, madd duration, ghunnah, tafkhim/tarqiq, and waqf/ibtida need expert-labeled audio and teacher validation.

### 5. Quranic Arabic depth is the largest content gap

Many products teach frequent vocabulary, but fewer connect it to morphology, syntax, rhetoric, and independent Quran reading. [Bayyinah Dream Arabic](https://explore.bayyinahtv.com/arabic/) supplies the deepest benchmark: nahw, sarf, readers, irregular structures, balaghah, and applied surah analysis. [Arabic101](https://academy.arabic101.org/course-3-how-to-understand-the-quran-in-arabic/) offers measurable vocabulary stages, while [Al Balagh](https://www.albalaghacademy.org/course/mastering-quranic-arabic-level-1/) publishes a four-level cohort model with 1,000 frequent words and 20+ grammar concepts as long-term goals. [Madinah Arabic](https://madinaharabic.com/free-content/reading) and [LQToronto](https://www.lqtoronto.com/videos.html) are useful cumulative grammar references.

Muslingo needs more than translation-choice questions. It needs root-family recognition, pronoun attachment, prepositions, nominal/verbal sentence parsing, verb form recognition, inflection-sensitive meaning, phrase chunking, and progressively reduced vowel support. Audio should test discrimination and comprehension, not merely play after the answer.

## Content-quality comparison

| Model | Best examples | Strength | Weakness | Muslingo response |
|---|---|---|---|---|
| Short official video | Arabic101, Understand Al-Quran | Clear demonstrations and high discoverability | Passive viewing, weak personalization | Embed selected official items only as optional enrichment; follow with native practice |
| Long-form teacher course | Bayyinah, AMAU, Qalam, SeekersGuidance | Depth, context, scholarly voice | High time cost; difficult mobile retention | Convert licensed/expert-authored concepts into 5–8 minute native lessons, not copied summaries |
| Live talaqqi | Maqraa Al-Harmain, Riwaq, Kalimah, Studio Arabiya | Real listening and correction | Cost, scheduling, limited scale | Add teacher escalation, periodic oral reviews, and partner booking |
| Voice-first app | Tarteel, Tasmi | Immediate feedback and daily practice | Tajwid coverage may be narrow or opaque | Publish score boundaries and confidence; allow unlimited retry after the model answer |
| Hifz planner | HIFZ, Tarteel, AlHuda | Revision discipline and progress visibility | Meaning and pronunciation may be separate | Maintain per-ayah memory states for text, order, meaning, and pronunciation |
| Audio library/API | King Fahd Complex, Quran.com, MP3Quran, QUL | Authentic examples and broad reciter coverage | Rights/provenance differ by recording | Build a rights manifest and use only approved, versioned assets |
| Quranic-Arabic curriculum | Bayyinah, Arabic101, Al Balagh | Vocabulary plus grammar progression | Usually not adaptive or voice-integrated | Combine morphology/grammar with ayah audio, retrieval practice, and spaced repetition |

## What Muslingo is still missing

### Reading and tajwid

- a diagnostic minimal-pair bank for `ح/ه`, `ح/خ`, `ع/ا`, `ص/س`, `ض/د`, `ط/ت`, `ظ/ذ/ز`, `ق/ك`, and emphatic/non-emphatic contexts;
- explicit visual and audio lessons for makharij and sifaat, followed by discrimination before production;
- measured madd and ghunnah exercises that compare durations without claiming certainty beyond the model's evidence;
- waqf and ibtida scenarios where the learner chooses a meaning-preserving stop, inspired by the gap visible in Arabic101's “Other 50%” collection;
- a mastery gate requiring success across different words and ayat, not repeated memorization of one prompt;
- oral-review checkpoints with an expert before Muslingo labels advanced tajwid mastery.

### Hifz

- independent states for new memorization, recent revision, and long-term revision, corresponding to Sabaq/Sabqi/Manzil;
- continuation-from-random-ayah tests, previous/next ayah tests, mutashabihat contrast drills, and hidden-text recall;
- retention prediction based on delayed recall, not same-session success;
- teacher/guardian assignment and review receipts, with private-by-default voice recordings;
- an explicit difference between a word-perfect attempt and a tajwid-reviewed attempt.

### Quranic Arabic

- a measurable high-frequency vocabulary ladder with coverage accounting;
- roots, patterns, attached pronouns, particles, nominal/verbal sentences, and verb forms;
- contextual ambiguity questions where distractors are plausible and the learner must use grammar or ayah context;
- listening comprehension at word, phrase, and ayah level;
- productive tasks: build a phrase, identify a referent, explain a morphological change, and infer meaning from a known root;
- gradual removal of translation, transliteration, and tashkeel support.

### Audio and video UX

- a per-asset rights and provenance manifest;
- reciter, riwayah, ayah boundaries, word timing, recording style, pace, source URL, checksum, license evidence, and expiry/review date;
- a slow teaching model separate from a beautiful performance model;
- A/B comparison between the reference and the user's attempt, with replay at segment level;
- captions/transcripts only when licensed and human-checked;
- offline download only for recordings whose license explicitly permits it.

### Trust and editorial governance

- named Quran/tajwid reviewers and a published correction workflow;
- versioned lesson sources and “last reviewed” dates;
- an uncertainty label for AI pronunciation feedback;
- school/madhhab and valid-difference notes when broader Islamic content is linked;
- documented teacher credential verification rather than relying on website claims;
- child safeguarding, consent, recording retention, and deletion rules for live or asynchronous review.

## Recommended source strategy

### Tier 1: pursue now

1. **King Fahd Complex** — ingest only the explicitly permitted listed recordings after creating a rights manifest and validating files/checksums.
2. **Quran.Foundation/Quran.com** — apply for the appropriate developer/Connected Apps path for text, recitation, timing, and attribution-safe synchronization.
3. **Arabic101** — discuss Russian localization, licensed short clips or co-authored lesson scripts, and a teacher-review escalation pilot.
4. **Maqraa Al-Harmain** — explore institutional referral, oral assessment, or expert-review collaboration rather than content copying.
5. **Riwaq or Kalimah** — pilot a small vetted pool of Russian/English-speaking teachers for uncertain pronunciation attempts.

### Tier 2: use as design and curriculum benchmarks

- Understand Al-Quran for watch/read/write/test packaging;
- Bayyinah for deep Quranic Arabic and narrative explanation;
- Tarteel and Tasmi for voice UX and honest score boundaries;
- HIFZ for Sabaq/Sabqi/Manzil revision logic;
- AlHuda and Al Balagh for cohort, assignment, and longitudinal-course design;
- IQRA Network and Free Quran Education for child-friendly visuals, after source review.

### Tier 3: reference or referral only

Commercial live academies without independently verified governance should be listed only after teacher-credential, curriculum, privacy, and safeguarding due diligence. Dormant YouTube archives can remain researcher references but should not be hardcoded into core lessons because availability and support may disappear.

## Proposed content-production pipeline

1. **Source intake** — record the primary URL, publisher, teacher, language, topics, rights statement, and intended use.
2. **Rights gate** — classify `native reuse`, `official embed`, `metadata/link only`, or `blocked pending written permission`.
3. **Islamic/tajwid review** — verify rule, riwayah, examples, terminology, and valid differences.
4. **Instructional design** — define prerequisite, objective, misconception, contrast set, guided practice, independent check, and delayed review.
5. **Audio production** — use a qualified reciter under an explicit recording agreement or a source whose recording license permits the intended use.
6. **Technical QA** — validate ayah/word boundaries, audio checksum, language direction, captions, playback, offline behavior, and deletion rules.
7. **Pilot** — test with beginners and qualified teachers; measure false positive/negative feedback, retry behavior, and delayed retention.
8. **Publication** — expose source attribution, educational limitation, version, reviewer, and next review date.

## Minimum metadata schema for future ingestion

The CSV created with this report is a discovery registry, not yet an ingestion manifest. A production media manifest should additionally contain:

- immutable asset or video ID;
- publisher and rights-holder contact;
- teacher/reciter and credential evidence;
- riwayah and recitation style;
- surah/ayah/word range and timestamps;
- original URL, retrieval timestamp, checksum, MIME type, duration and bitrate;
- license text snapshot, permitted territories, commercial use, modification, offline, expiration and attribution;
- embedability test result and last availability check;
- languages for instruction, captions and transcript;
- scholarly reviewer, review date and content version;
- child-safety classification and voice-data implications;
- Muslingo lesson IDs that depend on the asset.

## Limitations

This is a high-quality expansion, not a claim to have enumerated every Islamic video on the internet. Private groups, login-only classes, unindexed local mosque recordings, and sources with no accessible official authority page were excluded. Public availability can change. YouTube license and embed settings are per video, so channel inclusion does not authorize every upload. Commercial academy credentials are publisher claims until documents and references are independently verified. Government and institutional pages establish authority but do not imply permission to reproduce course materials.

An automated reachability pass on 11 September 2026 received HTTP 200 from 63 of the 70 direct registry URLs. Six primary pages returned bot-protection HTTP 403 to the automated client but were available through indexed/browser retrieval, and the King Fahd audio subdomain produced a local TLS/connection error while its primary page was retrievable through the web index. These seven entries should receive a normal-browser availability check immediately before product ingestion; none is a search-results URL.

The registry should be refreshed quarterly, and immediately before any source is published inside Muslingo.

## Primary references

1. King Fahd Glorious Quran Printing Complex. [Official Quran audio recitations and use rights](https://qc-dev.qurancomplex.gov.sa/quran-audios/). Accessed 11 September 2026.
2. King Fahd Glorious Quran Printing Complex. [Organizational structure and specialist audio review](https://qurancomplex.gov.sa/en/kfgqpc/kfq-structure/). Accessed 11 September 2026.
3. Quran.Foundation. [About Quran.com](https://quran.com/about-us?locale=en). Accessed 11 September 2026.
4. Quran.Foundation. [API reference](https://api-docs.quran.com/docs/api-reference/) and [developer terms](https://api-docs.quran.com/legal/developer-terms/). Accessed 11 September 2026.
5. MP3Quran. [API v3](https://www.mp3quran.net/eng/api) and [permissions statement](https://www.mp3quran.net/eng/contact-us). Accessed 11 September 2026.
6. Tarteel/QUL. [Recitation integration tutorial](https://qul.tarteel.ai/docs/tutorial-recitation-end-to-end) and [FAQ](https://qul.tarteel.ai/docs/faq). Accessed 11 September 2026.
7. YouTube. [License types](https://support.google.com/youtube/answer/2797468?hl=en) and [Terms of Service](https://uk.youtube.com/t/terms). Accessed 11 September 2026.
8. Google for Developers. [YouTube IFrame Player API](https://developers.google.com/youtube/iframe_api_reference) and [Developer Policies](https://developers.google.com/youtube/terms/developer-policies). Accessed 11 September 2026.
9. Arabic101 Academy. [Quran Mastery](https://academy.arabic101.org/course-2-quran-mastery/), [Understand the Quran in Arabic](https://academy.arabic101.org/course-3-how-to-understand-the-quran-in-arabic/), and [course catalogue](https://academy.arabic101.org/courses/). Accessed 11 September 2026.
10. Understand Al-Quran Academy. [Learn Tajweed - the Easy Way](https://understandquran.com/learn-tajweed-the-easy-way-english/). Accessed 11 September 2026.
11. Bayyinah TV. [Learn to Read Quran](https://explore.bayyinahtv.com/learn-to-read-quran/) and [Dream Arabic](https://explore.bayyinahtv.com/arabic/). Accessed 11 September 2026.
12. Tarteel. [Product site](https://tarteel.ai/). Accessed 11 September 2026.
13. Maqraa Al-Harmain. [Official platform](https://maqraa.prh.gov.sa/en). Accessed 11 September 2026.
14. Dubai IACAD. [A Hafiz in Every Home](https://www.iacad.gov.ae/en/initiatives/quran-teaching-and-memorization). Accessed 11 September 2026.
15. Oman Ministry of Endowments and Religious Affairs. [Electronic Quran teaching program](https://quran.mara.gov.om/). Accessed 11 September 2026.
16. Riwaq Al Quran. [Recitation with Tajweed](https://riwaqalquran.com/courses/recitation-with-tajweed/) and [instructors](https://riwaqalquran.com/all-instructors/). Accessed 11 September 2026.
17. Kalimah Center. [Arabic and Quran courses](https://kalimah-center.com/) and [teachers](https://kalimah-center.com/teachers/). Accessed 11 September 2026.
18. Studio Arabiya. [Tajweed courses](https://studioarabiya.com/lp/tajweed-courses/). Accessed 11 September 2026.
19. AlHuda Online. [Course catalogue](https://alhudaonline.org/online-courses/) and [learning features](https://alhudaonline.org/learning-and-features/). Accessed 11 September 2026.
20. Al Balagh Academy. [Mastering Quranic Arabic Level 1](https://www.albalaghacademy.org/course/mastering-quranic-arabic-level-1/). Accessed 11 September 2026.
21. Tasmi. [Quran hifz practice](https://www.tasmi.app/). Accessed 11 September 2026.
22. HIFZ. [Memorization methodology](https://gethifz.com/support). Accessed 11 September 2026.
