# Muslingo Foundations Curriculum Gap Analysis

## Executive finding

The current Foundations course is not large enough to function as a structured beginner Islamic-studies curriculum. It contains 10 orientation lessons and 66 steps, but only three lessons have more than one lesson-level source reference. Most questions test recognition of wording that appeared immediately before the question. The course introduces Islam, iman, prayer, cleanliness, Quran learning and adhkar, but does not teach a learner to perform, reason, verify, sequence, or safely apply them.

The verified comparison set contains 48 official programs, curriculum frameworks, school implementations, university or academy pathways, and safeguarding standards. It combines Islamic curriculum evidence with the assessment, governance, online-safety, and age-specific safeguarding standards needed to evaluate a youth product. No source grants Muslingo a blanket right to copy its lesson content. The correct action is to build original lessons from licensed primary texts and reviewed scholarly sources, using these programs only as metadata and design benchmarks.

The exact recommended backlog is **170 net-new lessons in 17 modules**. The existing 10 lessons should become short orientation or diagnostic lessons at the start of the relevant modules, producing a **180-lesson Foundations pathway** rather than being deleted. A releaseable first tranche is 60 lessons; the complete beginner and teen pathway requires all 170 new lessons plus governance and safeguarding gates.

## Scope and method

The review covered structured programs for beginners and teenagers in aqidah, ibadah, seerah, Quran studies, adab and akhlaq, duas, hadith literacy, digital safety, and contemporary life. Priority was given to official curriculum pages, syllabus PDFs, government frameworks, recognized Islamic school associations, universities, and academies. Product pages without visible learning objectives, assessment information, governance, or age boundaries were retained only when they added a distinct program model and were marked with lower evidence confidence in the CSV.

The research records curriculum metadata only. It does not reproduce textbook chapters, lesson scripts, assessment items, video transcripts, or proprietary teaching assets. “Free,” “downloadable,” and “shareable” were not treated as commercial adaptation rights.

Full source metadata is in [islamic-curricula-expansion-2026-09-11.csv](./islamic-curricula-expansion-2026-09-11.csv).

## Current Muslingo baseline

The authoritative implementation is `lib/services/lessons/rules_lessons.dart`.

| Current lesson | What it currently achieves | Curriculum status |
|---|---|---|
| R1. Вера и намерение | Introduces sincerity and intention before learning | Keep as orientation; lacks Islam–iman–ihsan and applied intention cases |
| R2. Что такое Коран | Introduces Quran as revelation and a listen–understand–repeat loop | Keep as orientation; lacks revelation, preservation, structure, tafsir method and context |
| R3. Пророк Мухаммад | Introduces the Prophet as a moral example | Keep as orientation; does not establish chronology or source confidence |
| R4. Молитва | States the centrality of prayer | Keep as orientation; does not teach prerequisites, sequence, meanings, errors or school-specific rulings |
| R5. Чистота и адаб | Introduces cleanliness and respectful Quran study | Split into worship and character paths; the cited 56:79 interpretation needs juristic review |
| R6. Как понимать перевод | Warns that translation is not the Arabic Quran and refers difficult questions outward | Keep; expand into source and tafsir literacy |
| R7. Как учить суры | Explains the Muslingo learning loop | Move to product onboarding or Quran-study skills; it is not a substantive Foundations unit |
| R8. Шесть столпов веры | Names the six articles of faith | Keep as diagnostic; each article needs later explanation and application |
| R9. Пять столпов ислама | Names the five pillars | Keep as diagnostic; each pillar needs a practical sequence and declared fiqh scope |
| R10. Короткие азкары | Introduces four common remembrances | Keep as orientation; lacks occasion, source, meaning, habit planning and safe claims |

### Measured weaknesses

