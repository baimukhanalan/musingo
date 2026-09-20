import fs from 'node:fs';
import { execFileSync } from 'node:child_process';
import { applyLearningGlossary } from './learning_translation_glossary.mjs';

// Development-time generation only. No learner content or credentials are sent.
// Arabic originals, URLs, stable IDs and answer order are never translated.
const source = JSON.parse(execFileSync(process.env.DART_BIN || 'dart', ['run', 'tool/export_learning_strings.dart'], { encoding: 'utf8', maxBuffer: 8 * 1024 * 1024 }));
const phoneticTerms = new Set(source.phoneticTerms);
const escapeRegex = value => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const phoneticPattern = `(?<![\\p{L}])(?:${[...phoneticTerms].filter(value => value.length >= 3).sort((a, b) => b.length - a.length).map(escapeRegex).join('|')})(?![\\p{L}])`;
const protectedPattern = new RegExp(`https?:\\/\\/[^\\s)]+|[\\u0600-\\u06ff\\u0750-\\u077f\\u08a0-\\u08ff]+(?:[\\s\\u200c\\u200d]+[\\u0600-\\u06ff\\u0750-\\u077f\\u08a0-\\u08ff]+)*|${phoneticPattern}`, 'gu');
const phoneticMatcher = new RegExp(phoneticPattern, 'u');
const latin = { а:'a',б:'b',в:'v',г:'g',д:'d',е:'e',ё:'yo',ж:'zh',з:'z',и:'i',й:'y',к:'k',л:'l',м:'m',н:'n',о:'o',п:'p',р:'r',с:'s',т:'t',у:'u',ф:'f',х:'kh',ц:'ts',ч:'ch',ш:'sh',щ:'shch',ъ:'ʿ',ы:'y',ь:'',э:'e',ю:'yu',я:'ya' };
function preserve(value, language) {
  if (language !== 'en' || !phoneticTerms.has(value)) return value;
  return [...value].map(letter => { const mapped = latin[letter.toLowerCase()]; return mapped === undefined ? letter : letter === letter.toUpperCase() ? mapped.charAt(0).toUpperCase() + mapped.slice(1) : mapped; }).join('');
}
const wait = ms => new Promise(resolve => setTimeout(resolve, ms));

async function translateSinglePreservingOriginals(text, language) {
  const matches = [...text.matchAll(protectedPattern)];
  const parts = [];
  let cursor = 0;
  async function plain(value) {
    if (!/[A-Za-zА-Яа-яЁё]/u.test(value)) return value;
    const url = new URL('https://translate.googleapis.com/translate_a/single');
    for (const [key, item] of Object.entries({ client: 'gtx', sl: /[А-Яа-яЁё]/u.test(value) ? 'ru' : 'auto', tl: language, dt: 't', q: value })) url.searchParams.set(key, item);
    const response = await fetch(url, { signal: AbortSignal.timeout(35000) });
    if (!response.ok) throw new Error(`Translation HTTP ${response.status}`);
    const result = await response.json();
    const translated = result[0].map(item => item[0] || '').join('');
    return `${value.match(/^\s*/)[0]}${translated.trim()}${value.match(/\s*$/)[0]}`;
  }
  for (const match of matches) {
    parts.push(await plain(text.slice(cursor, match.index)), preserve(match[0], language));
    cursor = match.index + match[0].length;
  }
  parts.push(await plain(text.slice(cursor)));
  return parts.join('');
}

function protect(text, language) {
  const values = [];
  return {
    text: text.replace(protectedPattern, value => { const key = `ZXQ${values.length}QXZ`; values.push(value); return key; }),
    restore(translated) {
      for (const [index, value] of values.entries()) {
        const pattern = new RegExp(`ZXQ\\s*${index}\\s*QXZ`, 'giu');
        if (!pattern.test(translated)) throw new Error(`Lost protected text ${index}`);
        translated = translated.replace(pattern, preserve(value, language));
      }
      return translated;
    },
  };
}

