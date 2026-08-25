import fs from 'node:fs/promises';

import { evaluateSpeechBody } from '../server/routes/speech-evaluate.js';

const TTS_URL = 'https://api.openai.com/v1/audio/speech';
const RETRYABLE_STATUSES = new Set([408, 409, 429, 500, 502, 503, 504]);

async function loadLocalEnvironment() {
  if (process.env.OPENAI_API_KEY) return;
  const source = await fs.readFile('.env.local', 'utf8');
  for (const rawLine of source.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const separator = line.indexOf('=');
    if (separator < 1) continue;
    const key = line.slice(0, separator).trim();
    const value = line.slice(separator + 1).trim();
    if (!process.env[key]) process.env[key] = value;
  }
}

async function generateVoice(target, attempt = 0) {
  const response = await fetch(TTS_URL, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-4o-mini-tts',
      voice: 'alloy',
      input: target,
      instructions:
        'Pronounce the Arabic text clearly, naturally, and slowly. Do not add or omit words.',
      response_format: 'opus',
    }),
  });
  if (response.ok) return Buffer.from(await response.arrayBuffer());
  if (RETRYABLE_STATUSES.has(response.status) && attempt < 3) {
    await new Promise((resolve) => setTimeout(resolve, 1000 * 2 ** attempt));
    return generateVoice(target, attempt + 1);
  }
  throw new Error(`TTS request failed with HTTP ${response.status}`);
}

async function main() {
  await loadLocalEnvironment();
  if (!process.env.OPENAI_API_KEY) throw new Error('OPENAI_API_KEY is missing');

  const inputPath = process.argv[2];
  const outputPath = process.argv[3] ?? '/tmp/muslingo-voice-audit.json';
  if (!inputPath) throw new Error('Usage: node tool/voice_simulator_audit.mjs targets.json [output.json]');
  const targets = JSON.parse(await fs.readFile(inputPath, 'utf8'));
  const byTarget = new Map();
  for (const item of targets) {
    if (!byTarget.has(item.target)) byTarget.set(item.target, []);
    byTarget.get(item.target).push(item);
  }

  const results = [];
  let completed = 0;
  for (const [target, items] of byTarget) {
    try {
      const audio = await generateVoice(target);
      const first = items[0];
      const audioResult = await evaluateSpeechBody({
        target,
        phoneticTarget: first.phoneticTarget,
        passScore: first.passScore,
        audioBase64: audio.toString('base64'),
        audioMimeType: 'audio/ogg',
      });
      for (const item of items) {
        const evaluated = await evaluateSpeechBody({
          transcript: audioResult.payload.transcript,
          target: item.target,
          phoneticTarget: item.phoneticTarget,
          passScore: item.passScore,
        });
        results.push({
          ...item,
          transcript: audioResult.payload.transcript,
          score: evaluated.payload.score,
          passed: evaluated.payload.passed,
          audioBytes: audio.length,
        });
      }
    } catch (error) {
      for (const item of items) {
        results.push({
          ...item,
          score: 0,
          passed: false,
          error: error instanceof Error ? error.message : String(error),
        });
      }
    }
    completed += 1;
    process.stderr.write(`\rVoice samples checked: ${completed}/${byTarget.size}`);
  }
  process.stderr.write('\n');

  const failed = results.filter((result) => !result.passed);
  const report = {
    generatedAt: new Date().toISOString(),
    totalSpeechSteps: targets.length,
    uniqueVoiceSamples: byTarget.size,
    passed: results.length - failed.length,
    failed: failed.length,
    failures: failed,
    results,
  };
  await fs.writeFile(outputPath, `${JSON.stringify(report, null, 2)}\n`);
  process.stdout.write(
    `${JSON.stringify({ ...report, results: undefined, failures: failed.slice(0, 20) }, null, 2)}\n`,
  );
  if (failed.length > 0) process.exitCode = 1;
}

await main();
