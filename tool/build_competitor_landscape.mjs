import fs from 'node:fs';
import path from 'node:path';

const root = process.cwd();
const sourcePath = path.join(
  root,
  'docs/research/agents/product-pedagogy-expansion-2026-09-11.csv',
);
const outputDir = path.join(root, 'docs/research/competitors');
const csvPath = path.join(
  outputDir,
  'muslingo-competitive-landscape-2026-09-11.csv',
);
const jsonPath = path.join(
  outputDir,
  'muslingo-competitive-landscape-2026-09-11.json',
);
const sourcesPath = path.join(
  outputDir,
  'muslingo-competitive-sources-2026-09-11.csv',
);
const previousSourceStatuses = fs.existsSync(sourcesPath)
  ? new Map(parseCsv(fs.readFileSync(sourcesPath, 'utf8')).map((row) => [
      row.canonical_url,
      row.http_status,
    ]))
  : new Map();

const productAliases = new Map(Object.entries({
  'academy by muslim pro': 'muslim-pro',
  'muslim pro': 'muslim-pro',
  'muslim pro / academy by muslim pro': 'muslim-pro',
  'arabic101': 'arabic101',
  'arabic101 academy': 'arabic101',
  'quran.com': 'quran-com',
  'quran.com / quran foundation': 'quran-com',
  'sajda': 'sajda',
  'sajda academy': 'sajda',
  'tarteel': 'tarteel',
  'tarteel ai': 'tarteel',
}));
const preferredProductNames = new Map(Object.entries({
  'arabic101': 'Arabic101',
  'muslim-pro': 'Muslim Pro',
  'quran-com': 'Quran.com',
  'sajda': 'Sajda',
  'tarteel': 'Tarteel',
}));

function canonicalProductId(product) {
  const normalized = product.trim().toLowerCase();
  return productAliases.get(normalized) ?? normalized
    .normalize('NFKD')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '');
}

function sourceType(url) {
  if (/apps\.apple\.com|play\.google\.com/.test(url)) return 'app_store';
  if (/privacy|terms|legal/.test(url)) return 'policy';
  if (/support|help|docs|faq/.test(url)) return 'documentation';
  if (/pricing|plans|premium|subscription/.test(url)) return 'pricing';
  return 'product';
}

function splitSources(value) {
  return String(value ?? '')
    .split(/\s*(?:\||;(?=\s*https?:\/\/))\s*/)
    .map((url) => url.trim())
    .filter((url) => url.startsWith('http'))
    .filter((url) => !/play\.google\.com\/store\/search\?/.test(url));
}

function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = '';
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    if (quoted) {
      if (char === '"' && text[index + 1] === '"') {
        field += '"';
        index += 1;
      } else if (char === '"') {
        quoted = false;
      } else {
        field += char;
      }
    } else if (char === '"') {
      quoted = true;
    } else if (char === ',') {
      row.push(field);
      field = '';
    } else if (char === '\n') {
      row.push(field);
      rows.push(row);
      row = [];
      field = '';
    } else if (char !== '\r') {
      field += char;
    }
  }
  if (field || row.length) {
    row.push(field);
    rows.push(row);
  }
  const [headers, ...values] = rows;
  return values
    .filter((cells) => cells.some(Boolean))
    .map((cells) => Object.fromEntries(headers.map((header, i) => [header, cells[i] ?? ''])));
}

