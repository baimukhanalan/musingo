# Muslingo: learning-science evidence and gap analysis

## Executive conclusion

Muslingo does not primarily need a larger undifferentiated lesson count. It needs a **validated progression** in which every lesson targets a named skill, every assessment measures that skill without answer leakage, and every review is scheduled from delayed retrieval evidence rather than completion or XP.

The strongest direct evidence supports five product decisions:

1. Beginners need fully vowelized Arabic and an explicit, gradual transition to less-vowelized text.
2. Arabic reading requires separate work on grapheme-phoneme decoding, phonological awareness, roots/patterns, oral vocabulary and comprehension.
3. Listening is useful scaffolding, but active production and delayed retrieval are required to infer learning.
4. Formative feedback must identify the task-level error and support a focused retry; a percentage or praise alone is weak feedback.
5. Spaced review and retrieval practice are well supported in general learning science, but their exact use for connected Quran memorization still requires a controlled Muslingo trial.

The largest evidence gap is automated recitation feedback. Public Quran ASR datasets are improving rapidly, yet most are dominated by professional reciters, narrow passages, synthetic errors or small human-error test sets. Word/character recognition accuracy cannot be presented as tajwid, makhraj or pronunciation accuracy. A production system needs an independent, consented learner corpus, scholar/teacher labels, subgroup evaluation and an abstention path.

The companion evidence table contains **54 sources** with citation, URL/DOI, year, population/language, method, finding, causal boundary, limitation, licence/data availability and a concrete Muslingo implication:

- [learning-science-evidence-2026-09-11.csv](./learning-science-evidence-2026-09-11.csv)
- 14 Arabic-reading, child-literacy and diglossia sources;
- 10 spacing, retrieval and hifz sources;
- 7 formative-assessment and feedback sources;
- 8 L2-pronunciation and CAPT sources;
- 11 Quran/Arabic speech datasets, benchmarks and model papers;
- 4 accessibility and Universal Design for Learning sources.

## Scope and method

The review covers evidence available through **11 September 2026** for:

- Arabic and Quran reading acquisition;
- pronunciation teaching and computer-assisted pronunciation training;
- hifz, retrieval practice and spaced repetition;
- formative assessment and feedback;
- Quran-recitation ASR, mispronunciation datasets and benchmarks;
- child learning and digital accessibility.

Priority was given to systematic reviews, meta-analyses, randomized or controlled experiments, original dataset papers, benchmark reports, official repositories and standards. Product marketing, testimonials and unverified app claims were excluded as efficacy evidence.

Evidence was interpreted under four rules:

1. Correlational, cross-sectional and path-analysis findings are not described as causal.
2. A general L2 or memory result is marked as **transfer evidence**, not proof for Quran learning.
3. Model metrics establish performance only on the stated test set; they do not establish pedagogical benefit.
4. Public access is not assumed to permit commercial reuse. Dataset, code, audio and Quran-text rights are treated separately.

This is an evidence map and product gap analysis, not a formal clinical guideline or a full risk-of-bias meta-analysis. Several 2025-2026 Quran speech resources are preprints or challenge artifacts and should be treated as emerging evidence until independently replicated.

## Evidence strength by question