async function translateBatch(strings, language, attempt = 0) {
  const entries = strings.map(text => protect(text, language));
  const text = entries.map((entry, i) => `[${990000 + i}] ${entry.text.replace(/\n/g, ' ZNEWLINEZ ')}`).join('\n');
  const url = new URL('https://translate.googleapis.com/translate_a/single');
  for (const [key, value] of Object.entries({ client: 'gtx', sl: /[А-Яа-яЁё]/u.test(text) ? 'ru' : 'auto', tl: language, dt: 't', q: text })) url.searchParams.set(key, value);
  try {
    const response = await fetch(url, { signal: AbortSignal.timeout(35000) });
    if (!response.ok) throw new Error(`Translation HTTP ${response.status}`);
    const result = await response.json();
    const translated = result[0].map(item => item[0] || '').join('');
    const matches = [...translated.matchAll(/\[\s*(990\d{3})\s*\]\s*/g)];
    if (matches.length !== entries.length) throw new Error(`Batch markers ${matches.length}/${entries.length}`);
    return entries.map((entry, index) => {
      if (Number(matches[index][1]) !== 990000 + index) throw new Error('Batch reordered');
      const start = matches[index].index + matches[index][0].length;
      const end = index + 1 < matches.length ? matches[index + 1].index : translated.length;
      return entry.restore(translated.slice(start, end).trim().replace(/\s*ZNEWLINEZ\s*/gi, '\n'));
    });
  } catch (error) {
    if (strings.length > 1) {
      const half = Math.ceil(strings.length / 2);
      return [...await translateBatch(strings.slice(0, half), language), ...await translateBatch(strings.slice(half), language)];
    }
    if (/Lost protected text|Batch markers|Batch reordered/.test(error.message)) {
      return [await translateSinglePreservingOriginals(strings[0], language)];
    }
    if (attempt < 3) { await wait(1000 * (attempt + 1)); return translateBatch(strings, language, attempt + 1); }
    throw error;
  }
}

for (const language of ['kk', 'en']) {
  const file = `assets/data/learning_${language}.json`;
  const data = fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : {};
  const translations = data.translations || {};
  const missing = source.strings.filter(text => !translations[text] ||
    (language === 'en' && /[А-Яа-яЁё]/u.test(translations[text])) ||
    (translations[text] === text && /[А-Яа-яЁё]/u.test(text) && /[: ]/u.test(text)) ||
    (!data.phoneticTermsProtected && (phoneticTerms.has(text) || phoneticMatcher.test(text))));
  const batches = [];
  let batch = [], size = 0;
  for (const text of missing) {
    if (batch.length && (size + text.length > 2600 || batch.length >= 35)) { batches.push(batch); batch = []; size = 0; }
    batch.push(text); size += text.length;
  }
  if (batch.length) batches.push(batch);
  let done = 0;
  const save = () => {
    const temporary = `${file}.tmp`;
    fs.writeFileSync(temporary, `${JSON.stringify({ schemaVersion: 1, locale: language, sourceLanguage: 'ru', translationMethod: 'Google machine translation with protected Arabic and phonetic reading aids; authored glossary overrides', reviewed: false, phoneticTermsProtected: batches.length === 0 && done === missing.length, lessonCount: source.lessonCount, moduleCount: source.moduleCount, sourceStringCount: source.strings.length, translations }, null, 2)}\n`);
    fs.renameSync(temporary, file);
  };
  async function worker() {
    while (batches.length) {
      const next = batches.shift();
      const translated = await translateBatch(next, language);
      next.forEach((text, index) => { translations[text] = translated[index]; });
      done += next.length;
      save();
      if (done % 100 < next.length || !batches.length) console.log(`${language}: ${Object.keys(translations).length}/${source.strings.length}`);
      await wait(120);
    }
  }
  await Promise.all(Array.from({ length: 4 }, worker));
  for (const text of source.strings) {
    if (phoneticTerms.has(text)) translations[text] = preserve(text, language);
  }
  const glossary = {
    'Милостивого': ['Аса қамқор', 'The Most Gracious'],
    'Милосердного': ['Ерекше мейірімді', 'The Most Merciful'],
    'Господа миров': ['Әлемдердің Раббысы', 'Lord of the worlds'],
    'Только гласными': ['Тек дауысты дыбыстар', 'Vowels only'],
    'Только огласовками': ['Тек харакат белгілері', 'Vowel marks only'],
    'И согласными, и долгими гласными': ['Дауыссыз дыбыстар да, созылыңқы дауысты дыбыстар да', 'Both consonants and long vowels'],
  };
  for (const [text, values] of Object.entries(glossary)) translations[text] = values[language === 'kk' ? 0 : 1];
  for (const [text, translated] of Object.entries(translations)) {
    translations[text] = applyLearningGlossary(text, translated, language);
  }
  // Native authored video text outranks all machine translation/glossary output.
  for (const text of source.nativeVideoStrings?.[language] || []) {
    translations[text] = text;
  }
  save();
}