- **Coverage:** no complete aqidah, purification, prayer, fasting, zakat, Hajj, seerah, Quran sciences, hadith method, relationships, digital safety, finance, citizenship, environment, mental wellbeing, or help-seeking sequence.
- **Sequence:** lessons are a flat list. There are no prerequisites, age bands, placement outcomes, review loops, or mastery gates inside Foundations.
- **Assessment:** most items are immediate three-option recall. There are no delayed checks, constructed responses, source classification, scenario decisions, ordered practice, projects, oral explanation, or cumulative capstones.
- **Source governance:** a single `sourceUrl` often stands behind a whole lesson. There is no structured claim-to-source map, translation edition, hadith grade and grader, madhhab tag, reviewer, approval date, or correction version.
- **Safeguarding:** the course does not teach body boundaries, grooming, cyberbullying, sextortion, harmful content, privacy, reporting, trusted adults, emergency escalation, or how to handle a personal religious question safely.
- **Age suitability:** the same wording and challenge model is shown without a 7–10, 11–14, and 15+ cognitive or safeguarding split.
- **Tradition visibility:** common-core claims, school-specific legal rulings, and theological formulations are not represented as distinct metadata layers.

## What strong curricula do differently

### 1. They use recurring strands and deliberate progression

Safar, An Nasihah, Weekend Learning, ICO, NISS, Pakistan NCC, JAKIM and the Indonesian madrasah framework revisit belief, worship, Quran and Hadith, seerah, and character at increasing depth rather than treating each topic once.[^1][^2][^3][^4][^5][^6][^7][^8]

Muslingo should adopt three learner bands with common concepts but different outcomes:

| Band | Learner outcome |
|---|---|
| Foundation 7–10 | Name, recognize, order, practise with an adult, and know when to ask for help |
| Bridge 11–14 | Explain reasons, compare safe scenarios, detect misinformation, and apply learning to school, peers and online life |
| Independent 15+ | Use sources, identify scope and disagreement, make bounded decisions, and escalate personal rulings appropriately |

### 2. They separate knowledge, practice, meaning, and transfer

Journey2Jannah uses video, embedded activity, summary, quiz, cumulative check and retry; Safar adds workbooks, projects, differentiated outcomes, mid-term and final assessment.[^9][^10] Cambridge Islamiyat assesses explanation and significance, not only recognition.[^11][^12] Ribaat mixes homework, reflections, essays, projects, exams and oral assessment.[^13]

Every Muslingo module therefore needs five evidence types:

1. Knowledge check after a delay.
2. Ordered or simulated practice where appropriate.
3. Meaning or source explanation in the learner’s own words.
4. Realistic scenario transfer with plausible distractors.
5. Cumulative review after 1, 7, 30 and 90 days.

### 3. They disclose scholarly scope or reveal why Muslingo must

SeekersGuidance explicitly separates Hanafi and Shafii pathways and publishes its traditional Sunni framing; Zad states its Quran-and-Sunnah/pious-predecessors methodology; Qalam declares a Hanafi legal core with comparative madhhab exposure; Al-Kisa visibly reflects a Twelver Shia framework.[^14][^15][^16][^17] Mixing these positions without labels would be a product and trust failure.

Muslingo needs a common-core layer plus optional, named fiqh and aqidah tracks. A lesson may not be published until the relevant track and reviewing scholar are recorded.

### 4. Contemporary life must be a curriculum, not a warning paragraph

Yaqeen teaches evidence, media filters, bias, fallacies and misinformation through cases and exit tickets.[^18] AMS UK places relationships, identity, internet safety, boundaries, parent consultation and statutory safeguarding into a Muslim-school context.[^19] Qatar’s 2026 Digital Citizenship curriculum covers account security, privacy, safe browsing, cyberbullying, social media and intellectual property with interactive assessment.[^20] The International Islamic Fiqh Academy explicitly recommends teaching Sharia standards for social media in schools.[^21]

Islamic ethics alone is not a sufficient child-safety framework. Muslingo must combine reviewed Islamic guidance with operational safety competencies from an age-banded framework such as Education for a Connected World.[^22]

## Exact Foundations backlog

The backlog below is net-new. Existing R1–R10 are retained as orientation or diagnostic entries and linked to these modules.