function csvCell(value) {
  const text = String(value ?? '');
  return /[",\n\r]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

const base = parseCsv(fs.readFileSync(sourcePath, 'utf8')).map((row) => ({
  product: row.product,
  segment: row.category,
  depth: 'deep',
  evidence_status: 'confirmed_with_gaps',
  defining_strength: row.confirmed,
  main_gap: row.evidence_gaps,
  muslingo_move: row.inference_for_muslingo,
  official_sources: row.official_sources,
  source_files: 'docs/research/agents/product-pedagogy-expansion-2026-09-11.csv',
}));

const expansion = [
  ['Tasmi', 'Quran memorization and teacher companion', 'deep', 'confirmed_with_gaps', 'Family and tutor positioning with recitation feedback between lessons', 'Public evidence for independent speech validity remains limited', 'Add teacher-visible attempts and make automated feedback subordinate to qualified review', 'https://www.tasmi.app/'],
  ['Hifz AI', 'Quran memorization and speech', 'mapped', 'confirmed_with_gaps', 'Arabic-first AI memorization and smart recitation mode', 'Public validation and governance detail are limited', 'Treat Arabic-first onboarding and offline practice as regional benchmarks', 'https://hifzai.app/ar'],
  ['Quran Companion', 'Quran memorization and social practice', 'mapped', 'confirmed_with_gaps', 'Memorization planning, challenges and community accountability', 'Adaptive mastery evidence is not sufficiently public', 'Use private accountability without publicizing sensitive religious activity', 'https://www.qurancompanion.com/'],
  ['Quran Academy', 'Quran memorization and word-level study', 'mapped', 'confirmed_with_gaps', 'Structured memorization platform with Quran study tooling', 'Current feature and pricing boundaries require checkout validation', 'Benchmark word-level study, but keep the daily plan simpler', 'https://quranacademy.io/'],
  ['Tatbith', 'Quran memorization and revision', 'mapped', 'emerging', 'Traditional memorization flow and balance between new material and revision', 'Young product with limited public operating evidence', 'Model the daily balance of new memorization and old review', 'https://www.tatbith.app/'],
  ['Gardens of the Quran', 'Quran revision and family monitoring', 'mapped', 'emerging', 'Device linking, review scheduling and parent monitor concept', 'Evidence is primarily launch-stage and needs product verification', 'Offer progress transfer and parent monitoring with explicit consent', 'https://play.google.com/store/search?q=Gardens%20of%20the%20Quran&c=apps'],
  ['HifzMate', 'Quran memorization utility', 'mapped', 'emerging', 'Community-built memorization and tajwid practice', 'Small product and incomplete public evidence', 'Watch emerging tools for focused workflows without copying content', 'https://hifzmate.com/'],
  ['HifzPath', 'Quran memorization utility', 'mapped', 'emerging', 'Focused revision planning without broad superapp scope', 'Beta-stage evidence and durability are unclear', 'Keep Muslingo focused on one daily learning decision', 'https://hifzpath.app/'],
  ['Journey2Jannah', 'Gamified Islamic learning', 'mapped', 'confirmed_with_gaps', 'Explicit game-like learning structure', 'Source governance and outcome evidence require deeper review', 'Use journeys only when every activity maps to a learning objective', 'https://journey2jannah.com/'],
  ['Noor Ul Huda', 'Gamified Islamic learning for children', 'mapped', 'confirmed_with_gaps', 'Stories, quizzes, Quran lessons and multilingual child experience', 'Public safeguarding and assessment detail are limited', 'Create age-aware paths and require parent control for child accounts', 'https://www.hudalabs.app/'],
  ['NOOR', 'Adventure Quran learning for children', 'mapped', 'confirmed_with_gaps', '500+ interactive lessons, quests, XP, streaks and parent dashboard', 'Independent outcome and content-governance evidence not found', 'Build coherent character-led journeys while measuring mastery, not activity', 'https://noor.vip/'],
  ['Al Noor Kids', 'Islamic habits and learning for families', 'mapped', 'confirmed_with_gaps', 'Family dashboard, age tiers, games and parent approval', 'Religious reward framing and AI answers need careful governance', 'Adopt parent approval and family routines, avoid scoring piety', 'https://alnoorkids.com/'],
  ['Noor World', 'K-12 Quran, Arabic and Islamic studies', 'mapped', 'confirmed_with_gaps', 'Three curriculum tracks, levels, reports and school use', 'Adaptive individualization is not established publicly', 'Benchmark school reporting and age-banded curricula', 'https://noorworld.com/'],
  ['NoorTrails', 'Islamic learning for children', 'mapped', 'confirmed_with_gaps', 'Stories, guided lessons, quizzes and ad-free child positioning', 'Product depth and assessment validity need verification', 'Pair joyful stories with retrieval and delayed review', 'https://noorinitiative.com/'],
  ['MuslimKids.TV', 'Islamic media and games for children', 'mapped', 'confirmed_with_gaps', 'Large cross-device library and Recitation Buddy', 'Content volume is not evidence of a personalized curriculum', 'Do not compete on library size; connect every media item to the learning path', 'https://www.muslimkids.tv/'],
  ['Miraj Stories', 'Islamic stories and learning for children', 'mapped', 'confirmed_with_gaps', 'Narrative-led child engagement and family media', 'Personalized mastery and speech correction are not core', 'Use stories as motivation and comprehension contexts, not as a separate feed', 'https://mirajstories.com/'],
  ['Ali Huda', 'Islamic streaming for children', 'mapped', 'confirmed_with_gaps', 'Child-safe Islamic video ecosystem', 'Primarily consumption rather than assessed learning', 'Keep video secondary and require an active recall step', 'https://alihuda.com/'],
  ['Learning Roots', 'Islamic educational products for families', 'mapped', 'confirmed_with_gaps', 'Strong family brand and tangible learning materials', 'App-native adaptation and mastery signals vary by product', 'Create teacher and parent kits around the app path', 'https://www.learningroots.com/'],
  ['SABIL Children Academy', 'Gamified Islamic curriculum for children', 'mapped', 'confirmed_with_gaps', 'Twelve pillars spanning belief, Quran, salah, seerah, character and Arabic', 'Public assessment and product maturity detail are limited', 'Use a visible curriculum map with declared source scope', 'https://thesabilinstitute.org/masjid/academy/children'],
  ['New Muslim Academy', 'New Muslim foundations', 'mapped', 'confirmed_with_gaps', 'Beginner-focused fundamentals and Quran classes', 'Mobile microlearning and adaptive routing are not core', 'Create a distinct new-Muslim route with safe escalation to people', 'https://www.newmuslimacademy.org/'],
  ['AlHuda Online', 'Quran and Islamic studies courses', 'mapped', 'confirmed_with_gaps', 'Instructor-led course catalogue and learning features', 'Not a lightweight daily adaptive app', 'Partner or link for deep study after Muslingo foundations', 'https://alhudaonline.org/online-courses'],
  ['Maqraa', 'Institutional electronic Quran teaching', 'mapped', 'confirmed_with_gaps', 'Institutional teaching and recitation access', 'Regional access and integration terms require diligence', 'Use as a model for qualified escalation and certification boundaries', 'https://maqraa.prh.gov.sa/en'],
  ['Riwaq Al Quran', 'Online Quran teaching', 'mapped', 'confirmed_with_gaps', 'Live recitation and tajwid teaching', 'Teacher availability and unit economics differ from self-service apps', 'Offer paid human review only for recordings that need it', 'https://riwaqalquran.com/courses/recitation-with-tajweed'],
  ['Madinah Arabic', 'Arabic reading and grammar', 'mapped', 'confirmed_with_gaps', 'Free structured Arabic reading and grammar materials', 'Not an adaptive mobile learning system', 'Use as a syllabus reference only where licensing permits', 'https://madinaharabic.com/free-content/reading'],
  ['Cambridge Muslim College Online', 'Islamic studies online learning', 'mapped', 'confirmed_with_gaps', 'Institutional long-form Islamic learning', 'Not designed for short daily beginner practice', 'Create a clear handoff from foundations to advanced study partners', 'https://www.cambridgemuslimcollege.ac.uk/onlinelearning'],
  ['Muslim App', 'Islamic daily utility and widgets', 'mapped', 'confirmed_with_gaps', 'Verse-of-day and prayer widgets across device surfaces', 'Learning diagnostics and mastery are not core', 'Use widgets to return users to assigned learning, not generic content alone', 'https://muslimapp.com/guide/on-your-device'],
  ['Pillars', 'Prayer and Quran utility', 'mapped', 'confirmed_with_gaps', 'Focused, privacy-oriented worship utility', 'Does not solve structured Quran learning', 'Keep Muslingo focused and privacy-forward instead of becoming a superapp', 'https://www.thepillarsapp.com/'],
  ['Athan', 'Islamic utility and content', 'mapped', 'confirmed_with_gaps', 'Large prayer, Quran and content utility footprint', 'Broad utility navigation can dilute learning focus', 'Compete through a single daily lesson decision rather than utility breadth', 'https://www.islamicfinder.org/athan/'],
  ['Quran for Android', 'Open Quran reader', 'mapped', 'confirmed_with_gaps', 'Open-source, reliable reading and audio utility', 'No personalized curriculum or speech assessment', 'Do not rebuild commodity reader features before mastery infrastructure', 'https://github.com/quran/quran_android'],
  ['Ayat', 'Quran reader and study', 'mapped', 'confirmed_with_gaps', 'University-backed Quran reading and study tooling', 'Adaptive lesson workflow is not core', 'Prefer trusted data and clear provenance over proprietary copies', 'https://quran.ksu.edu.sa/ayat/'],
  ['LingoDeer', 'Language-learning benchmark', 'mapped', 'confirmed_with_gaps', 'Structured grammar-aware paths for non-Latin scripts', 'No Quranic or religious-content authority', 'Use explicit grammar explanations and script scaffolding', 'https://www.lingodeer.com/'],
  ['Drops', 'Vocabulary microlearning benchmark', 'mapped', 'confirmed_with_gaps', 'Fast visual sessions and habit design', 'Shallow productive language depth if used alone', 'Use short sessions but require decoding and production transfer', 'https://languagedrops.com/'],
  ['Babbel', 'Language-learning benchmark', 'mapped', 'confirmed_with_gaps', 'Goal-oriented adult courses and review', 'Arabic/Quran relevance is limited', 'Benchmark adult tone and practical goal onboarding', 'https://www.babbel.com/'],
  ['Brilliant', 'Interactive learning benchmark', 'mapped', 'confirmed_with_gaps', 'Guided problem solving and non-obvious interactive tasks', 'Not a language or faith product', 'Replace obvious quizzes with reasoning and immediate explanatory feedback', 'https://brilliant.org/'],
  ['Elevate', 'Cognitive training benchmark', 'mapped', 'confirmed_with_gaps', 'Daily personalized training and polished feedback', 'Transfer to real-world outcomes is a general category challenge', 'Make daily plans feel premium while measuring Quran-specific outcomes', 'https://elevateapp.com/'],
  ['Mondly', 'Language-learning benchmark', 'mapped', 'confirmed_with_gaps', 'Speech, daily lessons and broad localization', 'Speech accuracy and depth vary by language', 'Benchmark localization breadth but validate Arabic speech separately', 'https://www.mondly.com/'],
  ['LingoPie', 'Video immersion benchmark', 'mapped', 'confirmed_with_gaps', 'Dual subtitles and media-to-vocabulary loop', 'Content rights and Quran suitability are central constraints', 'Turn licensed audio/video into active tasks with source metadata', 'https://lingopie.com/'],
  ['Coursera Arabic', 'Course marketplace benchmark', 'mapped', 'confirmed_with_gaps', 'Institutional course structure and certificates', 'Long sessions and low daily personalization', 'Use optional certificates only after defensible assessment', 'https://www.coursera.org/learn/arabic-for-beginners-1-arabic-alphabet-and-phonology'],
  ['OpenLearn Arabic', 'Open education benchmark', 'mapped', 'confirmed_with_gaps', 'Free university-authored beginner Arabic material', 'No mobile adaptive engine', 'Use open resources only under their exact licenses and add active practice', 'https://www.open.edu/openlearn/education-development/introduction-arabic'],
];

const manualRows = expansion.map((values) => Object.fromEntries([
  'product', 'segment', 'depth', 'evidence_status', 'defining_strength',
  'main_gap', 'muslingo_move', 'official_sources',
].map((key, index) => [key, values[index]])));
for (const row of manualRows) row.source_files = 'tool/build_competitor_landscape.mjs';

function existingAgentRows(fileName, mapper) {
  const filePath = path.join(outputDir, fileName);
  if (!fs.existsSync(filePath)) return [];
  return parseCsv(fs.readFileSync(filePath, 'utf8'))
    .map((row) => ({ ...mapper(row), source_files: `docs/research/competitors/${fileName}` }))
    .filter((row) => row.product && row.official_sources);
}

const agentRows = [
  ...existingAgentRows('direct-quran-ai-competitors-2026-09-11.csv', (row) => ({
    product: row.product,
    segment: row.segment,
    depth: 'deep',
    evidence_status: row.evidence_status,
    defining_strength: row.strengths,
    main_gap: row.weaknesses,
    muslingo_move: row.switch_trigger_to_muslingo,
    official_sources: row.official_urls,
  })),
  ...existingAgentRows('islamic-gamified-learning-2026-09-11.csv', (row) => ({
    product: row.product,
    segment: row.category,
    depth: 'deep',
    evidence_status: row.sources_status,
    defining_strength: [row.lesson_loop, row.motivation].filter(Boolean).join('; '),
    main_gap: row.principal_gap,
    muslingo_move: row.muslingo_relevance,
    official_sources: row.source_urls,
  })),
  ...existingAgentRows('islamic-superapps-2026-09-11.csv', (row) => ({
    product: row.product,
    segment: row.segment,
    depth: 'deep',
    evidence_status: row.evidence_status,
    defining_strength: [row.reader_audio_search, row.academy_learning].filter(Boolean).join('; '),
    main_gap: row.breadth_focus,
    muslingo_move: row.notes,
    official_sources: [row.primary_url, row.secondary_url].filter(Boolean).join(' | '),
  })),
  ...existingAgentRows('edtech-growth-mechanics-2026-09-11.csv', (row) => ({
    product: row.product,
    segment: row.segment,
    depth: 'deep',
    evidence_status: row.evidence_status,
    defining_strength: [row.adaptive_path, row.srs_review, row.lesson_sequence].filter(Boolean).join('; '),
    main_gap: row.unacceptable_or_risky || row.not_found,
    muslingo_move: row.applicable_to_muslingo,
    official_sources: row.source_urls || row.official_url,
  })),
  ...existingAgentRows('kids-family-new-muslim-2026-09-11.csv', (row) => ({
    product: row.product,
    segment: row.segment,
    depth: 'deep',
    evidence_status: row.evidence_status,
    defining_strength: row.confirmed,
    main_gap: row.not_found,
    muslingo_move: row.transition_to_muslingo,
    official_sources: row.official_urls,
  })),
  ...existingAgentRows('competitive-growth-switching-2026-09-11.csv', (row) => ({
    product: row.product,
    segment: row.segment,
    depth: 'deep',
    evidence_status: row.evidence_level,
    defining_strength: [row.onboarding, row.streak, row.teacher_community_distribution]
      .filter(Boolean).join('; '),
    main_gap: row.notes || 'Growth evidence does not prove learning efficacy',
    muslingo_move: row.ethical_muslingo_implication,
    official_sources: row.source_urls,
  })),
  ...existingAgentRows('competitor-pricing-packaging-2026-09-11.csv', (row) => ({
    product: row.product,
    segment: row.segment,
    depth: 'deep',
    evidence_status: row.evidence_status,
    defining_strength: `Free: ${row.free_tier}; monthly: ${row.monthly_price}; annual: ${row.annual_price}`,
    main_gap: row.notes || 'Pricing varies by region and store',
    muslingo_move: 'Keep the first result and essential learning free; monetize advanced planning, offline, family and human review',
    official_sources: row.source_urls,
  })),
  ...existingAgentRows('competitor-review-painpoints-2026-09-11.csv', (row) => ({
    product: row.product,
    segment: row.segment,
    depth: 'deep',
    evidence_status: row.status,
    defining_strength: row.evidence_basis,
    main_gap: `${row.pain_category}: ${row.recurring_pattern}`,
    muslingo_move: row.muslingo_response,
    official_sources: row.source_urls,
  })),
];

const rows = [...base, ...manualRows, ...agentRows];

const merged = new Map();
for (const row of rows) {
  const key = canonicalProductId(row.product);
  const current = merged.get(key);
  if (!current) {
    merged.set(key, row);
    continue;
  }
  const sourceUrls = [...new Set([
    ...splitSources(current.official_sources),
    ...splitSources(row.official_sources),
  ])];
  const preferRow = row.depth === 'deep' && current.depth !== 'deep' ? row : current;
  merged.set(key, {
    ...preferRow,
    depth: current.depth === 'deep' || row.depth === 'deep' ? 'deep' : 'mapped',
    official_sources: sourceUrls.join(' | '),
    source_files: [...new Set(
      `${current.source_files} | ${row.source_files}`.split(/\s*\|\s*/).filter(Boolean),
    )].join(' | '),
  });
}

const unique = [...merged.entries()].map(([canonical_product_id, row]) => ({
  canonical_product_id,
  ...row,
  product: preferredProductNames.get(canonical_product_id) ?? row.product,
}))
  .sort((a, b) => a.segment.localeCompare(b.segment) || a.product.localeCompare(b.product));

fs.mkdirSync(outputDir, { recursive: true });
const headers = [
  'canonical_product_id', 'product', 'segment', 'depth', 'evidence_status', 'defining_strength',
  'main_gap', 'muslingo_move', 'official_sources',
];
fs.writeFileSync(
  csvPath,
  `${headers.join(',')}\n${unique.map((row) => headers.map((key) => csvCell(row[key])).join(',')).join('\n')}\n`,
);
const sourceRows = unique.flatMap((row) => splitSources(row.official_sources)
  .map((url) => ({
    canonical_product_id: row.canonical_product_id,
    product: row.product,
    canonical_url: url,
    source_type: sourceType(url),
    accessed_at: '2026-09-11',
    http_status: previousSourceStatuses.get(url) ?? 'not_rechecked',
    source_file: row.source_files,
  })));
const sourceHeaders = [
  'canonical_product_id', 'product', 'canonical_url', 'source_type',
  'accessed_at', 'http_status', 'source_file',
];
const dedupedSources = [...new Map(
  sourceRows.map((row) => [`${row.canonical_product_id}|${row.canonical_url}`, row]),
).values()];
fs.writeFileSync(
  sourcesPath,
  `${sourceHeaders.join(',')}\n${dedupedSources.map((row) => sourceHeaders.map((key) => csvCell(row[key])).join(',')).join('\n')}\n`,
);
fs.writeFileSync(
  jsonPath,
  `${JSON.stringify({
    generatedAt: '2026-09-11',
    productCount: unique.length,
    deepProfileCount: unique.filter((row) => row.depth === 'deep').length,
    uniqueSourceCount: new Set(dedupedSources.map((row) => row.canonical_url)).size,
    evidencePolicy: 'Official-source market metadata; public availability is not a content license.',
    products: unique,
  }, null, 2)}\n`,
);

console.log(JSON.stringify({ productCount: unique.length, csvPath, jsonPath, sourcesPath }));
