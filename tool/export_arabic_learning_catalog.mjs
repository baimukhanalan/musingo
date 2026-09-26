import { readFileSync, writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import {
  common, surahNames, quranStages, foundationThemes, foundationStages,
  arabicRows, tajwidRows,
} from './arabic_catalog_seed.mjs';

const sourceUrl = new URL('../docs/content/approved-570-curriculum-plan.json', import.meta.url);
const outputUrl = new URL('../assets/data/learning_ar.json', import.meta.url);
const source = readFileSync(sourceUrl, 'utf8');
const hash = createHash('sha256').update(source).digest('hex');
// Catalog translations must be re-reviewed if the source metadata changes.
if (hash !== 'a64fdebd42cbf65f71ad9723267feb70973d0487b6962a280f8dca219eee2104') {
  throw new Error('Curriculum source changed: review Arabic metadata translations before regenerating.');
}
const modules = JSON.parse(source).modules;
const translations = { ...common };
for (const [number, name] of Object.entries(surahNames)) translations[`Surah ${number}`] = `سورة ${name}`;
for (const module of modules) {
  const n = module.sequence;
  let pair;
  if (module.track === 'Quran') {
    const chapter = Number(module.strand.replace('Surah ', ''));
    const stage = quranStages[(n - 1) % 6];
    const range = module.learning_objective.match(/рабочий диапазон ([\d:-]+)\.$/)?.[1];
    if (!range || !surahNames[chapter]) throw new Error(`Missing Quran source range ${module.module_id}`);
    pair = [`سورة ${surahNames[chapter]}: ${stage[0]}`, `سيتمكن المتعلّم من ${stage[1]}؛ نطاق التدريب ${range}.`];
  } else if (module.track === 'Foundations/Academy') {
    const theme = foundationThemes[Math.floor((n - 1) / 10)];
    const stage = foundationStages[(n - 1) % 10];
    pair = [`${theme}: ${stage[0]}`, stage[1](theme)];
  } else if (module.track === 'Tajwid') {
    pair = tajwidRows[n];
  } else if (module.track === 'Arabic') {
    pair = arabicRows[n];
    if (n <= 28) {
      const letter = module.module_title.match(/^Буква (.) \(/u)?.[1];
      if (!letter) throw new Error(`Missing letter ${module.module_id}`);
      pair = [`الحرف ${letter}: التعرّف في السياق`, `التعرّف إلى الحرف ${letter} منفصلًا ومتصلًا وتمييزه من الحروف المتشابهة بصريًا؛ ويقيّم النطقَ إنسان أو اختبار متخصص تم التحقق من صلاحيته.`];
    } else if (n >= 81 && n <= 95) {
      const root = module.module_title.replace('Семья корня ', '');
      pair = [`عائلة الجذر ${root}`, `تجميع صيغ الجذر ${root} الموثّقة في QAC، مع التنبيه إلى أن اشتراك الكلمات في الجذر لا يجعل معانيها متطابقة.`];
    } else if (n >= 121 && n <= 130) {
      const form = module.module_title.replace('Форма глагола ', '');
      pair = [`صيغة الفعل ${form}`, `التعرّف إلى وسم الصيغة ${form} في QAC ومقارنة أمثلة معتمدة فقط دون استنتاج المعنى بصورة مستقلة.`];
    } else if (n >= 161 && n <= 168) {
      const chapter = Number(module.learning_objective.match(/суры (\d+),/)?.[1]);
      if (!surahNames[chapter]) throw new Error(`Missing analysis chapter ${module.module_id}`);
      pair = [`تحليل سورة ${surahNames[chapter]}`, `تقسيم آية مختارة من السورة ${chapter} إلى عناصرها، وتحديد أقسام الكلمات وخصائصها الصرفية للعناصر المدروسة، واستنتاج المعنى الأساسي الذي تدعمه القواعد فقط.`];
    }
  }
  if (!pair || pair.length !== 2 || pair.some(text => !/[\u0600-\u06ff]/u.test(text) || /[А-Яа-яЁё]/u.test(text))) {
    throw new Error(`Incomplete Arabic title/objective: ${module.module_id}`);
  }
  translations[module.module_title] = pair[0];
  translations[module.learning_objective] = pair[1];
}

const document = {
  schemaVersion: 1,
  locale: 'ar',
  sourceLanguage: 'ru',
  translationMethod: 'Controlled assistant-authored metadata translation; no external translation API',
  reviewed: false,
  reviewNote: 'Arabic linguistic and religious editorial review remains required; original owner approval does not certify this translation.',
  sourceAsset: 'docs/content/approved-570-curriculum-plan.json',
  sourceSha256: hash,
  coverage: {
    moduleTitles: modules.length,
    moduleObjectives: modules.length,
    moduleBodies: 'Not lecture manuscripts; existing catalog contains learning plans only.',
    legacyGuidedLessonBodiesComplete: false,
    fullQuranReadingInstructions: '902 units use separate controlled Dart templates; canonical Arabic is unchanged.',
    sourceLocators: 'Unmodified identifiers and original source references, not translated source editions.',
  },
  sourceStringCount: Object.keys(translations).length,
  translations: Object.fromEntries(Object.entries(translations).sort(([a], [b]) => a.localeCompare(b, 'en'))),
};
const output = `${JSON.stringify(document, null, 2)}\n`;
if (process.argv.includes('--check')) {
  if (readFileSync(outputUrl, 'utf8') !== output) throw new Error('learning_ar.json is out of date');
  console.log(`Arabic catalog parity PASS: ${modules.length} titles, ${modules.length} objectives; ${document.sourceStringCount} translated strings.`);
} else if (process.argv.includes('--write')) {
  writeFileSync(outputUrl, output);
  console.log(`Generated ${outputUrl.pathname}: ${document.sourceStringCount} strings.`);
} else {
  process.stdout.write(output);
}
