# Learning-language coverage

The selected app language now selects the learning content as well. Bundled
Kazakh and English dictionaries cover 6,243 unique source strings from all 246
interactive lessons, the 570-module curriculum, curated video notes, and static
mentor/learning-profile metadata. They load once and require no translation
service when a learner opens a lesson. Russian remains the original source.

## Content provenance and review status

The initial text translations were generated offline using Google text
translation from the existing project-authored material. The dictionaries mark
`reviewed: false`: the owner's earlier review of Russian material does not imply
approval of these new translations. A Kazakh/English language and religious
meaning review is still required before describing the translations as expert
reviewed. No theological claims or additional teaching material were added.

Source Arabic recitation, verse numbers, pronunciation scoring targets, source
URLs, module/lesson IDs, assessment answer indices and progress stay unchanged.
Arabic phonetic reading options are protected from semantic machine translation.
English uses Latin romanization; Kazakh retains the existing Cyrillic reading
aid. This is a pronunciation aid, not a replacement for listening to the Arabic.
Embedded third-party recordings retain their original audio language. Their
notes, titles, topics and comprehension activities are translated; this release
does not dub those recordings.

## Quality checks

`test/lesson_content_localization_test.dart` checks every lesson's teaching text,
question, answer, explanation, matching pair and word bank against the bundled
dictionary; it also checks unchanged scoring targets and answer indices. All
570 localized modules produce five challenges with four distinct options.

The checks caught and fixed two classes of machine-translation errors:

- Phonetic answer options such as `закаатун` must remain reading samples, not
  become semantic translations. The generator protects 697 phonetic phrases.
- Distinct quiz concepts must not collapse into the same translated option.
  Authored glossary overrides distinguish *Most Gracious / Most Merciful*
  (`Аса қамқор / Ерекше мейірімді`) and vowels versus vowel marks.

The active lesson also resets transient answer/word-order UI when the language
changes, while retaining progress and remapping mistake-review steps.

## Rebuilding

`tool/export_learning_strings.dart` exports the actual strengthened lessons,
curriculum metadata, video notes and static mentor strings.
`tool/build_learning_translations.mjs` generates/resumes the bundled dictionaries,
using `dart` on PATH (or the explicit `DART_BIN` environment variable),
protects original Arabic/phonetic samples and URLs, and writes each output
atomically. The generator sends educational source text only, never learner
history or credentials. Run the coverage tests after every content update.

Machine translation coverage and structural checks do not substitute for a
human review of meaning, terminology or naturalness.

## Live terminology follow-up

The first live Kazakh lesson exposed an ayah incorrectly translated as poetry.
A source-conditioned glossary now corrects Kazakh inflections of `өлең` and
`тармақ` only where the source refers to an ayah/verse. The genuine poetry
distractor and unrelated words such as `көлеңке` remain intact. The Fatiha
introduction and frequent assessment wording have authored corrections.

Native-language video notes are returned unchanged when their original language
matches the selected app language; the generator also protects those exact
native strings. Each translated lesson and curriculum view visibly labels its
automatic translation as awaiting editorial review.