| Product question | Evidence strength | What can be concluded | What cannot be concluded |
|---|---:|---|---|
| Should beginners see tashkeel? | Moderate, direct Arabic evidence | Vowelization improves accuracy/comprehension for beginning and school-age readers in tested materials. | That one fixed removal point works for every child, dialect or non-native learner. |
| Should spoken Arabic/MSA distance be taught explicitly? | Moderate, mainly observational plus one early-childhood RCT | Diglossic distance predicts difficulty; active MSA recitation can support later literacy. | That dialect should be suppressed or treated as an error. |
| Should morphology and phonology both be taught? | Moderate, direct Arabic evidence | Both are relevant; phonology is central to decoding and morphology adds unique information. | A single universal lesson ratio or sequence for Quranic Arabic. |
| Does active recall beat recognition? | Strong, general learning evidence | Delayed retrieval generally benefits more from effortful recall than restudy/recognition. | Exact hifz intervals or that multiple choice has no educational value. |
| Does spaced practice improve hifz? | Strong transfer evidence; weak direct Quran evidence | Spacing is a defensible default and should be tested with delayed ayah retention. | That SM-2/FSRS or any fixed schedule is already validated for Quran memorization. |
| Does formative feedback help? | Moderate to strong, heterogeneous | Specific informational feedback generally helps; effects depend strongly on form and context. | A universal large effect or that a score-only AI response is effective. |
| Does CAPT improve pronunciation? | Moderate transfer evidence | Structured computer-assisted practice can improve L2 pronunciation, especially controlled tasks. | That generic ASR can diagnose tajwid or replace a qualified teacher. |
| Can current Quran ASR safely grade tajwid? | Emerging technical evidence, insufficient pedagogical validation | Models can follow recitation and detect some phoneme/error classes on bounded benchmarks. | Complete tajwid assessment, fairness across learners, or improved learning outcomes. |
| Do more animations improve child learning? | Weak as a blanket claim | Narration and conversation prompts can help; relevant multimedia can scaffold. | That more motion is better; decorative interactivity can distract and is not evidence-based. |
| Does UDL guarantee learning? | Limited and heterogeneous | Multiple modes and accessible controls improve access when implemented concretely. | That a generic “accessible mode” or UDL label proves efficacy. |

## Arabic and Quran reading

### 1. Tashkeel must be a scaffold, not a cosmetic setting