| Priority | Module | New lessons | Required sequence and outcomes | Assessment evidence | Existing lesson reused |
|---|---|---:|---|---|---|
| P0 | FND-01 Knowledge, intention and sources | 8 | Intention; Islam–iman–ihsan; Quran/Hadith/tafsir/fiqh/opinion; citation anatomy; scholar role; disagreement; asking a safe question; correction literacy | Source sorting, citation match, explain-the-boundary scenario | R1, R6 |
| P0 | AQD-01 Knowing Allah and tawhid | 10 | Creator and creation; worship; names and attributes at age-safe depth; sincerity; reliance; gratitude; avoiding superstition; evidence and reflection | Misconception diagnosis, scenario reasoning, short explanation | R8 as diagnostic |
| P0 | AQD-02 Revelation, prophets and the unseen | 12 | Angels; books; messengers; Prophet Muhammad; afterlife; qadr with human responsibility; hope and accountability; doubts and escalation | Concept map, claim classification, non-deterministic qadr cases | R3, R8 |
| P0 | IBD-01 Purification foundations | 10 | Purpose; types of cleanliness; wudu sequence; invalidators; ghusl overview; menstruation-safe branch; tayammum; accessibility; common mistakes; school-specific differences | Ordered simulation, error spotting, teacher/self checklist | R5 introduction |
| P0 | IBD-02 Prayer foundations | 14 | Why prayer; times; prerequisites; adhan; intention; movement sequence; meanings; congregation; mosque adab; common mistakes; travel/illness overview; missed steps boundary; review | Sequence tasks, audio meaning checks, realistic cases, observed-practice checklist | R4, R9 |
| P0 | QST-01 Quran revelation, reading and context | 10 | Revelation; compilation and preservation; surah/ayah/juz; Makki/Madani; translation vs tafsir; context; asbab reports; reflection limits; turning an ayah into action; source drawer | Timeline reconstruction, context matching, source-layer classification | R2, R6, R7 |
| P0 | HAD-01 Hadith literacy | 10 | Sunnah and hadith; report components at beginner level; collections; locator; grading; translation; commentary; isolated-text risk; hadith and fiqh; responsible sharing | Authenticity-metadata reading, citation repair, share-or-check scenarios | None |
| P1 | IBD-03 Fasting, zakat, Hajj and seasonal worship | 12 | Ramadan purpose; fasting sequence and exemptions; conduct; zakat meaning and calculation boundary; Hajj meaning and map; Umrah distinction; Eid; post-season habits | Calendar and sequence tasks, exemption triage with medical/scholar referral | R9 diagnostic |
| P1 | SIR-01 Makkan seerah | 10 | Arabia context; birth and upbringing; first revelation; early believers; opposition; migration to Abyssinia; Taif; Isra and Miraj with source labels; pledges; Hijrah | Timeline, motive/evidence cases, source-confidence tags | R3 orientation |
| P1 | SIR-02 Madinan seerah | 10 | Community building; Constitution context; major encounters without glorifying violence; Hudaybiyyah; letters; conquest; farewell Hajj; death; character and plural society | Timeline repair, decision scenarios, evidence confidence | R3 orientation |
| P1 | ADA-01 Adab, akhlaq and emotional life | 10 | Truth; mercy; patience; gratitude; anger; envy; apology; family and neighbours; disagreement; service; care for creation; mental distress and help | Behaviour plan, branching social cases, reflection follow-up | R5, R10 fragments |
| P1 | DUA-01 Duas and adhkar with meaning | 8 | What dua is; source and occasion; morning/evening overview; food/home/travel/sleep; distress; gratitude; memorization and meaning; no magical guarantees | Occasion matching, source card, spaced audio recall | R10 orientation |
| P1 | SAF-01 Growing up, body boundaries and relationships | 10 | Puberty vocabulary; dignity and privacy; body autonomy; safe/unsafe touch; consent and coercion; trusted adults; peer pressure; attraction without shame; explicit-content exposure; reporting and recovery | Age-gated scenarios, identify-help pathway, no disclosure stored in lesson analytics | None |
| P1 | DIG-01 Digital safety and media literacy | 10 | Passwords and account security; privacy and permanence; cyberbullying; grooming and sextortion; harmful content; misinformation; bias/fallacies; copyright; responsible posting; AI/deepfakes and help | Risk classification, privacy settings simulation, fact-check trail, report/block/escalate choices | None |
| P2 | LIFE-01 Money, work, citizenship and environment | 10 | Earning and spending; charity; debt boundary; consumer pressure; workplace/school integrity; neighbours and plural society; law and civic duties; racism; environment; service project | Budget and integrity cases, civic scenario, service reflection | R9 zakat name only |
| P2 | LIFE-02 Questions, doubt and contemporary pressures | 8 | Asking difficult questions; evidence vs virality; science and faith boundaries; suffering; identity; friendship; belonging; respectful disagreement; scholar/parent/professional referral | Claim-evidence matrix, dialogue response, escalation choice | None |
| P2 | CAP-01 Cumulative capstones | 8 | Six integrated missions combining belief worship sources seerah character and digital life; final personal learning plan and source-aware oral explanation | Multi-step scenario, delayed review, oral explanation, non-certifying mastery report | All ten as retrieval prompts |
|  | **Total** | **170** | **17 modules; 180 lessons including the current ten** |  |  |