Abu-Rabia experimentally found better comprehension with vowelized Arabic in grade 2 and grade 6 materials ([DOI](https://doi.org/10.1023/A:1023291620997)). Asadi, Khateb and Shany show that the balance between decoding and language changes across grades as Arabic readers move from transparent vowelized script to deeper unvowelized orthography ([DOI](https://doi.org/10.1111/1467-9817.12093)). These results support a staged display model:

- full tashkeel for initial decoding and all Quran text where canonical vocalization is required;
- optional fading only in Arabic-language transfer exercises, not alteration of Quran text;
- learner-controlled reveal;
- transition triggered by performance on unseen words and passages;
- continued access to the fully marked form after an error.

Removing marks to make a lesson “harder” before a learner has stable decoding is not productive difficulty. Difficulty should come from retrieval, discrimination and transfer, not from withholding essential phonological information.

### 2. Diglossia is a first-class learner variable

Two systematic reviews describe persistent effects of distance between spoken and Standard Arabic ([Thomure et al., 2025](https://doi.org/10.1016/j.ssaho.2025.102281); [Jouhar, 2023](https://doi.org/10.36771/ijre.47.1.23-pp200-229)). Developmental studies likewise link phonological/lexical distance with weaker Standard-Arabic representations and reading outcomes ([Saiegh-Haddad & Haj, 2018](https://doi.org/10.1017/S0305000918000302); [Rakhlin et al., 2025](https://doi.org/10.1044/2024_JSLHR-23-00522)). These are mostly observational and should not be turned into deterministic learner labels.

Muslingo should therefore record:

- whether Arabic is native, heritage or foreign;
- home dialect or primary language;
- familiarity with MSA and Quranic register;
- phoneme contrasts absent or substantially different in the learner's L1/dialect;
- listening, decoding and meaning scores separately.

The UI should use a learner's spoken language as a bridge. It should never imply that a dialect is “bad Arabic.”

### 3. Arabic literacy is not one mastery score

Arabic evidence consistently separates phonological, morphological and orthographic knowledge. Taha and Saiegh-Haddad's intervention improved spelling through both phonological and morphological training ([DOI](https://doi.org/10.1007/s10936-015-9362-6)); their developmental study found phonology to be the strongest reading predictor while morphology explained additional variance ([DOI](https://doi.org/10.1002/dys.1572)). The scoping review by Bin Sawad and colleagues reaches a similar but appropriately cautious conclusion ([DOI](https://doi.org/10.3389/fcomm.2022.984340)).

The learner model should not store “Arabic: 72%.” It should store at least:

- letter identity across isolated/initial/medial/final forms;
- dot-pattern visual discrimination;
- short/long vowel decoding;
- sukun, shadda and tanwin decoding;
- phoneme segmentation and blending;
- root recognition and pattern awareness;
- word reading accuracy and latency;
- oral vocabulary;
- sentence/passage comprehension;
- transfer from familiar to unseen words.

### 4. A validated progression matters more than 100 lesson titles

A lesson is educationally distinct only if it adds a new target, contrast, context or retrieval demand. Rewording the same obvious multiple-choice item does not increase curriculum depth.

For every reading lesson, the CMS should require:

| Required field | Example |
|---|---|
| Target skill | Distinguish `ح / ه / خ` in medial position |
| Prerequisite | Stable short-vowel decoding |
| Teaching example | Two reviewed, fully marked words |
| Contrastive non-example | Same frame with a confusable phoneme |
| Guided production | Listen, segment, produce |
| Independent retrieval | Read an unseen word without model audio |
| Transfer item | Read the feature inside a new ayah segment |
| Error taxonomy | substitution, omission, vowel-length, order, hesitation |
| Mastery rule | two delayed successes plus transfer, not one immediate answer |
| Accessibility alternative | slower audio, larger script, non-speech response path |

## Hifz, spacing and retrieval

### 1. The memory engine should model retrieval, not exposure

The strongest evidence comes from general memory research. Distributed practice has a robust average advantage, while the optimal gap changes with the desired retention interval ([Cepeda et al., 2006](https://doi.org/10.1037/0033-2909.132.3.354); [Cepeda et al., 2008](https://doi.org/10.1111/j.1467-9280.2008.02209.x)). Retrieval produces better delayed retention than restudy in multiple experimental paradigms ([Roediger & Karpicke, 2006](https://doi.org/10.1111/j.1467-9280.2006.01693.x); [Karpicke & Roediger, 2008](https://doi.org/10.1126/science.1152408); [Rowland, 2014](https://doi.org/10.1037/a0037559)). Applied classroom reviews are positive but warn that comparisons against strong active controls are less decisive ([Agarwal et al., 2021](https://doi.org/10.1007/s10648-021-09595-9); [Moreira et al., 2019](https://doi.org/10.3389/feduc.2019.00005)).

These findings justify a retrieval-first engine, but not blind adoption of one flashcard algorithm. Connected oral text has order, rhythm, similar passages, verse boundaries and pronunciation dimensions that paired-word studies do not capture.

Each memory record should include:

- unit: letter, word, phrase, ayah, ayah transition, meaning or rule;
- cue level: full text, first word, audio, translation, no cue;
- response mode: recognition, typed recall, ordered assembly, oral recall;
- correctness dimensions: completeness, order, wording, pronunciation, tajwid-validated subset;
- latency and number of restarts;
- model confidence and learner dispute;
- last successful **uncued** retrieval;
- delayed-retention history;
- next due time and reason.

### 2. Direct hifz evidence remains weak

Recent reviews of Quran memorization identify recurring time, motivation, teacher-support and coordination problems, but also document heavy reliance on observational regional studies ([Al Arifi et al., 2025](https://doi.org/10.31538/tijie.v7i1.2481); [Al-Razi & Kusumasari, 2026](https://doi.org/10.1080/01416200.2026.2688399)). A pre/post Android-app study reports improvement but has no randomized concurrent control ([Ikhsan et al., 2024](https://doi.org/10.21093/fj.v16i2.7529)).

Therefore Muslingo should not claim that its scheduler is “scientifically proven for Quran memorization” before a direct trial. A credible pilot would compare:

- adaptive spaced retrieval;
- fixed traditional review schedule;
- equal-time guided restudy control.

Primary outcome: exact and teacher-rated retention of unseen-prompt passages after 7, 30 and 90 days. Secondary outcomes: error types, review burden, dropout, distress, and agreement between automatic and teacher scoring.

### 3. Recognition and recitation must not be interchangeable

Multiple choice can check comprehension or discrimination, but it is weak evidence of memorized production. Hifz mastery should require:

1. Listen and read with full text.
2. Chunked guided repetition.
3. Increasing text occlusion.
4. Continuation from a random cue.
5. Full uncued recitation.
6. Delayed retrieval on another day.
7. Similar-ayah contrast after enough prerequisites.
8. Periodic human-reviewed checkpoint for high-stakes labels.

The system must retain review after the first correct attempt. Experimental memory evidence shows that repeated retrieval after initial success matters for delayed retention.

## Formative assessment and feedback

Feedback effects are real but highly heterogeneous. The often-repeated effect size near 0.70 is not a safe universal assumption: Kingston and Nash found a weighted mean of 0.20 after screening more than 300 K-12 studies for usable evidence ([DOI](https://doi.org/10.1111/j.1745-3992.2011.00220.x)). A much larger later meta-analysis found an average `d = 0.48`, with major differences by information content and outcome ([Wisniewski et al., 2020](https://doi.org/10.3389/fpsyg.2019.03087)). Shute's review emphasizes task-focused, specific and manageable feedback ([DOI](https://doi.org/10.3102/0034654307313795)).

### Required Muslingo feedback contract

Every graded interaction should return:

1. **What was heard/selected** — visible and readable, never hidden by placeholder boxes.
2. **What was expected** — canonical text or concept.
3. **Difference** — omission, substitution, sequence, vowel length, meaning or rule.
4. **Uncertainty** — model confidence and an explicit “could not assess reliably” state.
5. **One next action** — replay a segment, compare two sounds, or retry one phrase.
6. **Retry** — available after both failure and success.
7. **Scheduling effect** — explain whether and why the item returns.

Scores should remain multidimensional:

- memory completeness;
- word/order accuracy;
- pronunciation quality, only where validated;
- tajwid rule application, only for independently validated rules;
- comprehension;
- confidence of the measurement.

A single “82% pronunciation” value collapses incompatible constructs and gives false precision.

## Pronunciation pedagogy

Meta-analyses support explicit pronunciation instruction and computer-assisted practice in general L2 learning ([Saito, 2012](https://doi.org/10.1002/tesq.67); [Lee, Jang & Plonsky, 2015](https://doi.org/10.1093/applin/amu040); [Mahdi & Al Khateeb, 2019](https://doi.org/10.1002/rev3.3165); [Almusharraf et al., 2024](https://doi.org/10.1111/jcal.12974)). The evidence is not Quran-specific, many studies are small, and controlled word reading often improves more than spontaneous speech.

Muslingo should use a four-stage pronunciation loop:

1. **Perception:** hear and discriminate the target from a contrast.
2. **Articulation model:** concise human-reviewed explanation and visible place/manner cue.
3. **Controlled production:** isolated sound, syllable and word.
4. **Transfer:** new Quranic word or ayah segment without immediate model imitation.

Every recording task should begin with a correct human recitation sample, as requested in the product concept. Listening must not be counted as production mastery. Perception- and production-based training both matter, and the assessment should match the taught skill ([Lee, Plonsky & Saito, 2020](https://doi.org/10.1016/j.system.2019.102185)).

## Quran speech recognition and assessment

### 1. Three tasks must remain separate

| Task | Defensible near-term output | Unsafe overclaim |
|---|---|---|
| Recitation following / ASR | Current ayah, missing/extra/reordered words, approximate transcript | “Your tajwid is correct” |
| Pronunciation assessment | A validated phoneme substitution/omission for covered groups | Global makhraj quality from WER/CER |
| Tajwid assessment | A separately validated named rule with confidence and expert labels | Complete automatic tajwid teacher or ijazah-equivalent judgement |

An end-to-end model reported `8.34% WER` and `2.42% CER` on Ar-DAD ([Al Harere & Al Jallad, 2023](https://arxiv.org/abs/2305.07034)). Ar-DAD contains professional reciters, not representative learner mistakes ([dataset paper](https://doi.org/10.1016/j.dib.2020.106503)). Low WER on this corpus therefore supports transcript following, not fine-grained correction.

Iqra'Eval is the most relevant public benchmark family because it defines phoneme-level mispronunciation tasks and includes a human Quran test. Yet QuranMB.v1 is only about 2.2 hours from 18 native speakers and 98 verses ([benchmark](https://arxiv.org/abs/2506.07722)). The Hafs2Vec shared-task system reported `46.50% F1` and `79.20% recall` on QuranMB ([paper](https://aclanthology.org/2025.arabicnlp-sharedtasks.62/)). That recall/precision trade-off is useful research evidence and a warning against automatic learner-facing certainty.

The Quran Muaalem work is promising because it provides a Quran Phonetic Script, a large corpus and a 159-sample real-error benchmark, reporting `75.8% Tajweed F1` ([preprint](https://arxiv.org/abs/2509.00094), [MIT code repository](https://github.com/obadx/quran-muaalem)). The real-error test remains too small and incompletely stratified to validate a production system across children, women, non-native speakers, accents, microphones and noise.

### 2. Production speech acceptance gate

Before any named pronunciation/tajwid correction is shown, Muslingo should require:

- consented learner speech collected for the stated purpose;
- guardian flow and separate safeguards for minors;
- qualified recitation teachers defining and labeling error classes;
- at least two independent labels per test sample plus adjudication;
- speaker-, ayah- and recording-session-disjoint splits;
- authentic errors, with synthetic errors used only as augmentation;
- representation of children/adults, women/men, Arabic/non-Arabic L1s, devices and noise;
- per-rule precision, recall, F1 and calibration;
- false-positive rate by subgroup;
- model abstention coverage;
- teacher-system agreement with confidence intervals;
- a learner study testing whether feedback improves later recitation without increasing false beliefs or anxiety.

Recommended policy thresholds for the first pilot are product risk targets, not literature-derived universal constants:

- no learner-facing rule label below a pre-registered precision threshold;
- low-confidence output becomes “Не удалось надежно оценить — попробуй еще раз”;
- no life/XP penalty when audio quality or model confidence is insufficient;
- every result has playback, visible transcript and dispute/report controls;
- no use of recordings for model training without separate opt-in consent.

### 3. Dataset licensing blocks direct commercial ingestion

| Resource | Research value | Current rights status | Muslingo decision |
|---|---|---|---|
| Ar-DAD | Reproducible professional-reciter ASR baseline | Dataset states CC BY 4.0; source-audio provenance still needs review | Research/pretraining candidate after provenance audit |
| Non-native Quranic Audio Dataset | 1,287 participants across 11+ countries; learner-relevant | No explicit machine-readable licence found on dataset page | Do not ingest commercially; request written terms |
| Iqra'Eval / QuranMB | Best public phoneme benchmark family | Challenge access; no clear commercial licence in repository/HF card | Evaluation only after written clarification |
| Quran-MD | Fine-grained word/ayah audio from 30 reciters | No explicit licence in HF card; paper/README disagree on reciter count | Block ingestion until rights and metadata reconcile |
| Tadabur | 1,400+ hours and 600+ reciters | CC BY-NC 4.0 | Research only; seek commercial licence |
| Quran Muaalem | Phonetic script, code, models and benchmark | Repository code MIT; underlying audio/datasets have separate terms | Reproduce code; audit every data dependency |

“Available on Hugging Face/GitHub” is not a commercial-use licence.

## Children and accessibility

### 1. Child learning requires more than a smaller layout

The strongest child-specific mobile review found only 11 eligible experimental/quasi-experimental studies. Narration helped relative to child reading alone but not relative to shared adult reading; real-time prompts improved adult-child conversation; other interactive features were inconsistent ([Booton et al., 2023](https://doi.org/10.1080/09588221.2021.1930057)). This directly contradicts a “more animations must improve learning” assumption.

Child mode should include:

- shorter instructions and one demand per screen;
- no punitive consequence for speech-recognition uncertainty;
- parent/teacher shared-reading prompts;
- motion reduction and no decorative motion during script discrimination;
- age-appropriate privacy and guardian consent;
- no public leaderboard by default;
- explicit breaks and session limits;
- human escalation for persistent pronunciation errors.

### 2. Accessibility must be testable behavior

[WCAG 2.2](https://www.w3.org/TR/WCAG22/) is the minimum technical release target, not an optional theme. Universal Design for Learning reviews suggest promise but report inconsistent implementation and mixed effects ([Ok et al., 2017](https://doi.org/10.1080/09362835.2016.1196450); [Zhang et al., 2024](https://doi.org/10.1007/s10648-024-09860-7)).

Required acceptance tests:

- all controls have accessible names and states;
- Quran Arabic is exposed as readable text in correct order;
- 200% text scaling and narrow reflow do not clip content;
- full keyboard/switch path works without timing traps;
- focus is visible and follows the visual flow;
- tajwid is not encoded by color alone;
- every prerecorded teaching audio/video has a transcript or equivalent;
- microphone tasks have a non-speech learning alternative;
- playback speed and repeat ranges are accessible;
- reduced motion is honored;
- VoiceOver and TalkBack tests are completed by real users, including Arabic-script navigation.

## Priority gap register

| Priority | Gap | Why it matters | Required evidence before “done” |
|---:|---|---|---|
| P0 | No validated learner-speech corpus | Professional ASR can mislabel real learner speech | Consented, stratified, teacher-labeled, leakage-free corpus and data sheet |
| P0 | Speech score conflates constructs | WER, pronunciation and tajwid are not interchangeable | Separate specifications and metrics for completeness, phonemes and each tajwid rule |
| P0 | No independent pedagogical speech trial | Benchmark accuracy does not show learning | Controlled delayed-transfer study with teacher-rated outcomes |
| P0 | Lesson mastery can be inferred too early | Immediate recognition creates false mastery | Two delayed uncued successes plus an unseen transfer item |
| P0 | Quran content lacks item-level scholarly/rights gates | Incorrect text/audio or unclear rights is unacceptable | Canonical-text checksum, source record, scholar approval and licence record per asset |
| P1 | No direct validation of spaced hifz scheduler | General memory transfer may not fit connected recitation | 7/30/90-day controlled hifz study against equal-time controls |
| P1 | No diglossia/L1-aware placement | Native, heritage and foreign learners receive the same path | Placement validity study and misplacement audit by learner group |
| P1 | Lesson count is not tied to skill coverage | 100 lessons can still repeat shallow items | Skill-prerequisite map, contrast/non-example coverage and unseen assessments |
| P1 | Child pathway lacks separate evidence and safeguards | Adult content/model behavior does not generalize to children | Guardian flow, child ASR calibration, child usability and safeguarding review |
| P1 | Accessibility is not a release gate | Quran/voice UI can exclude disabled learners | WCAG 2.2 AA plus VoiceOver/TalkBack and disabled-user task tests |
| P1 | Feedback lacks uncertainty and dispute semantics | False correction can teach an error | Visible transcript, confidence, abstention, replay, retry and report flow |
| P2 | Meaning and recitation progress are disconnected | Fluent sound production does not imply comprehension | Separate meaning retrieval and vocabulary/root transfer measures |
| P2 | Animation has no instructional governance | Motion can distract, trigger symptoms or hide state | Motion inventory with purpose, reduced-motion alternative and task-performance A/B tests |

## Evidence-backed Muslingo lesson architecture

### Placement

1. Goal and prior Quran exposure.
2. Primary language, Arabic status and dialect.
3. Letter-form and dot-pattern discrimination.
4. Vowelized word/pseudoword decoding.
5. Oral vocabulary and short meaning task.
6. Listen-discriminate task for target contrasts.
7. Optional speech sample with explicit consent and an uncertainty-safe result.
8. Known-surah self-report followed by one uncued verification sample.

Placement output must be a recommendation with confidence, not a permanent “level.”

### Daily lesson loop

1. Two due retrievals without answer exposure.
2. One focused correction from the previous error log.
3. One new target taught with a reviewed example.
4. One contrastive/non-example discrimination.
5. Listen, then guided production.
6. One unseen transfer item.
7. One meaning/root task.
8. Confidence self-rating before reveal.
9. Specific feedback and unlimited retry.
10. Scheduling explanation and next due date.

### Mastery rule

An item is mastered only when all required dimensions have evidence:

```text
taught exposure
  != immediate correct response
  != delayed recognition
  != delayed uncued production
  != transfer to a new context
```

Recommended state model:

```text
introduced -> guided -> independently_correct -> retained -> transferred
```

Pronunciation and tajwid states remain `unassessed` unless the active model, rule, learner group and audio quality pass the validation gate.

## Minimum research program

### Study 1: Arabic placement validity

- Recruit native-dialect, heritage and non-Arabic learners across child/adult bands.
- Compare app placement with an independent teacher assessment.
- Report agreement and misplacement by language background.
- Re-test after four weeks for predictive validity.

### Study 2: Hifz scheduler trial

- Randomize learners to adaptive spaced retrieval, fixed review or equal-time restudy.
- Keep content, total practice time and teacher access equivalent.
- Primary outcome: uncued, blinded teacher-rated retention at 30 days.
- Follow at 7 and 90 days; report attrition and review burden.

### Study 3: Speech benchmark and fairness audit

- Pre-register error taxonomy and thresholds.
- Hold out speakers, ayat, sessions and devices.
- Report per-rule and per-group precision/recall/calibration.
- Include low-quality audio and explicit abstention evaluation.
- Compare two teachers, adjudicated gold label and model.

### Study 4: Feedback learning trial

- Compare score-only, specific corrective feedback and specific feedback plus focused retry.
- Assess an unseen ayah/word, not the trained item only.
- Measure learning, false beliefs, frustration and retry behavior.

### Study 5: Child and accessibility co-design

- Include blind/low-vision, motor, hearing, speech and reading-difficulty participants.
- Test core tasks with VoiceOver/TalkBack, text scaling, switch/keyboard and reduced motion.
- Record task success, independent completion, errors and qualitative barriers.

## Claims Muslingo should not make yet

- “AI accurately grades all tajwid rules.”
- “82% pronunciation accuracy” without a validated construct and confidence interval.
- “Scientifically proven hifz algorithm.”
- “Improves intelligence, grades, wellbeing or faith” based on observational hifz correlations.
- “Suitable for all children” without child-specific validation and safeguarding.
- “Accessible” based only on automated linting or the existence of an accessibility setting.
- “More animation improves learning.”
- “Open source/open data” when only the repository is public and underlying audio has separate rights.

## Product decision

Keep the existing breadth of Quran, Arabic, foundations and tajwid paths, but stop measuring progress by lesson count. The next content investment should be:

1. A skill and prerequisite graph for every existing lesson.
2. Contrastive examples and unseen transfer items for every core reading/tajwid target.
3. Delayed retrieval and multidimensional mastery states.
4. A speech claim boundary and abstention-safe feedback contract.
5. A licensed, consented learner-speech research program.
6. A child/accessibility release gate.
7. Controlled Muslingo studies for hifz spacing and feedback efficacy.

Only after these foundations are measurable should the curriculum expand further. One hundred validated, progressively difficult lessons are more valuable than several hundred obvious or duplicative tests.

## Source inventory

The complete 54-record source inventory and source-by-source implications are in [learning-science-evidence-2026-09-11.csv](./learning-science-evidence-2026-09-11.csv). DOI links resolve to the version of record; official repository and dataset links are included where the research artifact depends on downloadable data or code. Licence statements reflect publicly visible metadata checked on 11 September 2026 and require legal confirmation before production ingestion.