### Delivery tranches

| Tranche | Net-new lessons | Exit condition |
|---|---:|---|
| Release 1 | 60 | FND-01, AQD-01, IBD-01, IBD-02, QST-01 and the first 8 HAD-01 lessons are reviewed, localized and tested |
| Release 2 | 64 | Remaining aqidah/hadith, seasonal worship, both seerah modules, adab and duas are live with cumulative review |
| Release 3 | 46 | Safeguarding, digital safety, contemporary life and all capstones are approved and age-gated |

The digital-safety and body-boundary modules should be designed during Release 1 even though learner publication is in Release 3. Their privacy and escalation requirements affect analytics, AI Coach, community features, voice recordings, and notification copy across the product.

## Required lesson contract

Every new Foundations lesson needs the following fields before implementation:

| Field | Required evidence |
|---|---|
| `ageBand` | One of 7–10, 11–14, 15+; reading load and sensitive-topic gate defined |
| `prerequisites` | Prior concepts and placement result; no order inferred only from lesson number |
| `learningObjectives` | Two to four observable verbs; “understand” alone is rejected |
| `sourceClaims` | Claim ID, source type, exact locator, translation, hadith grade/grader if relevant |
| `scope` | Common core or named aqidah/fiqh track; material disagreement noted |
| `review` | Subject scholar, learning editor, source editor, safeguarding reviewer where relevant |
| `assessmentPlan` | Immediate, delayed, scenario, cumulative and practical evidence as applicable |
| `safetyBoundary` | What the lesson cannot determine; scholar, parent, safeguarding or medical escalation |
| `rights` | Source and media licence; territory, language, derivative and audio rights |
| `version` | Approval date, correction history, superseded version and learner-notification rule |

## Assessment model for Muslingo

The existing Duolingo-like step loop can remain, but the challenge engine should draw from a deeper assessment contract:

- **Recognition:** no more than 25 percent of a module score.
- **Retrieval:** answer after content is no longer visible and again after delay.
- **Construction:** order a process, rebuild a timeline, match claim to source, or explain a distinction.
- **Transfer:** choose among realistic actions where more than one option sounds superficially good.
- **Practice:** use non-certifying self/teacher checklists for worship and recitation; the app must not claim ritual validity.
- **Reflection:** private and optional; never place intimate disclosures, sins, relationships, health or safety incidents into public analytics or league data.
- **Mastery:** require at least two successful delayed attempts and one transfer task, not one multiple-choice pass.

## Safeguarding and scholarly governance backlog

Content expansion must not begin as bulk AI generation. The governance backlog is release-blocking:

1. Appoint an accountable scholarly board and publish the doctrinal and legal scope.
2. Establish subject, learning-design, source, language/audio and safeguarding sign-off roles.
3. Store citations at claim level; include hadith locator, grading, grader and translation provenance.
4. Create a correction workflow with review dates, rollback and notification to affected learners.
5. Add an age gate and parent/guardian model for sensitive content without forcing a child to disclose intimate information.
6. Define an in-app help flow for grooming, abuse, self-harm, coercion and dangerous content; route to trusted adults and local emergency resources rather than AI religious advice.
7. Prohibit AI Coach from issuing personalized fatwas, diagnosing ritual validity, eliciting confessions, or continuing unsafe private conversations with minors.
8. Minimize analytics for minors; never store free-text disclosures or voice recordings from safeguarding lessons by default.
9. Commission separate Hanafi and Shafii practice branches first, or launch one declared school; do not merge rulings into a synthetic answer.
10. Require written commercial rights for all translations, Quran/hadith text editions, illustrations, video, audio, worksheets and adapted assessments.

## Build, partner, or refer

| Capability | Recommendation | Reason |
|---|---|---|
| Core 7–14 progression | Build original; use Safar, An Nasihah, NISS and national grids as benchmarks | No comprehensive open commercial licence was found |
| Teen difficult questions | Seek a pilot licence or expert partnership with Yaqeen; otherwise build independently | Strong pedagogy and scholar review; explicitly supplementary |
| Fiqh pathways | Contract named Hanafi and Shafii reviewers; use SeekersGuidance as architecture benchmark | Legal positions must stay separated and reviewable |
| Seerah audio | Explore Qalam partnership; build Muslingo chronology and evidence tags | Strong long-form model but not app-ready assessment |
| Hadith literacy | Build with a hadith specialist; use Seekers, Cambridge and HEC outcomes as benchmarks | Citation and grading literacy is a major market gap |
| Digital safety | Build with a child-safeguarding specialist using UKCIS competencies and reviewed Islamic ethics | Religious content providers do not cover the full threat model |
| Sensitive relationships | Partner with a qualified Muslim RSE/safeguarding team such as AMS UK | Requires legal, developmental and pastoral competence |
| Advanced study | Refer outward to declared providers | Muslingo should not pretend a micro-course replaces seminary or university study |

## Acceptance criteria for curriculum production

A module is ready for publication only when:

- all lessons have observable objectives, prerequisites and age bands;
- every substantive religious claim maps to an approved source record;
- legal and theological scope is visible to the learner and editor;
- scholar, pedagogy and source reviews are complete, with safeguarding review for sensitive modules;
- rights permit commercial mobile/web delivery, translation, audio and derivative interaction design;
- at least 40 percent of scored evidence is delayed retrieval or transfer rather than immediate recognition;
- every incorrect answer has a misconception-specific explanation and return path;
- Arabic, transliteration and translation have separate language and audio review;
- privacy tests prove no sensitive response enters league, public profile, generic analytics or AI training;
- pilot learners in the target age band complete comprehension, usability and emotional-safety testing;
- correction and rollback metadata exists before the first learner receives the module.

## Sources

[^1]: Safar Publications, [subjects and full syllabus overview](https://docs.safarpublications.org/article/82-what-subjects-does-the-learn-about-islam-series-cover-and-where-can-i-find-a-syllabus-overview), updated 15 April 2026; [secondary implementation](https://safarpublications.org/help-center/islamic-studies/primary-islamic-studies-syllabus/what-should-i-teach-after-textbook-6/).
[^2]: An Nasihah Publications, [Scope and Sequence Books 1–8](https://an-nasihah.com/project/scope-and-sequence-books-1-8/).
[^3]: Weekend Learning Publishers, [Our Curriculum](https://weekendlearning.com/pages/curriculum).
[^4]: International Curricula Organization, [Islamic Studies Grades 1–12](https://www.iconetwork.com/product-category/islamic-studies/).
[^5]: Islamic Studies Standardized Tests, [National Islamic Studies Standards](https://isstschools.com/national_standard.html).
[^6]: Pakistan National Curriculum Council, [Islamiyat standards, SLOs and progression grid for Grades 1–10](https://ncc.gov.pk/Detail/ZmFmNTZhMDEtNjBjYy00ZmIyLThhYTctMTg5YmMzNWRkNjkz).
[^7]: JAKIM, [KAFA Curriculum 2.0](https://www.islam.gov.my/ms/e-penerbitan/2164-buku-sukatan-pelajaran-kafa-jakim-2-0), 10 January 2020.
[^8]: Ministry of Religious Affairs Indonesia, [KMA 183 of 2019 PAI and Arabic Madrasah Curriculum](https://kemenag.go.id/en/nasional/ini-persamaan-dan-penyempurnaan-kurikulum-pai-dan-bahasa-arab-madrasah-p3qbwe), implemented from the 2020/2021 school year.
[^9]: Journey2Jannah, [Learning structure](https://journey2jannah.com/docs/what-is-the-structure-of-the-learning/) and [full lesson completion](https://journey2jannah.com/docs/how-to-complete-a-full-lesson/).
[^10]: Safar Publications, [workbook marking and assessment schedule](https://docs.safarpublications.org/article/93-is-there-a-marking-scheme-for-the-workbooks), updated 10 April 2026.
[^11]: Cambridge International, [IGCSE Islamiyat 0493](https://www.cambridgeinternational.org/programmes-and-qualifications/cambridge-igcse-islamiyat-0493/) and [2026–2027 syllabus PDF](https://www.cambridgeinternational.org/Images/697174-2026-2027-syllabus.pdf).
[^12]: Cambridge International, [O Level Islamiyat 2058](https://www.cambridgeinternational.org/programmes-and-qualifications/view/cambridge-o-level-islamiyat-2058/) and [2026–2027 syllabus PDF](https://www.cambridgeinternational.org/Images/697279-2026-2027-syllabus.pdf).
[^13]: Ribaat Academic Institute, [program and curriculum catalogue](https://academy.rabata.org/) and [Student Handbook](https://rabata.org/wp-content/uploads/2022/01/Student-Handbook-2022.pdf).
[^14]: SeekersGuidance Academy, [Islamic Studies and Youth curricula](https://academy.seekersguidance.org/); SeekersGuidance, [belief and approach](https://seekersguidance.org/answers/general-counsel/what-is-the-belief-and-approach-of-seekersguidance-and-its-online-islamic-courses/).
[^15]: Zad Academy, [curriculum](https://zad-academy.com/en/curriculum) and [assessment model](https://support.zad-academy.com/en/275805-Exams).
[^16]: Qalam Institute, [Seminary syllabus](https://www.qalaminstitute.org/wp-content/uploads/Syllabus-1.pdf).
[^17]: Al-Kisa Foundation, [K–12 development and governance report](https://alkisafoundation.org/wp-content/uploads/2024/09/AnnualReport2023-2024.pdf) and [Grades 7–12 pilot](https://us.alkisafoundation.org/collections/grades-7-12-pilot).
[^18]: Yaqeen Institute, [Decoding Media: An Islamic Framework for Truth and Information](https://yaqeeninstitute.org/curriculum/the-everyday-ethics-of-life/decoding-media).
[^19]: Association of Muslim Schools UK, [RSE Hub](https://ams-uk.org/rse-hub/) and [Section 48 inspections](https://ams-uk.org/section-48-inspections/).
[^20]: Qatar News Agency reporting the Ministry of Education and Higher Education launch, [Digital Citizenship Curricula for Grades 5 and 8](https://qna.org.qa/en/news/news-details?date=24/06/2026&id=moehe-launches-digital-citizenship-curricula-for-students), 24 June 2026.
[^21]: International Islamic Fiqh Academy, [Resolution 244 (6/25) on social media and dissemination of information](https://iifa-aifi.org/en/49700.html), 28 July 2023.
[^22]: UK Council for Internet Safety, [Education for a Connected World](https://www.gov.uk/government/publications/education-for-a-connected-world), 2020 edition.
